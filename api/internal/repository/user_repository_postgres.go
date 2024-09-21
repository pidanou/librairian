package repository

import (
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type PostgresUserRepository struct {
	DB *sqlx.DB
}

func NewPostgresUserRepository(db *sqlx.DB) *PostgresUserRepository {
	return &PostgresUserRepository{DB: db}
}

func (r *PostgresUserRepository) GetUserTier(userID *uuid.UUID) (string, error) {
	var tier string
	query := `SELECT tier FROM public.user WHERE id = $1`
	err := r.DB.Get(&tier, query, userID)
	if err != nil {
		return "", err
	}
	return tier, nil
}

func (r *PostgresUserRepository) SetUserTier(userID *uuid.UUID, tier string) error {
	query := `UPDATE public.user SET (tier = $1) WHERE id = $2 returning tier `
	err := r.DB.Get(&tier, query, tier, userID)
	if err != nil {
		return err
	}
	return nil
}

func (r *PostgresUserRepository) UserIsPremium(userID *uuid.UUID) bool {
	var tier string
	query := `SELECT tier FROM public.user WHERE id = $1`
	err := r.DB.Get(&tier, query, userID)
	if err != nil {
		return false
	}
	if tier != "premium" {
		return false
	}
	return true
}
