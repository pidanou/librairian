package service

import (
	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
	"github.com/pidanou/librairian/internal/repository"
	"github.com/pidanou/librairian/internal/types"
)

type SimilarityService struct {
	SimilarityRepository repository.SimilarityRepository
}

func NewSimilarityService(repo repository.SimilarityRepository) *SimilarityService {
	return &SimilarityService{SimilarityRepository: repo}
}

func (s *SimilarityService) Find(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedItem, error) {
	return s.SimilarityRepository.Find(vector, matchThreshold, matchCount, UserID)
}
