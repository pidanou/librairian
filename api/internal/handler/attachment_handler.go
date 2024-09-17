package handler

import (
	"fmt"
	"net/http"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/types"
)

func (h *Handler) GetItemAttachments(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	itemID := uuid.MustParse(c.Param("id"))
	attachments, err := h.ArchiveService.GetItemAttachments(&itemID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot get attachments")
	}
	n := 0
	for _, attachment := range attachments {
		if attachment.UserHasAccess(userID) {
			attachments[n] = attachment
			n++
		}
	}
	attachments = attachments[:n]
	return c.JSON(http.StatusOK, attachments)
}

func (h *Handler) PostAttachments(c echo.Context) error {
	attachments := []types.Attachment{}
	c.Bind(&attachments)
	userID := getUserIDFromJWT(c)
	n := 0
	for _, attachment := range attachments {
		if attachment.UserHasAccess(userID) {
			fmt.Println(attachment.ItemID)
			attachments[n] = attachment
			n++
		}
	}
	attachments = attachments[:n]
	attachments = h.ArchiveService.AddAttachments(attachments)
	return c.JSON(http.StatusOK, attachments)
}

func (h *Handler) DeleteAttachmentByID(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	id := uuid.MustParse(c.Param("id"))
	fmt.Println(id)
	attachment, err := h.ArchiveService.GetAttachmentByID(&id)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot get attachment")
	}
	if attachment.UserHasAccess(userID) {
		err = h.ArchiveService.DeleteAttachmentByID(&id)
		if err != nil {
			return echo.NewHTTPError(http.StatusInternalServerError, "Cannot delete attachment")
		}
	}

	return c.JSON(http.StatusOK, nil)
}
