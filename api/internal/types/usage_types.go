package types

import "github.com/google/uuid"

type Usage struct {
	Base
	TotalStorage       int64  `json:"total_storage" db:"total_storage"`
	MonthlyTokens      int64  `json:"monthly_tokens" db:"monthly_tokens"`
	MonthlyAttachments int64  `json:"monthly_attachments" db:"monthly_attachments"`
	CurrentTier        string `json:"current_tier" db:"current_tier"`
}

func (u *Usage) UserHasAccess(userID *uuid.UUID) bool {
	if u.UserID == nil {
		return false
	}
	return *u.UserID == *userID
}
