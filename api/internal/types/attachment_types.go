package types

import (
	"log"

	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
)

type Attachment struct {
	Base
	ItemID             *uuid.UUID       `json:"item_id" db:"item_id"`
	Path               string           `json:"path" db:"path"`
	Captions           string           `json:"captions" db:"captions"`
	CaptionsEmbeddings *pgvector.Vector `json:"-" db:"captions_embeddings"`
	Bytes              []byte           `json:"bytes"`
	Size               int              `json:"-" db:"size"`
}

func (a *Attachment) UserHasAccess(userID *uuid.UUID) bool {
	if a.UserID == nil {
		log.Println("Missing userID in item")
		return false
	}

	return *a.UserID == *userID
}
