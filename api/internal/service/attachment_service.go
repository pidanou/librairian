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
	ImageArchiveService  IObjectArchiveService
	BillingService       *BillingService
}

func NewAttachmentService(
	r repository.AttachmentRepository,
	e IEmbeddingService,
	s IImageCaptionService,
	i IObjectArchiveService,
	b *BillingService,
) *AttachmentService {
	return &AttachmentService{AttachmentRepository: r, EmbeddingService: e, ImageCaptionService: s, ImageArchiveService: i, BillingService: b}
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

func (s *AttachmentService) AddAttachments(attachments []types.Attachment, userID *uuid.UUID) ([]types.Attachment, error) {
	totalStorage, err := s.BillingService.GetTotalStorageUsed(userID)
	if err != nil || totalStorage > 5368709120 {
		log.Println(err)
		return []types.Attachment{}, echo.NewHTTPError(http.StatusForbidden, "Out of storage")
	}
	attachmentsToAdd := []types.Attachment{}
	for _, attachment := range attachments {
		totalStorage += len(attachment.Bytes)
		if totalStorage > 5368709120 {
			totalStorage -= len(attachment.Bytes)
			continue
		}
		if attachment.UserHasAccess(userID) {
			attachment.Size = len(attachment.Bytes)
			attachmentsToAdd = append(attachmentsToAdd, attachment)
		}
	}
	for i, attachment := range attachmentsToAdd {
		err := s.ImageArchiveService.UploadImage("attachments", attachment.Path, attachment.Bytes)
		if err != nil {
			log.Println(err)
			continue
		}

		monthlyTokens, err := s.BillingService.GetUserMonthlyTokenUsage(userID)
		if monthlyTokens > 100000000 || err != nil {
			return nil, echo.NewHTTPError(http.StatusForbidden, "Out of credits")
		}
		// captions, _ := s.ImageCaptionService.CreateCaption(attachment.Bytes)
		// attachment.Captions = captions

		// captionsEmbedding, _ := s.EmbeddingService.CreateEmbedding(captions)
		// attachment.CaptionsEmbeddings = captionsEmbedding
		// tokens := s.EmbeddingService.CountTokens(captions)
		// err = s.BillingService.AddTokenUsage(tokens, userID)
		// if err != nil {
		// 	log.Println(err)
		// }
		// Set to 75000 (or cost of captions) when implemented
		err = s.BillingService.AddTokenUsage(0, userID)
		if err != nil {
			log.Println(err)
		}

		attachmentsToAdd[i] = attachment
	}

	return s.AttachmentRepository.AddAttachments(attachmentsToAdd)
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
