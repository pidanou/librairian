package handler

import (
	"log"
	"net/http"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/types"
)

func (h *Handler) GetItemAttachments(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	itemID := uuid.MustParse(c.Param("id"))
	attachments, err := h.AttachmentService.GetItemAttachments(&itemID, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); ok {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot get attachments")
		}
		log.Println(err)
		return echo.NewHTTPError(http.StatusInternalServerError)
	}
	return c.JSON(http.StatusOK, attachments)
}

func (h *Handler) PostAttachments(c echo.Context) error {
	attachments := []types.Attachment{}
	c.Bind(&attachments)
	userID := getUserIDFromJWT(c)
	attachments, err := h.AttachmentService.AddAttachments(attachments, userID)
	if err != nil {
		log.Println(err)
		if httpErr, ok := err.(*echo.HTTPError); ok {
			return echo.NewHTTPError(httpErr.Code, "Cannot add attachments")
		}
		return echo.NewHTTPError(http.StatusInternalServerError)
	}
	return c.JSON(http.StatusOK, attachments)
}

func (h *Handler) DeleteAttachmentByID(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	id := uuid.MustParse(c.Param("id"))
	err := h.AttachmentService.DeleteAttachmentByID(&id, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); ok {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot delete attachment")
		}
		log.Println(err)
		return echo.NewHTTPError(http.StatusInternalServerError)
	}
	return c.JSON(http.StatusOK, nil)
}
