package repository

import (
	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
	"github.com/pidanou/librairian/internal/types"
)

type ArchiveRepository interface {
	AddItem(item *types.Item) (*types.Item, error)
	DeleteItem(id *uuid.UUID) error
	UpdateItem(item *types.Item) (*types.Item, error)
	GetItemByID(id *uuid.UUID) (*types.Item, error)
	EditItemMetadata(item *types.Item) (*types.Item, error)
	GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error)
	GetStorageByID(id *uuid.UUID) (*types.Storage, error)
	DeleteStorageByID(id *uuid.UUID) error
	EditStorage(storage *types.Storage) (*types.Storage, error)
	AddStorage(storage *types.Storage) (*types.Storage, error)
}

type EmbeddingRepository interface {
	CreateEmbedding(text string) (*pgvector.Vector, error)
}

type SimilarityRepository interface {
	Find(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedItem, error)
}

type AuthRepository interface {
	LoginWithPassword(email, password string) (*types.Session, error)
}
