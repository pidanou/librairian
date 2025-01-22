package service

import (
	"log"
	"net/http"
	"sort"

	"dario.cat/mergo"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/repository"
	"github.com/pidanou/librairian/internal/types"
)

type ArchiveService struct {
	ArchiveRepository repository.ArchiveRepository
	EmbeddingService  IEmbeddingService
	SimilarityService *SimilarityService
	BillingService    *BillingService
}

func NewArchiveService(r repository.ArchiveRepository, e IEmbeddingService, s *SimilarityService, b *BillingService) *ArchiveService {
	return &ArchiveService{ArchiveRepository: r, EmbeddingService: e, SimilarityService: s, BillingService: b}
}

func (s *ArchiveService) AddItem(item *types.Item) (*types.Item, error) {
	return s.ArchiveRepository.AddItem(item)
}

func (s *ArchiveService) GetItems(userID *uuid.UUID, storageID *uuid.UUID, name string, page int, limit int, order types.OrderBy) ([]types.Item, int, error) {
	return s.ArchiveRepository.GetItems(userID, storageID, name, page, limit, order)
}

func (s *ArchiveService) DeleteItem(id, userID *uuid.UUID) error {
	item, err := s.GetItemByID(id, userID)
	if err != nil {
		return err
	}
	if item == nil {
		return nil
	}
	if !UserHasAccess(item, userID) {
		return echo.NewHTTPError(http.StatusUnauthorized)
	}
	return s.ArchiveRepository.DeleteItem(id)
}

func (s *ArchiveService) UpdateItem(item *types.Item, userID *uuid.UUID) (*types.Item, error) {
	itemCheck, err := s.GetItemByID(item.ID, userID)
	if err != nil || itemCheck == nil {
		log.Println(err)
		return nil, echo.NewHTTPError(http.StatusBadRequest, "Cannot edit item")
	}

	if !UserHasAccess(itemCheck, userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}

	monthlyTokens, err := s.BillingService.GetUserMonthlyTokenUsage(userID)
	if monthlyTokens > 100000000 || err != nil {
		return nil, echo.NewHTTPError(http.StatusForbidden, "Out of credits")
	}

	if item.Description != nil && item.Description != itemCheck.Description {
		descriptionEmbedding, err := s.EmbeddingService.CreateEmbedding(*item.Description)
		if err != nil {
			return nil, echo.NewHTTPError(http.StatusInternalServerError, "Cannot create description embedding")
		}
		item.DescriptionEmbeddings = descriptionEmbedding
		// descriptionToken := s.EmbeddingService.CountTokens(*item.Description)
		// err = s.BillingService.AddTokenUsage(descriptionToken, userID)
		// if err != nil {
		// 	log.Println(err)
		// }
	}

	return s.ArchiveRepository.UpdateItem(item)
}

func (s *ArchiveService) PartialUpdateItem(itemID *uuid.UUID, newItem *types.Item, userID *uuid.UUID) (*types.Item, error) {
	oldItem, err := s.GetItemByID(itemID, userID)
	if httpErr, ok := err.(*echo.HTTPError); ok {
		return nil, echo.NewHTTPError(httpErr.Code, "Cannot get item")
	}
	if err != nil || oldItem == nil {
		return nil, echo.NewHTTPError(http.StatusBadRequest, "Cannot edit item")
	}

	monthlyTokens, err := s.BillingService.GetUserMonthlyTokenUsage(userID)
	if monthlyTokens > 100000000 || err != nil {
		return nil, echo.NewHTTPError(http.StatusForbidden, "Out of credits")
	}

	if newItem.Description != nil && newItem.Description != oldItem.Description {
		descriptionEmbedding, err := s.EmbeddingService.CreateEmbedding(*newItem.Description)
		if err != nil {
			return nil, echo.NewHTTPError(http.StatusInternalServerError, "Cannot create description embedding")
		}
		newItem.DescriptionEmbeddings = descriptionEmbedding
		// descriptionToken := s.EmbeddingService.CountTokens(*newItem.Description)
		// err = s.BillingService.AddTokenUsage(descriptionToken, userID)
		// if err != nil {
		// 	log.Println(err)
		// 	return nil, err
		// }
	}

	mergo.Merge(newItem, types.ItemFromItemResponse(oldItem))

	if !UserHasAccess(newItem, userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}

	return s.ArchiveRepository.UpdateItem(newItem)
}

func (s *ArchiveService) GetItemByID(id *uuid.UUID, userID *uuid.UUID) (*types.ItemResponse, error) {
	var response types.ItemResponse
	item, err := s.ArchiveRepository.GetItemByID(id)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	if !item.UserHasAccess(userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}

	locations, err := s.ArchiveRepository.GetItemLocations(id)

	response = types.ItemResponseFromItem(item)
	response.Locations = locations

	for i, location := range locations {
		storage, err := s.GetStorageByID(location.StorageID, userID)
		if err != nil {
			continue
		}
		locations[i].Storage = storage
	}
	return &response, nil
}

func (s *ArchiveService) AddItemLocation(itemID *uuid.UUID, location *types.Location, userID *uuid.UUID) (*types.ItemResponse, error) {
	if !location.UserHasAccess(userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}
	_, err := s.ArchiveRepository.AddItemLocation(location)
	if err != nil {
		return nil, err
	}

	itemResponse, err := s.GetItemByID(itemID, userID)
	if err != nil {
		return nil, err
	}

	return itemResponse, nil
}

func (s *ArchiveService) DeleteItemLocation(id *uuid.UUID, userID *uuid.UUID) error {
	location, _ := s.ArchiveRepository.GetLocation(id)
	if !location.UserHasAccess(userID) {
		return echo.NewHTTPError(http.StatusUnauthorized)
	}
	return s.ArchiveRepository.DeleteItemLocation(id)
}

func (s *ArchiveService) FindMatches(search string, threshold float32, maxResults int, userID *uuid.UUID) []types.MatchedItem {
	monthlyTokens, err := s.BillingService.GetUserMonthlyTokenUsage(userID)
	if monthlyTokens > 100000000 || err != nil {
		return []types.MatchedItem{}
	}

	embedding, err := s.EmbeddingService.CreateEmbedding(search)
	if err != nil {
		return []types.MatchedItem{}
	}
	// searchToken := s.EmbeddingService.CountTokens(search)
	// err = s.BillingService.AddTokenUsage(searchToken, userID)
	// if err != nil {
	// 	log.Println(err)
	// 	return []types.MatchedItem{}
	// }

	matches := []types.MatchedItem{}
	matchesByCaptions := []types.MatchedItem{}
	matchesByDescription := []types.MatchedItem{}

	matchesByDescription, err = s.SimilarityService.FindByDescription(embedding, threshold, maxResults, userID)
	if err != nil || matchesByDescription == nil {
		matchesByDescription = []types.MatchedItem{}
	}

	matchesByCaptions, err = s.SimilarityService.FindByCaptions(embedding, threshold, maxResults, userID)
	if err != nil || matchesByCaptions == nil {
		matchesByDescription = []types.MatchedItem{}
	}

	matches = append(matches, matchesByDescription...)
	matches = append(matches, matchesByCaptions...)

	if len(matches) == 0 {
		return matches
	}

	seen := make(map[string]bool)
	var deduped []types.MatchedItem

	for _, match := range matches {
		if !seen[match.ItemID.String()] {
			deduped = append(deduped, match)
			seen[match.ItemID.String()] = true
		}
	}

	sort.Slice(deduped, func(i, j int) bool {
		return deduped[i].Similarity > deduped[j].Similarity
	})

	if maxResults < len(deduped) {
		deduped = deduped[:maxResults]
	}
	for i, match := range deduped {
		if userID == nil || match.ItemID == nil {
			log.Printf("Invalid match or user ID")
			continue
		}
		item, err := s.GetItemByID(match.ItemID, userID)
		if err != nil {
			log.Printf("Cannot get item %s: %s", match.ItemID, err)
			continue
		}
		if UserHasAccess(item, userID) {
			deduped[i].Item = item
		}
	}
	return deduped
}

func (s *ArchiveService) GetStorageByID(id, userID *uuid.UUID) (*types.Storage, error) {
	storage, err := s.ArchiveRepository.GetStorageByID(id)
	if err != nil {
		return nil, err
	}
	if !UserHasAccess(storage, userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}

	return storage, nil
}

func (s *ArchiveService) GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error) {
	return s.ArchiveRepository.GetStorageByUserID(userID)
}

func (s *ArchiveService) DeleteStorageByID(storageID, userID *uuid.UUID) error {
	storage, err := s.GetStorageByID(storageID, userID)
	if err != nil || storage == nil {
		return echo.NewHTTPError(http.StatusNotFound, "Storage not found")
	}
	if !storage.UserHasAccess(userID) {
		return echo.NewHTTPError(http.StatusUnauthorized)
	}

	return s.ArchiveRepository.DeleteStorageByID(storageID)
}

func (s *ArchiveService) AddStorage(storage *types.Storage) (*types.Storage, error) {
	return s.ArchiveRepository.AddStorage(storage)
}

func (s *ArchiveService) EditStorage(storage *types.Storage, userID *uuid.UUID) (*types.Storage, error) {
	if !storage.UserHasAccess(userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}

	return s.ArchiveRepository.EditStorage(storage)
}
