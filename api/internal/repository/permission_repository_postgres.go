package repository

import (
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type PostgresPermissionRepository struct {
	DB *sqlx.DB
}

func NewPostgresPermissionRepository(db *sqlx.DB) *PostgresPermissionRepository {
	return &PostgresPermissionRepository{DB: db}
}

func (r *PostgresPermissionRepository) GetUserTier(userID *uuid.UUID) (string, error) {
	var tier string
	query := `SELECT tier FROM public.user WHERE id = $1`
	err := r.DB.Get(&tier, query, userID)
	if err != nil {
		return "", err
	}
	return tier, nil
}

func (r *PostgresPermissionRepository) SetUserTier(userID *uuid.UUID, tier string) error {
	query := `UPDATE public.user SET (tier = $1) WHERE id = $2 `
	err := r.DB.Get(&tier, query, tier, userID)
	if err != nil {
		return err
	}
	return nil
}
