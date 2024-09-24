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

type ItemService struct {
	ItemRepository    repository.ItemRepository
	EmbeddingService  IEmbeddingService
	SimilarityService *SimilarityService
	BillingService    *BillingService
}

func NewItemService(r repository.ItemRepository, e IEmbeddingService, s *SimilarityService, b *BillingService) *ItemService {
	return &ItemService{ItemRepository: r, EmbeddingService: e, SimilarityService: s, BillingService: b}
}

func (s *ItemService) AddItem(item *types.Item) (*types.Item, error) {
	return s.ItemRepository.AddItem(item)
}

func (s *ItemService) GetItems(userID *uuid.UUID, storageID *uuid.UUID, name string, page int, limit int, order types.OrderBy) ([]types.Item, int, error) {
	return s.ItemRepository.GetItems(userID, storageID, name, page, limit, order)
}

func (s *ItemService) DeleteItem(id, userID *uuid.UUID) error {
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
	return s.ItemRepository.DeleteItem(id)
}

func (s *ItemService) UpdateItem(item *types.Item, userID *uuid.UUID) (*types.Item, error) {
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

	if item.Description != "" && item.Description != itemCheck.Description {
		descriptionEmbedding, err := s.EmbeddingService.CreateEmbedding(item.Description)
		if err != nil {
			return nil, echo.NewHTTPError(http.StatusInternalServerError, "Cannot create description embedding")
		}
		item.DescriptionEmbeddings = descriptionEmbedding
		descriptionToken := s.EmbeddingService.CountTokens(item.Description)
		err = s.BillingService.AddTokenUsage(descriptionToken, userID)
		if err != nil {
			log.Println(err)
		}
	}

	return s.ItemRepository.UpdateItem(item)
}

func (s *ItemService) PartialUpdateItem(itemID *uuid.UUID, newItem *types.Item, userID *uuid.UUID) (*types.Item, error) {
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

	if newItem.Description != "" && newItem.Description != oldItem.Description {
		descriptionEmbedding, err := s.EmbeddingService.CreateEmbedding(newItem.Description)
		if err != nil {
			return nil, echo.NewHTTPError(http.StatusInternalServerError, "Cannot create description embedding")
		}
		newItem.DescriptionEmbeddings = descriptionEmbedding
		descriptionToken := s.EmbeddingService.CountTokens(newItem.Description)
		err = s.BillingService.AddTokenUsage(descriptionToken, userID)
		if err != nil {
			log.Println(err)
			return nil, err
		}
	}

	if newItem.Locations != nil && len(newItem.Locations) == 0 {
		mergo.Merge(newItem, oldItem)
		newItem.Locations = []types.Location{}
	} else {
		mergo.Merge(newItem, oldItem)
	}

	if !UserHasAccess(newItem, userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}

	return s.ItemRepository.UpdateItem(newItem)
}

func (s *ItemService) GetItemByID(id *uuid.UUID, userID *uuid.UUID) (*types.Item, error) {
	item, err := s.ItemRepository.GetItemByID(id)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	if !item.UserHasAccess(userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}
	return item, nil
}

func (s *ItemService) FindMatches(search string, threshold float32, maxResults int, userID *uuid.UUID) []types.MatchedItem {
	monthlyTokens, err := s.BillingService.GetUserMonthlyTokenUsage(userID)
	if monthlyTokens > 100000000 || err != nil {
		return []types.MatchedItem{}
	}

	embedding, err := s.EmbeddingService.CreateEmbedding(search)
	if err != nil {
		return []types.MatchedItem{}
	}
	searchToken := s.EmbeddingService.CountTokens(search)
	err = s.BillingService.AddTokenUsage(searchToken, userID)
	if err != nil {
		log.Println(err)
		return []types.MatchedItem{}
	}

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