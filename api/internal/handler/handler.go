package handler

import "github.com/pidanou/librairian/internal/service"

type Handler struct {
	ArchiveService    *service.ArchiveService
	AttachmentService *service.AttachmentService
}

func New(itemService *service.ArchiveService, attachmentService *service.AttachmentService,
) *Handler {
	return &Handler{
		ArchiveService:    itemService,
		AttachmentService: attachmentService,
	}
}
