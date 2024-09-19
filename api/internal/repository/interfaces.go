package repository

import (
	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
	"github.com/pidanou/librairian/internal/types"
)

type ItemRepository interface {
	AddItem(item *types.Item) (*types.Item, error)
	GetItems(userID *uuid.UUID, storageID *uuid.UUID, name string, page int, limit int, orderBy types.OrderBy) ([]types.Item, int, error)
	DeleteItem(id *uuid.UUID) error
	UpdateItem(item *types.Item) (*types.Item, error)
	GetItemByID(id *uuid.UUID) (*types.Item, error)
}

type StorageRepository interface {
	GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error)
	GetStorageByID(id *uuid.UUID) (*types.Storage, error)
	DeleteStorageByID(id *uuid.UUID) error
	EditStorage(storage *types.Storage) (*types.Storage, error)
	AddStorage(storage *types.Storage) (*types.Storage, error)
}

type AttachmentRepository interface {
	GetAttachmentByID(id *uuid.UUID) (*types.Attachment, error)
	GetItemAttachments(itemID *uuid.UUID) ([]types.Attachment, error)
	AddAttachments(attachment []types.Attachment) []types.Attachment
	DeleteAttachmentByID(*uuid.UUID) error
}

type EmbeddingRepository interface {
	CreateEmbedding(text *string) (*pgvector.Vector, error)
}

type SimilarityRepository interface {
	Find(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedItem, error)
}

type UsageRepository interface {
	AddUsage(usage *types.Usage) (*types.Usage, error)
	GetUsage(id *uuid.UUID) (*types.Usage, error)
	EditUsage(usage *types.Usage) (*types.Usage, error)
	GetUserUsage(userID *uuid.UUID) (*types.Usage, error)
	GetUserTier(userID *uuid.UUID) (string, error)
}

type PermissionRepository interface {
	GetUserTier(userID *uuid.UUID) (string, error)
	SetUserTier(userID *uuid.UUID, tier string) error
}
