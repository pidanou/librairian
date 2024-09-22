package types

import (
	"fmt"
	"log"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"github.com/pgvector/pgvector-go"
)

type Item struct {
	Base
	Name                  string           `json:"name" db:"name"`
	Description           string           `json:"description" db:"description"`
	DescriptionEmbeddings *pgvector.Vector `json:"-" db:"description_embeddings"`
	Locations             []Location       `json:"locations"`
	Attachments           pq.StringArray   `json:"attachments" db:"attachments"`
}

func (i Item) String() string {
	return fmt.Sprintf("Item{Name: %s, Description: %s, Locations: %v, Attachments: %s}",
		i.Name,
		i.Description,
		i.Locations,
		i.Attachments,
	)
}

func (f *Item) UserHasAccess(userID *uuid.UUID) bool {
	if f == nil {
		log.Println("No item")
		return false
	}

	if f.UserID == nil {
		log.Println("Missing userID in item")
		return false
	}

	for _, sl := range f.Locations {
		if !sl.UserHasAccess(userID) {
			log.Println("Unauthorized access to item")
			return false
		}
	}

	return *f.UserID == *userID
}

type MatchedItem struct {
	ItemID     *uuid.UUID `json:"-" db:"item_id"`
	Item       *Item      `json:"item"`
	Similarity float32    `json:"similarity" db:"similarity"`
}
