package handler

import "github.com/pidanou/librairian/internal/service"

type Handler struct {
	ItemService       *service.ItemService
	StorageService    *service.StorageService
	AttachmentService *service.AttachmentService
}

func New(itemService *service.ItemService, storageService *service.StorageService, attachmentService *service.AttachmentService,
) *Handler {
	return &Handler{
		ItemService:       itemService,
		StorageService:    storageService,
		AttachmentService: attachmentService,
	}
}
