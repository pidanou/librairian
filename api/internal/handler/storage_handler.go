package handler

import (
	"log"
	"net/http"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/types"
)

func (h *Handler) GetStorageByID(c echo.Context) error {

	userID := getUserIDFromJWT(c)
	id := uuid.MustParse(c.Param("id"))

	storage, err := h.ArchiveService.GetStorageByID(&id)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot get storage")
	}

	if !UserHasAccess(storage, userID) {
		return echo.NewHTTPError(http.StatusForbidden)
	}

	return c.JSON(http.StatusOK, storage)
}

func (h *Handler) GetStorage(c echo.Context) error {

	userID := getUserIDFromJWT(c)

	storages, err := h.ArchiveService.GetStorageByUserID(userID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot get storage")
	}

	return c.JSON(http.StatusOK, storages)
}

func (h *Handler) PostStorage(c echo.Context) error {
	userID := getUserIDFromJWT(c)

	storage := &types.Storage{}

	err := c.Bind(storage)
	if err != nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid storage")
	}

	storage.UserID = userID
	storage, err = h.ArchiveService.AddStorage(storage)
	if err != nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot add storage")
	}

	return c.JSON(http.StatusCreated, storage)
}

func (h *Handler) PutStorage(c echo.Context) error {
	userID := getUserIDFromJWT(c)

	storage := &types.Storage{}

	err := c.Bind(storage)
	if err != nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid storage")
	}

	if !storage.UserHasAccess(userID) {
		return echo.NewHTTPError(http.StatusForbidden)
	}

	storage, err = h.ArchiveService.EditStorage(storage)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot edit storage")
	}

	return c.JSON(http.StatusOK, storage)
}

func (h *Handler) DeleteStorage(c echo.Context) error {
	userID := getUserIDFromJWT(c)

	storageID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	storage, err := h.ArchiveService.GetStorageByID(&storageID)
	if err != nil || storage == nil {
		return echo.NewHTTPError(http.StatusNotFound, "Storage not found")
	}
	if !storage.UserHasAccess(userID) {
		return echo.NewHTTPError(http.StatusForbidden)
	}

	err = h.ArchiveService.DeleteStorageByID(&storageID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot delete storage")
	}

	return c.NoContent(http.StatusOK)
}
