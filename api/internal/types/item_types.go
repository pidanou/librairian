package types

import (
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
)

type Item struct {
	Base
	Name                 string            `json:"name" db:"name"`
	AnalysisDate         *time.Time        `json:"analysis_date" db:"analysis_date"`
	Description          string            `json:"description" db:"description"`
	DescriptionEmbedding *pgvector.Vector  `json:"-" db:"description_embedding"`
	StorageLocation      []StorageLocation `json:"storage_locations"`
}

func (f *Item) UserHasAccess(userID *uuid.UUID) bool {
	if f.UserID == nil {
		log.Println("Missing userID in item")
		return false
	}

	for _, sl := range f.StorageLocation {
		if !sl.UserHasAccess(userID) {
			log.Println("Unauthorized access to item")
			return false
		}
	}

	return *f.UserID == *userID
}

type MatchedItem struct {
	ItemID                *uuid.UUID `json:"-" db:"item_id"`
	Item                  *Item      `json:"item"`
	DescriptionSimilarity float32    `json:"description_similarity" db:"description_similarity"`
}
