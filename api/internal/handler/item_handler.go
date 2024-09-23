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

	name := c.QueryParam("name")

	orderBy := c.QueryParam("order_by")
	if !isValidOrderColumn(orderBy) {
		orderBy = "updated_at"
	}

	asc := "DESC"
	ascQ := c.QueryParam("asc")
	if ascQ != "true" {
		asc = "ASC"
	}

	order := types.OrderBy{Column: orderBy, Direction: asc}

	if page == 0 {
		page = 1
	}

	if limit == 0 {
		limit = 20
	}

	items, total, err := h.ItemService.GetItems(userID, &storageID, name, page, limit, order)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); !ok {
			log.Println(err)
			return echo.NewHTTPError(http.StatusInternalServerError)
		} else {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot get item")
		}
	}

	response := types.Response{Data: items, Metadata: types.Pagination{Page: page, Limit: limit, Total: total}}

	c.Response().Header().Set("Content-Type", "application/json;charset=UTF-8")
	return c.JSON(http.StatusOK, response)
}

func (h *Handler) PostItem(c echo.Context) error {
	var itemReq = &types.Item{}
	err := c.Bind(itemReq)

	item := *itemReq

	userID := getUserIDFromJWT(c)

	cleanedLocation := h.StorageService.Clean(&item, userID)

	item.Locations = cleanedLocation

	newItem, err := h.ItemService.AddItem(&item)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); !ok {
			log.Println(err)
			return echo.NewHTTPError(http.StatusInternalServerError)
		} else {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot get item")
		}
	}

	return c.JSON(http.StatusCreated, newItem)
}

func (h *Handler) GetItemByID(c echo.Context) error {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		log.Println(err)
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	userID := getUserIDFromJWT(c)

	item, err := h.ItemService.GetItemByID(&id, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); !ok {
			log.Println(err)
			return echo.NewHTTPError(http.StatusInternalServerError)
		} else {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot get item")
		}
	}

	c.Response().Header().Set("Content-Type", "application/json;charset=UTF-8")
	return c.JSON(http.StatusOK, item)
}

func (h *Handler) DeleteItem(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid ID")
	}

	err = h.ItemService.DeleteItem(&id, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); !ok {
			log.Println(err)
			return echo.NewHTTPError(http.StatusInternalServerError)
		} else {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot delete item")
		}
	}

	return c.NoContent(http.StatusOK)
}

func (h *Handler) PutItem(c echo.Context) error {
	var item = &types.Item{}
	c.Bind(item)

	userID := getUserIDFromJWT(c)

	item, err := h.ItemService.UpdateItem(item, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); !ok {
			log.Println(err)
			return echo.NewHTTPError(http.StatusInternalServerError)
		} else {
			log.Println(err)
			return echo.NewHTTPError(httpErr.Code, "Cannot update item")
		}
	}

	return c.JSON(http.StatusOK, item)
}

func (h *Handler) PatchItem(c echo.Context) error {
	userID := getUserIDFromJWT(c)
	item := &types.Item{}
	c.Bind(item)

	id := uuid.MustParse(c.Param("id"))

	item, err := h.ItemService.PartialUpdateItem(&id, item, userID)
	if err != nil {
		if httpErr, ok := err.(*echo.HTTPError); !ok {
			log.Println(err)
			return echo.NewHTTPError(http.StatusInternalServerError)
		} else {
			log.Println(httpErr.Message)
			return echo.NewHTTPError(httpErr.Code, "Cannot update item")
		}
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

	matches := h.ItemService.FindMatches(req.Search, req.Threshold, req.MaxResults, &userID)

	c.Response().Header().Set("Content-Type", "application/json;charset=UTF-8")
	return c.JSON(http.StatusOK, matches)
}
