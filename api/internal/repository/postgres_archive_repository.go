package repository

import (
	"errors"
	"log"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/pidanou/librairian/internal/types"
)

type PostgresArchiveRepository struct {
	DB *sqlx.DB
}

func NewPostgresArchiveRepository(db *sqlx.DB) *PostgresArchiveRepository {
	return &PostgresArchiveRepository{DB: db}
}

func (r *PostgresArchiveRepository) AddItem(item *types.Item) (*types.Item, error) {
	var insertedItemId uuid.UUID

	tx := r.DB.MustBegin()

	query := `INSERT INTO item 
  (user_id, name, is_digital, analysis_date, tags) 
  VALUES (:user_id, :name, :is_digital, :analysis_date, :tags) returning id`
	rows, err := tx.NamedQuery(query, item)
	if err != nil {
		log.Printf(`Cannot create item %s`, err)
		return nil, err
	}

	rows.Next()
	err = rows.Scan(&insertedItemId)
	if err != nil {
		tx.Rollback()
		return nil, err
	}
	rows.Close()

	query = `INSERT INTO description (item_id, data, embedding, user_id) VALUES ($1, $2, $3, $4)`
	_, err = tx.Exec(query, insertedItemId, item.Description.Data, item.Description.Embedding, item.Description.UserID)
	if err != nil {
		log.Printf(`Cannot create description %s`, err)
		tx.Rollback()
		return nil, err
	}

	for _, sl := range item.StorageLocation {
		query = `INSERT INTO storage_location (location, storage_id, item_id, user_id) VALUES ($1, $2, $3, $4)`
		_, err = tx.Exec(query, sl.Location, sl.StorageID, insertedItemId, sl.UserID)
		if err != nil {
			log.Printf(`Cannot create storage location %s`, err)
			tx.Rollback()
			return nil, err
		}
	}

	err = tx.Commit()
	if err != nil {
		log.Printf(`Cannot commit: %s`, err)
		return nil, err
	}

	item, err = r.GetItemByID(&insertedItemId)
	if err != nil {
		return nil, errors.New("Cannot get created item")
	}

	return item, nil
}

func (r *PostgresArchiveRepository) DeleteItem(id *uuid.UUID) error {
	query := `DELETE FROM item WHERE id = $1`
	_, err := r.DB.Exec(query, id)
	if err != nil {
		log.Printf("Cannot delete item: %s", err)
		return err
	}

	return nil
}

func (r *PostgresArchiveRepository) UpdateItem(item *types.Item) (*types.Item, error) {
	tx := r.DB.MustBegin()

	query := `UPDATE item 
  set user_id = :user_id, analysis_date = :analysis_date, is_digital = :is_digital, updated_at = now(), tags = :tags where id = :id`
	_, err := tx.NamedExec(query, item)
	if err != nil {
		log.Printf(`Cannot update item %s`, err)
		return nil, err
	}

	query = `UPDATE description set data = :data, embedding = :embedding, updated_at = now() where id = :id`
	_, err = tx.NamedExec(query, item.Description)
	if err != nil {
		log.Printf(`Cannot update description %s`, err)
		tx.Rollback()
		return nil, err
	}

	for _, sl := range item.StorageLocation {
		query = `UPDATE storage_location set location = :location, storage_id = :storage_id, updated_at = now() where id = :id`
		_, err = tx.NamedExec(query, sl)
		if err != nil {
			log.Printf(`Cannot update storage location %s`, err)
			tx.Rollback()
			return nil, err
		}
	}

	err = tx.Commit()
	if err != nil {
		log.Printf(`Cannot commit: %s`, err)
		return nil, err
	}
	return item, nil
}

func (r *PostgresArchiveRepository) GetItemByID(id *uuid.UUID) (*types.Item, error) {
	item := &types.Item{}
	description := &types.Description{}
	storageLocation := []types.StorageLocation{}
	storage := &types.Storage{}

	query := `SELECT * FROM item WHERE id = $1`
	err := r.DB.Get(item, query, id)
	if err != nil {
		log.Printf("Cannot get item: %s", err)
		return nil, err
	}

	query = `SELECT * FROM description WHERE item_id = $1`
	err = r.DB.Get(description, query, item.ID)
	if err != nil {
		log.Printf("Cannot get description: %s", err)
	}

	query = `SELECT * FROM storage_location WHERE item_id = $1`
	err = r.DB.Select(&storageLocation, query, item.ID)
	if err != nil {
		log.Printf("Cannot get storage location: %s", err)
	}

	for i, sl := range storageLocation {
		query = `SELECT * FROM storage WHERE id = $1`
		err = r.DB.Get(storage, query, sl.StorageID)
		if err != nil {
			log.Printf("Cannot get storage: %s", err)
		}
		sl.Storage = storage
		storageLocation[i] = sl
	}

	item.Description = description
	item.StorageLocation = storageLocation

	return item, nil
}

func (r *PostgresArchiveRepository) EditItemMetadata(item *types.Item) (*types.Item, error) {
	tx := r.DB.MustBegin()
	query := `UPDATE item set user_id = :user_id, name = :name, analysis_date = :analysis_date, updated_at = now(), tags = :tags where id = :id`
	_, err := tx.NamedExec(query, item)
	if err != nil {
		log.Printf("Cannot edit item: %s", err)
		tx.Rollback()
		return nil, err
	}

	for _, sl := range item.StorageLocation {
		query = `UPDATE storage_location set location = :location, storage_id = :storage_id, updated_at = now() where id = :id`
		_, err = tx.NamedExec(query, sl)
		if err != nil {
			log.Printf("Cannot edit storage location: %s", err)
			tx.Rollback()
			return nil, err
		}
	}
	tx.Commit()

	item, err = r.GetItemByID(item.ID)
	if err != nil {
		log.Printf("Cannot get item: %s", err)
		return nil, err
	}

	return item, nil
}

func (r *PostgresArchiveRepository) GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error) {
	storages := []types.Storage{}
	query := `SELECT * FROM storage WHERE user_id = $1`
	err := r.DB.Select(&storages, query, userID)
	if err != nil {
		return nil, err
	}
	return storages, nil
}

func (r *PostgresArchiveRepository) GetStorageByID(id *uuid.UUID) (*types.Storage, error) {
	storage := &types.Storage{}

	query := `SELECT * FROM storage where id = $1`
	err := r.DB.Get(storage, query, id)
	if err != nil {
		log.Printf("Cannot get storage: %s", err)
		return nil, err
	}

	return storage, nil
}
