package types

import (
	"time"

	"github.com/google/uuid"
)

type Base struct {
	ID        *uuid.UUID `json:"id" db:"id"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt time.Time  `json:"updated_at" db:"updated_at"`
	UserID    *uuid.UUID `json:"user_id" db:"user_id"`
}

type OrderBy struct {
	Column    string
	Direction string
}

type Pagination struct {
	Page  int `json:"page"`
	Limit int `json:"limit"`
	Total int `json:"total"`
}

type Response struct {
	Data     interface{} `json:"data"`
	Metadata interface{} `json:"metadata"`
}
