package repository

import (
	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
	"github.com/pidanou/librairian/internal/types"
)

type ArchiveRepository interface {
	AddFile(file *types.File) (*types.File, error)
	DeleteFile(id *uuid.UUID) error
	UpdateFile(file *types.File) (*types.File, error)
	GetFileByID(id *uuid.UUID) (*types.File, error)
	EditFileMetadata(file *types.File) (*types.File, error)
	GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error)
	GetStorageByID(id *uuid.UUID) (*types.Storage, error)
}

type EmbeddingRepository interface {
	CreateEmbedding(text string) (*pgvector.Vector, error)
}

type SimilarityRepository interface {
	Find(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedFile, error)
}

type AuthRepository interface {
	LoginWithPassword(email, password string) (*types.Session, error)
}
