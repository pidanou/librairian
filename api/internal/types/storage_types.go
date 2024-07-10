package types

import "github.com/google/uuid"

type StorageLocation struct {
	Base
	FileID    uuid.UUID `json:"-" db:"file_id"`
	Storage   *Storage  `json:"storage"`
	StorageID uuid.UUID `json:"storage_id" db:"storage_id"`
	Location  string    `json:"location"`
}

type Storage struct {
	Base
	Name     PlatformName `json:"name" db:"name"`
	Alias    string       `json:"alias" db:"alias"`
	Username string       `json:"username" db:"username"`
}

type PlatformName string

const (
	LocalStorageName       PlatformName = "Local"
	GoogleDriveStorageName PlatformName = "Google Drive"
	OneDriveStorageName    PlatformName = "OneDrive"
)
