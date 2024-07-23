package repository

import (
	"log"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/pgvector/pgvector-go"
	"github.com/pidanou/librairian/internal/types"
)

type PgvectorSimilarityRepository struct {
	DB *sqlx.DB
}

func NewPgvectorSimilarityRepository(db *sqlx.DB) *PgvectorSimilarityRepository {
	return &PgvectorSimilarityRepository{DB: db}
}

func (r *PgvectorSimilarityRepository) Find(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedItem, error) {
	matches := []types.MatchedItem{}
	query := `SELECT * FROM match_item($1, $2, $3, $4)`
	err := r.DB.Select(&matches, query, vector, matchThreshold, matchCount, UserID)
	if err != nil {
		log.Printf("Error finding similar items %s", err)
		return nil, err
	}

	return matches, nil
}
