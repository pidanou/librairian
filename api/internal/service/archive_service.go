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

func (s *ArchiveService) AddFile(file *types.File) (*uuid.UUID, error) {
	return s.ArchiveRepository.Add(file)
}

func (s *ArchiveService) GetFileById(id uuid.UUID) (*types.File, error) {
	return s.ArchiveRepository.GetFileByID(id)
}

func (s *ArchiveService) EditSummary(summary *types.Summary) error {
	return s.ArchiveRepository.EditSummary(summary)
}
