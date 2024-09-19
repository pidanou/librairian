package service

import (
	"log"
	"net/http"

	"dario.cat/mergo"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/repository"
	"github.com/pidanou/librairian/internal/types"
)

type ItemService struct {
	ItemRepository    repository.ItemRepository
	EmbeddingService  Embedder
	SimilarityService SimilarityChecker
}

func NewItemService(r repository.ItemRepository, e Embedder, s SimilarityChecker) *ItemService {
	return &ItemService{ItemRepository: r, EmbeddingService: e, SimilarityService: s}
}

func (s *ItemService) AddItem(item *types.Item) (*types.Item, error) {
	descriptionEmbedding, err := s.EmbeddingService.CreateEmbedding(item.Description)
	if err != nil {
		log.Println("Cannot create description embedding: ", err)
		return nil, err
	}
	item.DescriptionEmbeddings = descriptionEmbedding

	newItem, err := s.ItemRepository.AddItem(item)
	if err != nil {
		log.Println("Cannot add item: ", err)
		return nil, err
	}

	return newItem, nil
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

	if item.Description != nil && item.Description != itemCheck.Description {
		descriptionEmbedding, err := s.EmbeddingService.CreateEmbedding(item.Description)
		if err != nil {
			return nil, echo.NewHTTPError(http.StatusInternalServerError, "Cannot create description embedding")
		}
		item.DescriptionEmbeddings = descriptionEmbedding
	}

	return s.ItemRepository.UpdateItem(item)
}

func (s *ItemService) PartialUpdateItem(itemID *uuid.UUID, newItem *types.Item, userID *uuid.UUID) (*types.Item, error) {
	oldItem, err := s.GetItemByID(itemID, userID)
	if err != nil || oldItem == nil {
		return nil, echo.NewHTTPError(http.StatusBadRequest, "Cannot edit item: item does not exist")
	}

	if newItem.Description != nil && newItem.Description != oldItem.Description {
		descriptionEmbedding, err := s.EmbeddingService.CreateEmbedding(newItem.Description)
		if err != nil {
			return nil, echo.NewHTTPError(http.StatusInternalServerError, "Cannot create description embedding")
		}
		newItem.DescriptionEmbeddings = descriptionEmbedding
	}

	mergo.Merge(newItem, oldItem)
	if !UserHasAccess(newItem, userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}

	return s.ItemRepository.UpdateItem(newItem)
}

func (s *ItemService) GetItemByID(id *uuid.UUID, userID *uuid.UUID) (*types.Item, error) {
	item, err := s.ItemRepository.GetItemByID(id)
	if err != nil {
		return nil, err
	}
	if !item.UserHasAccess(userID) {
		return nil, echo.NewHTTPError(http.StatusUnauthorized)
	}
	return item, nil
}

func (s *ItemService) FindMatches(search string, threshold float32, maxResults int, userID *uuid.UUID) []types.MatchedItem {

	embedding, err := s.EmbeddingService.CreateEmbedding(&search)
	if err != nil {
		return []types.MatchedItem{}
	}

	matches, err := s.SimilarityService.Find(embedding, threshold, maxResults, userID)
	if err != nil {
		return []types.MatchedItem{}
	}

	for i, match := range matches {
		item, err := s.GetItemByID(match.ItemID, userID)
		if err != nil {
			log.Printf("Cannot get item %s: %s", match.ItemID, err)
			continue
		}
		if UserHasAccess(item, userID) {
			matches[i].Item = item
		}
	}
	return matches
}
