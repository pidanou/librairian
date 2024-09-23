package service

import (
	"github.com/google/uuid"
	"github.com/pidanou/librairian/internal/repository"
	"github.com/pidanou/librairian/internal/types"
)

type BillingService struct {
	BillingRepository repository.BillingRepository
}

func NewPostgresBillingService(billingRepository repository.BillingRepository) *BillingService {
	return &BillingService{BillingRepository: billingRepository}
}

func (s *BillingService) AddTokenUsage(tokens int, userID *uuid.UUID) error {
	t := types.TokenUsage{Base: types.Base{UserID: userID}, Amount: tokens}
	return s.BillingRepository.AddTokenUsage(&t)
}

func (s *BillingService) GetUserMonthlyTokenUsage(userID *uuid.UUID) (int, error) {
	return s.BillingRepository.GetUserMonthlyTokenUsage(userID)
}
