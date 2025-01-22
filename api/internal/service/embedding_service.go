package service

import (
	"encoding/json"
	"log"

	"github.com/pgvector/pgvector-go"
	"github.com/supabase-community/supabase-go"
)

type IEmbeddingService interface {
	// CountTokens(text string) int
	CreateEmbedding(text string) (*pgvector.Vector, error)
}

type EmbeddingService struct {
	Client *supabase.Client
	Model  string
}

func NewEmbeddingService(API_KEY, API_URL, model string) *EmbeddingService {
	client, err := supabase.NewClient(API_URL, API_KEY, &supabase.ClientOptions{})
	if err != nil {
		log.Panic("cannot initalize client", err)
	}
	return &EmbeddingService{
		Client: client,
		Model:  model,
	}
}

// func (r *EmbeddingService) CountTokens(text string) int {
// 	tkm, err := tiktoken.EncodingForModel(r.Model)
// 	if err != nil {
// 		err = fmt.Errorf(": %v", err)
// 		return 0
// 	}
//
// 	token := tkm.Encode(text, nil, nil)
//
// 	return len(token)
// }

func (r *EmbeddingService) CreateEmbedding(text string) (*pgvector.Vector, error) {
	type embeddingResponse struct {
		Embedding []float32 `json:"embedding"`
	}
	embeddings := embeddingResponse{}

	if text == "" {
		return nil, nil
	}

	queryResponse, err := r.Client.Functions.Invoke("generate-embeddings", map[string]interface{}{"input": text})
	if err != nil {
		log.Println("Error creating query embedding:", err)
		return nil, err
	}

	err = json.Unmarshal([]byte(queryResponse), &embeddings)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	vector := pgvector.NewVector(embeddings.Embedding)

	return &vector, nil
}
