package types

import (
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
)

type File struct {
	Base
	Name            string            `json:"name" db:"name"`
	AnalysisDate    *time.Time        `json:"analysis_date" db:"analysis_date"`
	Description     *Description      `json:"description"`
	StorageLocation []StorageLocation `json:"storage_locations"`
	Tags            StringArray       `json:"tags" db:"tags"`
	Size            int64             `json:"size" db:"size"`
	WordCount       int64             `json:"word_count" db:"word_count"`
}

func (f *File) UserHasAccess(userID *uuid.UUID) bool {
	if f.UserID == nil || f.Description.UserID == nil {
		log.Println("Missing userID in file")
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
	FileID    *uuid.UUID       `json:"file_id" db:"file_id"`
	Data      string           `json:"data" db:"data"`
	Embedding *pgvector.Vector `json:"-" db:"embedding"`
}

func (d *Description) UserHasAccess(userID *uuid.UUID) bool {
	if d.UserID == nil || userID == nil {
		return false
	}
	return *d.UserID == *userID
}

type MatchedFile struct {
	FileID                *uuid.UUID `json:"id" db:"file_id"`
	File                  *File      `json:"file"`
	SummarySimilarity     float32    `json:"summary_similarity" db:"summary_similarity"`
	DescriptionSimilarity float32    `json:"description_similarity" db:"description_similarity"`
}
