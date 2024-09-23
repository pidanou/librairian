package service

import (
	"context"
	"fmt"
	"log"

	"github.com/pgvector/pgvector-go"
	"github.com/pkoukk/tiktoken-go"
	"github.com/sashabaranov/go-openai"
)

type IEmbeddingService interface {
	CountTokens(text string) int
	CreateEmbedding(text string) (*pgvector.Vector, error)
}

type EmbeddingService struct {
	Client *openai.Client
	Model  string
}

func NewEmbeddingService(token string, model string) *EmbeddingService {
	client := openai.NewClient(token)
	return &EmbeddingService{
		Client: client,
		Model:  model,
	}
}

func (r *EmbeddingService) CountTokens(text string) int {
	tkm, err := tiktoken.EncodingForModel(r.Model)
	if err != nil {
		err = fmt.Errorf(": %v", err)
		return 0
	}

	token := tkm.Encode(text, nil, nil)

	return len(token)
}

func (r *EmbeddingService) CreateEmbedding(text string) (*pgvector.Vector, error) {
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
