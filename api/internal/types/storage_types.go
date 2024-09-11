package types

import (
	"github.com/google/uuid"
)

type Location struct {
	Base
	ItemID    *uuid.UUID `json:"item_id" db:"item_id"`
	Storage   *Storage   `json:"storage"`
	StorageID *uuid.UUID `json:"storage_id" db:"storage_id"`
	Location  string     `json:"location"`
}

func (sl *Location) UserHasAccess(userID *uuid.UUID) bool {
	if userID == nil || sl.UserID == nil {
		return false
	}
	return *sl.UserID == *userID
}

type Storage struct {
	Base
	Alias string `json:"alias" db:"alias"`
}

func (s *Storage) UserHasAccess(userID *uuid.UUID) bool {
	if userID == nil || s.UserID == nil {
		return false
	}
	return *s.UserID == *userID
}
