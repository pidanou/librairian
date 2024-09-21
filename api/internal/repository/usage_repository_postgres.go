package repository

import (
	"github.com/jmoiron/sqlx"
	"github.com/pidanou/librairian/internal/types"
)

// WIP

type PostgresUsageRepository struct {
	DB *sqlx.DB
}

func NewPostgresUsageRepository(db *sqlx.DB) *PostgresUsageRepository {
	return &PostgresUsageRepository{DB: db}
}

func (r *PostgresUsageRepository) AddUsage(usage *types.Usage) (*types.Usage, error) {
	query := `INSERT INTO usage (user_id, total_storage, monthly_tokens, monthly_attachments) 
  VALUES (:user_id, :total_storage, :monthly_tokens, :monthly_attachments) RETURNING *`
	rows, err := r.DB.Queryx(query, usage.UserID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		rows.StructScan(usage)
	}
	return usage, nil
}
