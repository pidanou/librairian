package handler

import (
	"log"
	"net/http"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/types"
)

func (h *Handler) PostFile(c echo.Context) error {
	token, ok := c.Get("user").(*jwt.Token)
	if !ok {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid token")
	}

	userID := uuid.MustParse(token.Claims.(jwt.MapClaims)["sub"].(string))

	var file types.File
	c.Bind(&file)

	file.UserID = userID
	file.Summary.UserID = userID
	file.Description.UserID = userID
	file.StorageLocation.UserID = userID

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

	id, err := h.ArchiveService.AddFile(&file)
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot add file")
	}

	return c.JSON(http.StatusCreated, map[string]interface{}{"message": map[string]interface{}{"created": id}})
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

	token, ok := c.Get("user").(*jwt.Token)
	if !ok {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid token")
	}

	userID := uuid.MustParse(token.Claims.(jwt.MapClaims)["sub"].(string))

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

	matches, err := h.SimilarityService.Find(embedding, 0.5, 3, userID)
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
