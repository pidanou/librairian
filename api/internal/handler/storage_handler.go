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

	storage, err := h.StorageService.GetStorageByID(&id, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); ok {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot get storage")
		}
		log.Println(err)
		return echo.NewHTTPError(http.StatusInternalServerError)
	}

	return c.JSON(http.StatusOK, storage)
}

func (h *Handler) GetStoragesByUserID(c echo.Context) error {

	userID := getUserIDFromJWT(c)

	storages, err := h.StorageService.GetStorageByUserID(userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); ok {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot get storage")
		}
		log.Println(err)
		return echo.NewHTTPError(http.StatusInternalServerError)
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
	storage, err = h.StorageService.AddStorage(storage)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); ok {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot add storage")
		}
		log.Println(err)
		return echo.NewHTTPError(http.StatusInternalServerError)
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

	storage, err = h.StorageService.EditStorage(storage, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); ok {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot edit storage")
		}
		log.Println(err)
		return echo.NewHTTPError(http.StatusInternalServerError)
	}

	return c.JSON(http.StatusOK, storage)
}

func (h *Handler) DeleteStorage(c echo.Context) error {
	userID := getUserIDFromJWT(c)

	storageID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	err = h.StorageService.DeleteStorageByID(&storageID, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); ok {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot delete storage")
		}
		log.Println(err)
		return echo.NewHTTPError(http.StatusInternalServerError)
	}

	return c.NoContent(http.StatusOK)
}
