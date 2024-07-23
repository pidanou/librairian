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

func (s *ArchiveService) DeleteItem(id *uuid.UUID) error {
	return s.ArchiveRepository.DeleteItem(id)
}

func (s *ArchiveService) UpdateItem(item *types.Item) (*types.Item, error) {
	return s.ArchiveRepository.UpdateItem(item)
}

func (s *ArchiveService) GetItemById(id *uuid.UUID) (*types.Item, error) {
	return s.ArchiveRepository.GetItemByID(id)
}

func (s *ArchiveService) EditItemMetadata(item *types.Item) (*types.Item, error) {
	return s.ArchiveRepository.EditItemMetadata(item)
}

func (s *ArchiveService) GetStorageByID(id *uuid.UUID) (*types.Storage, error) {
	return s.ArchiveRepository.GetStorageByID(id)
}

func (s *ArchiveService) GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error) {
	return s.ArchiveRepository.GetStorageByUserID(userID)
}
