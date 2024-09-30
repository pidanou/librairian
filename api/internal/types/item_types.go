package types

import (
	"fmt"
	"log"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"github.com/pgvector/pgvector-go"
)

type ItemResponse struct {
	Base
	Name                  *string          `json:"name" db:"name"`
	Description           *string          `json:"description" db:"description"`
	DescriptionEmbeddings *pgvector.Vector `json:"-" db:"description_embeddings"`
	Locations             []Location       `json:"locations"`
	Attachments           pq.StringArray   `json:"attachments" db:"attachments"`
}

func (f *ItemResponse) UserHasAccess(userID *uuid.UUID) bool {
	if f == nil {
		log.Println("No item")
		return false
	}

	if f.UserID == nil {
		log.Println("Missing userID in item")
		return false
	}

	return *f.UserID == *userID
}

func ItemResponseFromItem(item *Item) ItemResponse {
	return ItemResponse{
		Base:                  item.Base,
		Name:                  item.Name,
		Description:           item.Description,
		DescriptionEmbeddings: item.DescriptionEmbeddings,

		Locations:   []Location{},
		Attachments: pq.StringArray{},
	}
}

type Item struct {
	Base
	Name                  *string          `json:"name" db:"name"`
	Description           *string          `json:"description" db:"description"`
	DescriptionEmbeddings *pgvector.Vector `json:"-" db:"description_embeddings"`
}

func ItemFromItemResponse(item *ItemResponse) Item {
	return Item{
		Base:                  item.Base,
		Name:                  item.Name,
		Description:           item.Description,
		DescriptionEmbeddings: item.DescriptionEmbeddings,
	}
}

func (i Item) String() string {
	noname := "nil"
	if i.Name == nil {
		i.Name = &noname
	}
	if i.Description == nil {
		i.Description = &noname
	}
	return fmt.Sprintf("Item{Name: %s, Description: %s}",
		*i.Name,
		*i.Description,
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

	return *f.UserID == *userID
}

type MatchedItem struct {
	ItemID     *uuid.UUID    `json:"-" db:"item_id"`
	Item       *ItemResponse `json:"item"`
	Similarity float32       `json:"similarity" db:"similarity"`
}
