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
	AddItemLocation(location *types.Location) (*types.Item, error)
	DeleteItemLocation(id *uuid.UUID) error
	GetItemLocation(id *uuid.UUID) (*types.Location, error)
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
	AddAttachments(attachment []types.Attachment) ([]types.Attachment, error)
	DeleteAttachmentByID(*uuid.UUID) error
}

type EmbeddingRepository interface {
	CreateEmbedding(text *string) (*pgvector.Vector, error)
}

type SimilarityRepository interface {
	Find(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedItem, error)
}
