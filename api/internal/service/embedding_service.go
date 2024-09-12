package service

import (
	"github.com/pgvector/pgvector-go"
	"github.com/pidanou/librairian/internal/repository"
)

type EmbeddingService struct {
	EmbeddingRepository repository.EmbeddingRepository
}

func NewEmbeddingService(repo repository.EmbeddingRepository) *EmbeddingService {
	return &EmbeddingService{EmbeddingRepository: repo}
}

func (s *EmbeddingService) CreateEmbedding(text *string) (*pgvector.Vector, error) {
	return s.EmbeddingRepository.CreateEmbedding(text)
}
