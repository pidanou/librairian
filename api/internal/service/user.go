package service

import (
	"github.com/google/uuid"
	"github.com/pidanou/librairian/internal/repository"
)

// Get user permissions
type Permissioner interface {
	GetUserTier(userID *uuid.UUID) (string, error)
	SetUserTier(userID *uuid.UUID, tier string) error
	UserIsPremium(userID *uuid.UUID) bool
}

type UserService struct {
	PermissionRepository repository.PermissionRepository
}

func NewUserService(r repository.PermissionRepository) *UserService {
	return &UserService{PermissionRepository: r}
}

func (p *UserService) GetUserTier(userID *uuid.UUID) (string, error) {
	return p.PermissionRepository.GetUserTier(userID)
}

func (p *UserService) UserIsPremium(userID *uuid.UUID) bool {
	return p.PermissionRepository.UserIsPremium(userID)
}

func (p *UserService) SetUserTier(userID *uuid.UUID, tier string) error {
	return p.PermissionRepository.SetUserTier(userID, tier)
}
