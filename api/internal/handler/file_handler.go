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

func (h *Handler) PostFiles(c echo.Context) error {
	var files = &[]types.File{}
	c.Bind(files)
	fmt.Println(files)

	userID := getUserIDFromJWT(c)

	success := []types.File{}
	errors := []types.File{}

	for _, file := range *files {
		if file.Summary == nil {
			file.Summary = &types.Summary{}
		}
		if file.Description == nil {
			file.Description = &types.Description{}
		}

		cleanedStorageLocation := []types.StorageLocation{}
		for _, sl := range file.StorageLocation {
			storage, err := h.ArchiveService.GetStorageByID(sl.StorageID)
			if err != nil {
				log.Println("Cannot get storage: ", err)
				continue
			}
			if !UserHasAccess(storage, userID) {
				continue
			}
			sl.UserID = userID
			cleanedStorageLocation = append(cleanedStorageLocation, sl)
		}

		if len(cleanedStorageLocation) == 0 {
			log.Println("No storage location")
			errors = append(errors, file)
			continue
		}

		file.StorageLocation = cleanedStorageLocation

		file.Summary.UserID = userID
		summaryEmbedding, err := h.EmbeddingService.CreateEmbedding(file.Summary.Data)
		if err != nil {
			log.Println("Cannot create summary embedding: ", err)
			errors = append(errors, file)
			continue
		}
		file.Summary.Embedding = summaryEmbedding

		file.Description.UserID = userID
		descriptionEmbedding, err := h.EmbeddingService.CreateEmbedding(file.Description.Data)
		if err != nil {
			log.Println("Cannot create description embedding: ", err)
			errors = append(errors, file)
			continue
		}
		file.Description.Embedding = descriptionEmbedding

		tfile, err := h.ArchiveService.AddFile(&file)
		if err != nil {
			log.Println("Cannot add file: ", err)
			errors = append(errors, file)
			continue
		}

		success = append(success, *tfile)
	}
	return c.JSON(http.StatusCreated, map[string]interface{}{"successes": success, "errors": errors})
}

func (h *Handler) GetFileById(c echo.Context) error {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	userID := getUserIDFromJWT(c)

	file, err := h.ArchiveService.GetFileById(&id)
	if err != nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot get file")
	}

	if !UserHasAccess(file, userID) {
		return c.NoContent(http.StatusUnauthorized)
	}

	return c.JSON(http.StatusOK, file)
}

func (h *Handler) DeleteFile(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	file, err := h.ArchiveService.GetFileById(&id)
	if err != nil || file == nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot delete file: file does not exist")
	}

	if !UserHasAccess(file, userID) {
		return c.NoContent(http.StatusUnauthorized)
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

	userID := getUserIDFromJWT(c)
	file, err := h.ArchiveService.GetFileById(file.ID)
	if err != nil || file == nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot edit file: file does not exist")
	}

	if !UserHasAccess(file, userID) {
		return c.NoContent(http.StatusUnauthorized)
	}

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

	id := uuid.MustParse(c.Param("id"))
	if &id != file.ID {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid or missing ID")
	}

	userID := getUserIDFromJWT(c)
	if !UserHasAccess(file, userID) {
		return c.NoContent(http.StatusUnauthorized)
	}

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
		if UserHasAccess(file, &userID) {
			matches[i].File = file
		}
	}

	return c.JSON(http.StatusOK, matches)
}
