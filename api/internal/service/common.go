package service

import (
	"github.com/google/uuid"
)

// Check struct against user ID
type ProtectedResource interface {
	UserHasAccess(userID *uuid.UUID) bool
}

func UserHasAccess(p ProtectedResource, userID *uuid.UUID) bool {
	return p.UserHasAccess(userID)
}
