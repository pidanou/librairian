package service

import (
	"log"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/pgvector/pgvector-go"
	"github.com/pidanou/librairian/internal/types"
)

type SimilarityService struct {
	DB *sqlx.DB
}

func NewSimilarityService(db *sqlx.DB) *SimilarityService {
	return &SimilarityService{DB: db}
}

func (r *SimilarityService) FindByDescription(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedItem, error) {
	matchesByDescription := []types.MatchedItem{}
	matchesByCaptions := []types.MatchedItem{}
	query := `SELECT * FROM match_item_by_description($1, $2, $3, $4)`
	err := r.DB.Select(&matchesByDescription, query, vector, matchThreshold, matchCount, UserID)
	if err != nil {
		log.Printf("Error finding similar items %s", err)
		return nil, err
	}

	query = `SELECT * FROM match_item_by_captions($1, $2, $3, $4)`
	err = r.DB.Select(&matchesByCaptions, query, vector, matchThreshold, matchCount, UserID)
	if err != nil {
		log.Printf("Error finding similar items %s", err)
		return nil, err
	}

	return matchesByDescription, nil
}

func (r *SimilarityService) FindByCaptions(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedItem, error) {
	matchesByDescription := []types.MatchedItem{}
	matchesByCaptions := []types.MatchedItem{}
	query := `SELECT * FROM match_item_by_description($1, $2, $3, $4)`
	err := r.DB.Select(&matchesByDescription, query, vector, matchThreshold, matchCount, UserID)
	if err != nil {
		log.Printf("Error finding similar items %s", err)
		return nil, err
	}

	query = `SELECT * FROM match_item_by_captions($1, $2, $3, $4)`
	err = r.DB.Select(&matchesByCaptions, query, vector, matchThreshold, matchCount, UserID)
	if err != nil {
		log.Printf("Error finding similar items %s", err)
		return nil, err
	}

	return matchesByCaptions, nil
}
