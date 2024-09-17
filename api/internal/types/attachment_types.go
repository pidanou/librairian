package types

import (
	"log"

	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
)

type Attachment struct {
	Base
	ItemID           *uuid.UUID       `json:"item_id" db:"item_id"`
	Path             *string          `json:"path" db:"path"`
	Labels           *string          `json:"-" db:"labels"`
	LabelsEmbeddings *pgvector.Vector `json:"-" db:"labels_embeddings"`
}

func (a *Attachment) UserHasAccess(userID *uuid.UUID) bool {
	if a.UserID == nil {
		log.Println("Missing userID in item")
		return false
	}

	return *a.UserID == *userID
}
