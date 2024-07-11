package handler

import (
	"fmt"
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

	file.UserID = &userID
	file.Summary.UserID = &userID
	file.Description.UserID = &userID
	for i, sl := range file.StorageLocation {
		sl.UserID = &userID
		file.StorageLocation[i] = sl
	}

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

	file, err := h.ArchiveService.GetFileById(&id)
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot get file")
	}

	return c.JSON(http.StatusOK, file)
}

func (h *Handler) DeleteFile(c echo.Context) error {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	err = h.ArchiveService.DeleteFile(&id)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot delete file")
	}

	return c.NoContent(http.StatusOK)
}

func (h *Handler) PutFile(c echo.Context) error {
	var file = &types.File{}
	c.Bind(file)

	summaryEmbedding, err := h.EmbeddingService.CreateEmbedding(file.Summary.Data)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot create summary embedding")
	}
	descriptionEmbedding, err := h.EmbeddingService.CreateEmbedding(file.Description.Data)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot create description embedding")
	}
	file.Summary.Embedding = summaryEmbedding
	file.Description.Embedding = descriptionEmbedding
	fmt.Println(file.Summary.ID)

	file, err = h.ArchiveService.UpdateFile(file)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot update file")
	}

	return c.JSON(http.StatusOK, file)
}

func (h *Handler) PatchFileMetadata(c echo.Context) error {
	var file = &types.File{}
	c.Bind(file)

	// id := uuid.MustParse(c.Param("id"))

	file, err := h.ArchiveService.EditFileMetadata(file)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot update file")
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

	matches, err := h.SimilarityService.Find(embedding, 0.5, 3, &userID)
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
