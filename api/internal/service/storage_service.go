package service

import (
	"log"
	"net/http"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/repository"
	"github.com/pidanou/librairian/internal/types"
)

type StorageService struct {
	repository.StorageRepository
}

func NewStorageService(r repository.StorageRepository) *StorageService {
	return &StorageService{StorageRepository: r}
}

func (s *StorageService) GetStorageByID(id, userID *uuid.UUID) (*types.Storage, error) {
	storage, err := s.StorageRepository.GetStorageByID(id)
	if err != nil {
		return nil, err
	}
	if !UserHasAccess(storage, userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}

	return storage, nil
}

func (s *StorageService) GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error) {
	return s.StorageRepository.GetStorageByUserID(userID)
}

func (s *StorageService) DeleteStorageByID(storageID, userID *uuid.UUID) error {
	storage, err := s.GetStorageByID(storageID, userID)
	if err != nil || storage == nil {
		return echo.NewHTTPError(http.StatusNotFound, "Storage not found")
	}
	if !storage.UserHasAccess(userID) {
		return echo.NewHTTPError(http.StatusUnauthorized)
	}

	return s.StorageRepository.DeleteStorageByID(storageID)
}

func (s *StorageService) AddStorage(storage *types.Storage) (*types.Storage, error) {
	return s.StorageRepository.AddStorage(storage)
}

func (s *StorageService) EditStorage(storage *types.Storage, userID *uuid.UUID) (*types.Storage, error) {
	if !storage.UserHasAccess(userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}

	return s.StorageRepository.EditStorage(storage)
}

func (s *StorageService) Clean(item *types.Item, userID *uuid.UUID) []types.Location {
	cleanedLocation := []types.Location{}
	if item.Locations == nil {
		item.Locations = []types.Location{}
	}
	for _, sl := range item.Locations {
		if sl.Storage == nil {
			continue
		}
		storage, err := s.GetStorageByID(sl.Storage.ID, userID)
		if err != nil {
			log.Println("Cannot get storage: ", err)
			continue
		}
		if !UserHasAccess(storage, userID) {
			continue
		}
		sl.UserID = userID
		cleanedLocation = append(cleanedLocation, sl)
	}
	return cleanedLocation
}
