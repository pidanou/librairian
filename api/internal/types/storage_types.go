package types

import (
	"github.com/google/uuid"
)

type StorageLocation struct {
	Base
	ItemID    *uuid.UUID `json:"item_id" db:"item_id"`
	Storage   *Storage   `json:"storage"`
	StorageID *uuid.UUID `json:"storage_id" db:"storage_id"`
	Location  string     `json:"location"`
}

func (sl *StorageLocation) UserHasAccess(userID *uuid.UUID) bool {
	if userID == nil || sl.UserID == nil {
		return false
	}
	return *sl.UserID == *userID
}

type Storage struct {
	Base
	Type  PlatformType `json:"type" db:"type"`
	Alias string       `json:"alias" db:"alias"`
}

func (s *Storage) UserHasAccess(userID *uuid.UUID) bool {
	if userID == nil || s.UserID == nil {
		return false
	}
	return *s.UserID == *userID
}

type PlatformType string

const (
	Device   PlatformType = "Device"
	Physical PlatformType = "Physical Storage"
	Cloud    PlatformType = "Cloud"
)
