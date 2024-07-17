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

func (s *ArchiveService) AddFile(file *types.File) (*types.File, error) {
	return s.ArchiveRepository.AddFile(file)
}

func (s *ArchiveService) DeleteFile(id *uuid.UUID) error {
	return s.ArchiveRepository.DeleteFile(id)
}

func (s *ArchiveService) UpdateFile(file *types.File) (*types.File, error) {
	return s.ArchiveRepository.UpdateFile(file)
}

func (s *ArchiveService) GetFileById(id *uuid.UUID) (*types.File, error) {
	return s.ArchiveRepository.GetFileByID(id)
}

func (s *ArchiveService) EditFileMetadata(file *types.File) (*types.File, error) {
	return s.ArchiveRepository.EditFileMetadata(file)
}

func (s *ArchiveService) EditFileSummary(summary *types.Summary) error {
	return s.ArchiveRepository.EditFileSummary(summary)
}

func (s *ArchiveService) GetStorageByID(id *uuid.UUID) (*types.Storage, error) {
	return s.ArchiveRepository.GetStorageByID(id)
}

func (s *ArchiveService) GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error) {
	return s.ArchiveRepository.GetStorageByUserID(userID)
}
