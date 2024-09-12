package repository

import (
	"context"
	"log"

	"github.com/pgvector/pgvector-go"
	openai "github.com/sashabaranov/go-openai"
)

type OpenaiEmbeddingRepository struct {
	Client *openai.Client
	Model  string
}

func NewOpenaiEmbeddingRepository(token string, model string) *OpenaiEmbeddingRepository {
	client := openai.NewClient(token)
	return &OpenaiEmbeddingRepository{
		Client: client,
		Model:  model,
	}
}

func (r *OpenaiEmbeddingRepository) CreateEmbedding(text *string) (*pgvector.Vector, error) {
	textToEmbed := " "
	if text != nil {
		if *text != "" {
			textToEmbed = *text
		}
	}
	queryReq := openai.EmbeddingRequest{
		Input: []string{textToEmbed},
		Model: openai.SmallEmbedding3,
	}

	queryResponse, err := r.Client.CreateEmbeddings(context.Background(), queryReq)
	if err != nil {
		log.Println("Error creating query embedding:", err)
	}

	vector := pgvector.NewVector(queryResponse.Data[0].Embedding)

	return &vector, nil
}
