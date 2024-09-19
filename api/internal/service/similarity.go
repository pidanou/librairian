package service

import (
	"fmt"
	"log"
	"sort"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/pgvector/pgvector-go"
	"github.com/pidanou/librairian/internal/types"
)

type SimilarityChecker interface {
	Find(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedItem, error)
}

type PgvectorSimilarityService struct {
	DB *sqlx.DB
}

func NewPgvectorSimilarityService(db *sqlx.DB) *PgvectorSimilarityService {
	return &PgvectorSimilarityService{DB: db}
}

func (r *PgvectorSimilarityService) Find(vector *pgvector.Vector, matchThreshold float32, matchCount int, UserID *uuid.UUID) ([]types.MatchedItem, error) {
	matches := []types.MatchedItem{}
	matchesByDescription := []types.MatchedItem{}
	matchesByCaptions := []types.MatchedItem{}
	query := `SELECT * FROM match_item_by_description($1, $2, $3, $4)`
	err := r.DB.Select(&matchesByDescription, query, vector, matchThreshold, matchCount, UserID)
	if err != nil {
		log.Printf("Error finding similar items %s", err)
		return nil, err
	}
	fmt.Println(matchesByDescription)

	query = `SELECT * FROM match_item_by_captions($1, $2, $3, $4)`
	err = r.DB.Select(&matchesByCaptions, query, vector, matchThreshold, matchCount, UserID)
	if err != nil {
		log.Printf("Error finding similar items %s", err)
		return nil, err
	}
	fmt.Println(matchesByCaptions)

	matches = append(matches, matchesByDescription...)
	matches = append(matches, matchesByCaptions...)

	sort.Slice(matches, func(i, j int) bool {
		return matches[i].Similarity > matches[j].Similarity
	})

	if matchCount < len(matches) {
		matches = matches[:matchCount]
	}

	fmt.Println(matches)

	return matches, nil
}
