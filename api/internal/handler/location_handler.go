package handler

import (
	"log"
	"net/http"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/types"
)

func (h *Handler) PostItemLocation(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	location := &types.Location{}
	c.Bind(location)

	id := uuid.MustParse(c.Param("id"))

	item, err := h.ArchiveService.AddItemLocation(&id, location, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); !ok {
			log.Println(err)
			return echo.NewHTTPError(http.StatusInternalServerError)
		} else {
			log.Println(httpErr.Message)
			return echo.NewHTTPError(httpErr.Code, "Cannot update item")
		}
	}

	return c.JSON(http.StatusOK, item)
}

func (h *Handler) DeleteItemLocation(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	id := uuid.MustParse(c.Param("id"))

	err := h.ArchiveService.DeleteItemLocation(&id, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); !ok {
			log.Println(err)
			return echo.NewHTTPError(http.StatusInternalServerError)
		} else {
			log.Println(httpErr.Message)
			return echo.NewHTTPError(httpErr.Code, "Cannot update item")
		}
	}

	return c.JSON(http.StatusOK, nil)
}
