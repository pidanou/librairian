package service

import (
	"context"
	"log"

	"github.com/pgvector/pgvector-go"
	"github.com/sashabaranov/go-openai"
)

type Embedder interface {
	CreateEmbedding(text string) (*pgvector.Vector, error)
}

type OpenaiEmbeddingService struct {
	Client *openai.Client
	Model  string
}

func NewOpenaiEmbeddingService(token string, model string) *OpenaiEmbeddingService {
	client := openai.NewClient(token)
	return &OpenaiEmbeddingService{
		Client: client,
		Model:  model,
	}
}

func (r *OpenaiEmbeddingService) CreateEmbedding(text string) (*pgvector.Vector, error) {
	if text == "" {
		return nil, nil
	}
	queryReq := openai.EmbeddingRequest{
		Input: []string{text},
		Model: openai.SmallEmbedding3,
	}

	queryResponse, err := r.Client.CreateEmbeddings(context.Background(), queryReq)
	if err != nil {
		log.Println("Error creating query embedding:", err)
	}

	vector := pgvector.NewVector(queryResponse.Data[0].Embedding)

	return &vector, nil
}

// Store image and objects in S3 compatible storage
