package handler

import (
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

type Handler struct {
}

func New() *Handler {
	return &Handler{}
}

func (h *Handler) PostDocument(c echo.Context) error {
	analyze, err := strconv.ParseBool(c.QueryParam("analyze"))
	if err != nil {
		return c.String(http.StatusBadRequest, "Error")
	}

	if !analyze {
		return c.String(200, "Hello World")
	}

	return c.String(200, "Starting Analysis")
}
