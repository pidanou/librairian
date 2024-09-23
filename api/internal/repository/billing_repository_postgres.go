package repository

import (
	"database/sql"
	"errors"
	"log"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/pidanou/librairian/internal/types"
)

// WIP

type PostgresBillingRepository struct {
	DB *sqlx.DB
}

func NewPostgresBillingRepository(db *sqlx.DB) *PostgresBillingRepository {
	return &PostgresBillingRepository{DB: db}
}

func (r *PostgresBillingRepository) AddTokenUsage(usage *types.TokenUsage) error {
	query := `INSERT INTO token_usage (user_id, amount) 
  VALUES (:user_id, :amount)`
	_, err := r.DB.Exec(query, usage.UserID)
	if err != nil {
		return err
	}
	return nil
}

func (r *PostgresBillingRepository) GetUserMonthlyTokenUsage(userID *uuid.UUID) (int, error) {
	var amount int
	subscription, err := r.GetUserActiveSubscription(userID)
	if err != nil || subscription == nil {
		return 0, err
	}

	query := `SELECT sum(amount) FROM token_usage WHERE user_id = $1 AND created_at BETWEEN $2 AND $3`
	err = r.DB.Get(&amount, query, userID, subscription.SubscriptionStart, subscription.SubscriptionEnd)
	if err != nil {
		log.Println("Cannot get token usage: ", err)
		return 0, err
	}
	return amount, nil
}

func (r *PostgresBillingRepository) GetUserActiveSubscription(userID *uuid.UUID) (*types.Subscription, error) {
	var subscription types.Subscription
	query := `SELECT * FROM subscription WHERE user_id = $1 AND now() BETWEEN subscription_start AND subscription_end`
	err := r.DB.Get(&subscription, query, userID)
	if errors.Is(err, sql.ErrNoRows) {
		log.Println("No active subscription")
		return nil, nil
	}
	if err != nil {
		log.Println("Cannot get subscription: ", err)
		return nil, err
	}
	return &subscription, nil
}
