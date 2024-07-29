package handler

import (
	"log"
	"net/http"
	"strconv"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/types"
)

func (h *Handler) GetItems(c echo.Context) error {
	userID := getUserIDFromJWT(c)

	page, _ := strconv.Atoi(c.QueryParam("page"))
	limit, _ := strconv.Atoi(c.QueryParam("limit"))

	storageIDString := c.QueryParam("storage_id")
	storageID, err := uuid.Parse(storageIDString)

	if page == 0 {
		page = 1
	}

	if limit == 0 {
		limit = 20
	}

	items, total, err := h.ArchiveService.GetItems(userID, &storageID, page, limit)
	if err != nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot get items")
	}

	response := types.Response{Data: items, Metadata: types.Pagination{Page: page, Limit: limit, Total: total}}

	return c.JSON(http.StatusOK, response)
}

func (h *Handler) PostItems(c echo.Context) error {
	var items = &[]types.Item{}
	c.Bind(items)

	userID := getUserIDFromJWT(c)

	success := []types.Item{}
	errors := []types.Item{}

	for _, item := range *items {
		if item.Description == nil {
			item.Description = &types.Description{}
		}

		cleanedStorageLocation := []types.StorageLocation{}
		for _, sl := range item.StorageLocation {
			storage, err := h.ArchiveService.GetStorageByID(sl.Storage.ID)
			if err != nil {
				log.Println("Cannot get storage: ", err)
				continue
			}
			if !UserHasAccess(storage, userID) {
				continue
			}
			sl.UserID = userID
			cleanedStorageLocation = append(cleanedStorageLocation, sl)
		}

		item.StorageLocation = cleanedStorageLocation

		item.Description.UserID = userID
		descriptionEmbedding, err := h.EmbeddingService.CreateEmbedding(item.Description.Data)
		if err != nil {
			log.Println("Cannot create description embedding: ", err)
			errors = append(errors, item)
			continue
		}
		item.Description.Embedding = descriptionEmbedding

		titem, err := h.ArchiveService.AddItem(&item)
		if err != nil {
			log.Println("Cannot add item: ", err)
			errors = append(errors, item)
			continue
		}

		success = append(success, *titem)
	}
	return c.JSON(http.StatusCreated, map[string]interface{}{"successes": success, "errors": errors})
}

func (h *Handler) GetItemById(c echo.Context) error {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	userID := getUserIDFromJWT(c)

	item, err := h.ArchiveService.GetItemById(&id)
	if err != nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot get item")
	}

	if !UserHasAccess(item, userID) {
		return c.NoContent(http.StatusUnauthorized)
	}

	return c.JSON(http.StatusOK, item)
}

func (h *Handler) DeleteItem(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	item, err := h.ArchiveService.GetItemById(&id)
	if err != nil || item == nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot delete item: item does not exist")
	}

	if !UserHasAccess(item, userID) {
		return c.NoContent(http.StatusUnauthorized)
	}

	err = h.ArchiveService.DeleteItem(&id)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot delete item")
	}

	return c.NoContent(http.StatusOK)
}

func (h *Handler) PutItem(c echo.Context) error {
	var item = &types.Item{}
	c.Bind(item)

	userID := getUserIDFromJWT(c)
	itemCheck, err := h.ArchiveService.GetItemById(item.ID)
	if err != nil || itemCheck == nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Cannot edit item: item does not exist")
	}

	if !UserHasAccess(itemCheck, userID) {
		return c.NoContent(http.StatusUnauthorized)
	}

	descriptionEmbedding, err := h.EmbeddingService.CreateEmbedding(item.Description.Data)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot create description embedding")
	}
	item.Description.Embedding = descriptionEmbedding

	item, err = h.ArchiveService.UpdateItem(item)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot update item")
	}

	return c.JSON(http.StatusOK, item)
}

func (h *Handler) PatchItemMetadata(c echo.Context) error {
	var item = &types.Item{}
	c.Bind(item)

	id := uuid.MustParse(c.Param("id"))
	if &id != item.ID {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid or missing ID")
	}

	userID := getUserIDFromJWT(c)
	if !UserHasAccess(item, userID) {
		return c.NoContent(http.StatusUnauthorized)
	}

	item, err := h.ArchiveService.EditItemMetadata(item)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Cannot update item")
	}
	return c.JSON(http.StatusOK, item)
}

func (h *Handler) GetMatches(c echo.Context) error {
	type request struct {
		Search     string  `query:"search"`
		Threshold  float32 `query:"threshold"`
		MaxResults int     `query:"max_results"`
	}

	token, ok := c.Get("user").(*jwt.Token)
	if !ok {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid token")
	}

	userID := uuid.MustParse(token.Claims.(jwt.MapClaims)["sub"].(string))

	req := request{}
	err := c.Bind(&req)
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest)
	}

	if req.Search == "" {
		return c.JSON(http.StatusOK, []types.Item{})
	}

	if req.MaxResults == 0 {
		req.MaxResults = 10
	}

	if req.MaxResults > 100 {
		req.MaxResults = 100
	}

	embedding, err := h.EmbeddingService.CreateEmbedding(req.Search)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}

	matches, err := h.SimilarityService.Find(embedding, req.Threshold, req.MaxResults, &userID)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}

	for i, match := range matches {
		item, err := h.ArchiveService.GetItemById(match.ItemID)
		if err != nil {
			log.Printf("Cannot get item %s: %s", item.ID, err)
			continue
		}
		if UserHasAccess(item, &userID) {
			matches[i].Item = item
		}
	}

	c.Response().Header().Set("Content-Type", "application/json;charset=UTF-8")
	return c.JSON(http.StatusOK, matches)
}
