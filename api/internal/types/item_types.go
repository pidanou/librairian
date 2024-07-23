package types

import (
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
)

type Item struct {
	Base
	Name            string            `json:"name" db:"name"`
	IsDigital       bool              `json:"is_digital" db:"is_digital"`
	AnalysisDate    *time.Time        `json:"analysis_date" db:"analysis_date"`
	Description     *Description      `json:"description"`
	StorageLocation []StorageLocation `json:"storage_locations"`
}

type ItemType string

func (f *Item) UserHasAccess(userID *uuid.UUID) bool {
	if f.UserID == nil || f.Description.UserID == nil {
		log.Println("Missing userID in item")
		return false
	}

	for _, sl := range f.StorageLocation {
		if !sl.UserHasAccess(userID) {
			log.Println("Unauthorized access to storage location")
			return false
		}
	}

	return *f.UserID == *userID && f.Description.UserHasAccess(userID)
}

type Description struct {
	Base
	ItemID    *uuid.UUID       `json:"item_id" db:"item_id"`
	Data      string           `json:"data" db:"data"`
	Embedding *pgvector.Vector `json:"-" db:"embedding"`
}

func (d *Description) UserHasAccess(userID *uuid.UUID) bool {
	if d.UserID == nil || userID == nil {
		return false
	}
	return *d.UserID == *userID
}

type MatchedItem struct {
	ItemID                *uuid.UUID `json:"-" db:"item_id"`
	Item                  *Item      `json:"item"`
	DescriptionSimilarity float32    `json:"description_similarity" db:"description_similarity"`
}
