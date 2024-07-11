package types

import (
	"time"

	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
)

type File struct {
	Base
	Name            string            `json:"name" db:"name"`
	AnalysisDate    *time.Time        `json:"analysis_date" db:"analysis_date"`
	Summary         *Summary          `json:"summary"`
	Description     *Description      `json:"description"`
	StorageLocation []StorageLocation `json:"storage_locations"`
	Tags            StringArray       `json:"tags" db:"tags"`
	Size            int64             `json:"size" db:"size"`
	WordCount       int64             `json:"word_count" db:"word_count"`
}

type Summary struct {
	Base
	FileID    *uuid.UUID       `json:"file_id" db:"file_id"`
	Data      string           `json:"data" db:"data"`
	Embedding *pgvector.Vector `json:"-" db:"embedding"`
}

type Description struct {
	Base
	FileID    *uuid.UUID       `json:"file_id" db:"file_id"`
	Data      string           `json:"data" db:"data"`
	Embedding *pgvector.Vector `json:"-" db:"embedding"`
}

type MatchedFile struct {
	FileID                *uuid.UUID `json:"id" db:"file_id"`
	File                  *File      `json:"file"`
	SummarySimilarity     float32    `json:"summary_similarity" db:"summary_similarity"`
	DescriptionSimilarity float32    `json:"description_similarity" db:"description_similarity"`
}
