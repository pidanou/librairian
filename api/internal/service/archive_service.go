package service

import (
	"github.com/google/uuid"
	"github.com/pidanou/librairian/internal/repository"
	"github.com/pidanou/librairian/internal/types"
)

type ArchiveService struct {
	ArchiveRepository repository.ArchiveRepository
}

func NewArchiveService(r repository.ArchiveRepository) *ArchiveService {
	return &ArchiveService{ArchiveRepository: r}
}

func (s *ArchiveService) AddItem(item *types.Item) (*types.Item, error) {
	return s.ArchiveRepository.AddItem(item)
}

func (s *ArchiveService) GetItems(userID *uuid.UUID, storageID *uuid.UUID, name string, page int, limit int, order types.OrderBy) ([]types.Item, int, error) {
	return s.ArchiveRepository.GetItems(userID, storageID, name, page, limit, order)
}

func (s *ArchiveService) DeleteItem(id *uuid.UUID) error {
	return s.ArchiveRepository.DeleteItem(id)
}

func (s *ArchiveService) UpdateItem(item *types.Item) (*types.Item, error) {
	return s.ArchiveRepository.UpdateItem(item)
}

func (s *ArchiveService) GetItemByID(id *uuid.UUID) (*types.Item, error) {
	return s.ArchiveRepository.GetItemByID(id)
}

func (s *ArchiveService) GetStorageByID(id *uuid.UUID) (*types.Storage, error) {
	return s.ArchiveRepository.GetStorageByID(id)
}

func (s *ArchiveService) GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error) {
	return s.ArchiveRepository.GetStorageByUserID(userID)
}

func (s *ArchiveService) DeleteStorageByID(id *uuid.UUID) error {
	return s.ArchiveRepository.DeleteStorageByID(id)
}

func (s *ArchiveService) AddStorage(storage *types.Storage) (*types.Storage, error) {
	return s.ArchiveRepository.AddStorage(storage)
}

func (s *ArchiveService) EditStorage(storage *types.Storage) (*types.Storage, error) {
	return s.ArchiveRepository.EditStorage(storage)
}

func (s *ArchiveService) GetAttachmentByID(id *uuid.UUID) (*types.Attachment, error) {
	return s.ArchiveRepository.GetAttachmentByID(id)
}

func (s *ArchiveService) GetItemAttachments(itemID *uuid.UUID) ([]types.Attachment, error) {
	return s.ArchiveRepository.GetItemAttachments(itemID)
}

func (s *ArchiveService) AddAttachments(attachments []types.Attachment) []types.Attachment {
	return s.ArchiveRepository.AddAttachments(attachments)
}

func (s *ArchiveService) DeleteAttachmentByID(attachmentID *uuid.UUID) error {
	return s.ArchiveRepository.DeleteAttachmentByID(attachmentID)
}
