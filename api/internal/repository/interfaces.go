package repository

import (
	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
	"github.com/pidanou/librairian/internal/types"
)

type ArchiveRepository interface {
	Add(file *types.File) error
	GetFileByID(id uuid.UUID) (*types.File, error)
	EditSummary(summary *types.Summary) error
}

type EmbeddingRepository interface {
	CreateEmbedding(text string) (*pgvector.Vector, error)
}

type SimilarityRepository interface {
	Find(vector *pgvector.Vector, matchThreshold float32, matchCount int, ownerID uuid.UUID) ([]types.MatchedFile, error)
}
