package repository

import (
	"log"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/pidanou/librairian/internal/types"
)

type PostgresStorageRepository struct {
	DB *sqlx.DB
}

func NewPostgresStorageRepository(db *sqlx.DB) *PostgresStorageRepository {
	return &PostgresStorageRepository{DB: db}
}

func (r *PostgresStorageRepository) GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error) {
	storages := []types.Storage{}
	query := `SELECT * FROM storage WHERE user_id = $1 ORDER BY updated_at DESC`
	err := r.DB.Select(&storages, query, userID)
	if err != nil {
		return nil, err
	}
	return storages, nil
}

func (r *PostgresStorageRepository) GetStorageByID(id *uuid.UUID) (*types.Storage, error) {
	storage := &types.Storage{}

	query := `SELECT * FROM storage where id = $1 ORDER BY updated_at DESC`
	err := r.DB.Get(storage, query, id)
	if err != nil {
		log.Printf("Cannot get storage: %s", err)
		return nil, err
	}

	return storage, nil
}

func (r *PostgresStorageRepository) AddStorage(storage *types.Storage) (*types.Storage, error) {
	query := `INSERT INTO storage (user_id, alias, created_at, updated_at) VALUES (:user_id, :alias, now(), now()) RETURNING *`
	rows, err := r.DB.NamedQuery(query, storage)
	if err != nil {
		log.Printf("Cannot add storage: %s", err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		rows.StructScan(storage)
	}
	return storage, nil
}

func (r *PostgresStorageRepository) EditStorage(storage *types.Storage) (*types.Storage, error) {
	query := `UPDATE storage SET alias = :alias, updated_at = now() WHERE id = :id`
	_, err := r.DB.NamedExec(query, storage)
	if err != nil {
		log.Printf("Cannot add storage: %s", err)
		return nil, err
	}
	return storage, nil
}

func (r *PostgresStorageRepository) DeleteStorageByID(id *uuid.UUID) error {
	itemsInStorage := []types.Item{}
	itemsIDList := []*uuid.UUID{}
	tx, err := r.DB.Begin()
	if err != nil {
		log.Println(err)
		return err
	}

	query := `SELECT i.* FROM item i JOIN location sl on i.id = sl.item_id WHERE sl.storage_id = $1`
	_ = r.DB.Select(&itemsInStorage, query, id)

	for _, item := range itemsInStorage {
		itemsIDList = append(itemsIDList, item.ID)
	}

	query = "DELETE FROM item WHERE id = any ($1)"
	_, err = tx.Exec(query, itemsIDList)
	if err != nil {
		tx.Rollback()
		log.Println(err)
		return err
	}

	query = `DELETE FROM storage WHERE id = $1`
	_, err = tx.Exec(query, id)
	if err != nil {
		tx.Rollback()
		log.Printf("Cannot delete storage: %s", err)
		return err
	}

	tx.Commit()
	return nil
}
