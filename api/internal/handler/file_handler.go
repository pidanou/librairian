package handler

import (
	"log"
	"net/http"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/service"
	"github.com/pidanou/librairian/internal/types"
)

type Handler struct {
	ArchiveService    *service.ArchiveService
	EmbeddingService  *service.EmbeddingService
	SimilarityService *service.SimilarityService
}

func New(fileService *service.ArchiveService, embeddingService *service.EmbeddingService, similarityService *service.SimilarityService) *Handler {
	return &Handler{
		ArchiveService:    fileService,
		EmbeddingService:  embeddingService,
		SimilarityService: similarityService,
	}
}

func (h *Handler) PostFile(c echo.Context) error {
	var file types.File
	c.Bind(&file)

	summaryEmbedding, err := h.EmbeddingService.CreateEmbedding(file.Summary.Data)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}

	descriptionEmbedding, err := h.EmbeddingService.CreateEmbedding(file.Description.Data)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}

	file.Summary.Embedding = summaryEmbedding
	file.Description.Embedding = descriptionEmbedding

	err = h.ArchiveService.AddFile(&file)
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot add file")
	}

	return c.String(200, "Starting Analysis")
}

func (h *Handler) GetFileById(c echo.Context) error {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	file, err := h.ArchiveService.GetFileById(id)
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot get file")
	}

	return c.JSON(http.StatusOK, file)
}

func (h *Handler) GetMatches(c echo.Context) error {
	type request struct {
		Search string `query:"search"`
	}

	req := request{}
	err := c.Bind(&req)
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest)
	}

	if req.Search == "" {
		return c.JSON(http.StatusOK, []types.File{})
	}

	embedding, err := h.EmbeddingService.CreateEmbedding(req.Search)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}

	testId, _ := uuid.Parse("817025ca-b878-45a7-ab3d-9833a9f5c8fa")

	matches, err := h.SimilarityService.Find(embedding, 0.5, 3, testId)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}

	for i, match := range matches {
		file, err := h.ArchiveService.GetFileById(match.FileID)
		if err != nil {
			log.Printf("Cannot get file %s: %s", match.FileID, err)
			continue
		}
		matches[i].File = file
	}

	return c.JSON(http.StatusOK, matches)
}
