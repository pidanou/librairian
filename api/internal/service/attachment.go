package service

import (
	"log"
	"net/http"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/repository"
	"github.com/pidanou/librairian/internal/types"
)

type AttachmentService struct {
	AttachmentRepository repository.AttachmentRepository
	EmbeddingService     IEmbeddingService
	ImageCaptionService  IImageCaptionService
	ImageStorageService  IObjectStorageService
	BillingService       *BillingService
}

func NewAttachmentService(
	r repository.AttachmentRepository,
	e IEmbeddingService,
	s IImageCaptionService,
	i IObjectStorageService,
	b *BillingService,
) *AttachmentService {
	return &AttachmentService{AttachmentRepository: r, EmbeddingService: e, ImageCaptionService: s, ImageStorageService: i, BillingService: b}
}

func (s *AttachmentService) GetAttachmentByID(id *uuid.UUID) (*types.Attachment, error) {
	return s.AttachmentRepository.GetAttachmentByID(id)
}

func (s *AttachmentService) GetItemAttachments(itemID, userID *uuid.UUID) ([]types.Attachment, error) {
	attachments, err := s.AttachmentRepository.GetItemAttachments(itemID)
	if err != nil {
		return nil, err
	}
	n := 0
	for _, attachment := range attachments {
		if attachment.UserHasAccess(userID) {
			attachments[n] = attachment
			n++
		}
	}
	attachments = attachments[:n]

	return attachments, nil
}

func (s *AttachmentService) AddAttachments(attachments []types.Attachment, userID *uuid.UUID) []types.Attachment {
	n := 0
	for _, attachment := range attachments {
		if attachment.UserHasAccess(userID) {
			attachments[n] = attachment
			n++
		}
	}
	attachments = attachments[:n]
	for i, attachment := range attachments {
		if attachment.Path == "" {
			continue
		}
		image, err := s.ImageStorageService.GetImage("attachments", attachment.Path)
		if err != nil {
			log.Println(err)
			continue
		}

		captions, _ := s.ImageCaptionService.CreateCaption(image)
		attachment.Captions = captions

		captionsEmbedding, _ := s.EmbeddingService.CreateEmbedding(captions)
		attachment.CaptionsEmbeddings = captionsEmbedding

		attachments[i] = attachment
	}

	return s.AttachmentRepository.AddAttachments(attachments)
}

func (s *AttachmentService) DeleteAttachmentByID(attachmentID, userID *uuid.UUID) error {
	attachment, err := s.GetAttachmentByID(attachmentID)
	if err != nil {
		return err
	}
	if !attachment.UserHasAccess(userID) {
		return echo.NewHTTPError(http.StatusUnauthorized)
	}
	return s.AttachmentRepository.DeleteAttachmentByID(attachmentID)
}
