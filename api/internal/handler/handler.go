package handler

import "github.com/pidanou/librairian/internal/service"

type Handler struct {
	ArchiveService    *service.ArchiveService
	EmbeddingService  *service.EmbeddingService
	SimilarityService *service.SimilarityService
}

func New(itemService *service.ArchiveService,
	embeddingService *service.EmbeddingService,
	similarityService *service.SimilarityService,
) *Handler {
	return &Handler{
		ArchiveService:    itemService,
		EmbeddingService:  embeddingService,
		SimilarityService: similarityService,
	}
}
