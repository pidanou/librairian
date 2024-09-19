package service

import (
	"github.com/google/uuid"
	"github.com/pidanou/librairian/internal/repository"
)

// Get user permissions
type Permissioner interface {
	GetUserTier(userID *uuid.UUID) (string, error)
	SetUserTier(userID *uuid.UUID, tier string) error
}

type PermissionService struct {
	PermissionRepository repository.PermissionRepository
}

func NewPermissionService(r repository.PermissionRepository) *PermissionService {
	return &PermissionService{PermissionRepository: r}
}

func (p *PermissionService) GetUserTier(userID *uuid.UUID) (string, error) {
	return p.PermissionRepository.GetUserTier(userID)
}

func (p *PermissionService) SetUserTier(userID *uuid.UUID, tier string) error {
	return p.PermissionRepository.SetUserTier(userID, tier)
}
