package types

import (
	"time"

	"github.com/google/uuid"
)

type TokenUsage struct {
	Base
	TotalStorage int `json:"total_storage" db:"total_storage"`
	Amount       int `json:"amount" db:"amount"`
}

func (u *TokenUsage) UserHasAccess(userID *uuid.UUID) bool {
	if u.UserID == nil || userID == nil {
		return false
	}
	return *u.UserID == *userID
}

type Subscription struct {
	Base
	SubscriptionStart time.Time `json:"subscription_start" db:"subscription_start"`
	SubscriptionEnd   time.Time `json:"subscription_end" db:"subscription_end"`
}
