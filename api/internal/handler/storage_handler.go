package handler

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

func (h *Handler) GetStorage(c echo.Context) error {

	userID := getUserIDFromJWT(c)

	storages, err := h.ArchiveService.GetStorageByUserID(userID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot get storage")
	}

	return c.JSON(http.StatusOK, storages)
}
