package handler

import (
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

func getUserIDFromJWT(c echo.Context) *uuid.UUID {
	token, ok := c.Get("user").(*jwt.Token)
	if !ok {
		return nil
	}
	userID := uuid.MustParse(token.Claims.(jwt.MapClaims)["sub"].(string))
	return &userID
}

type ProtectedResource interface {
	UserHasAccess(userID *uuid.UUID) bool
}

func UserHasAccess(p ProtectedResource, userID *uuid.UUID) bool {
	return p.UserHasAccess(userID)
}
