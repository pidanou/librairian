package repository

import (
	"database/sql"
	"errors"
	"fmt"
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

	query := `INSERT INTO item
  (user_id, name, description, description_embeddings )
  VALUES (:user_id, :name, :description, :description_embeddings ) returning id`
	rows, err := r.DB.NamedQuery(query, item)
	if err != nil {
		log.Printf(`Cannot create item %s`, err)
		return nil, err
	}
	defer rows.Close()

	rows.Next()
	err = rows.Scan(&insertedItemId)
	if err != nil {
		return nil, err
	}
	rows.Close()

	item, err = r.GetItemByID(&insertedItemId)
	if err != nil {
		return nil, errors.New("Cannot get created item")
	}

	return item, nil
}

func (r *PostgresArchiveRepository) GetItems(userID *uuid.UUID, storageID *uuid.UUID, name string, page int, limit int, orderBy types.OrderBy) ([]types.Item, int, error) {
	itemsID := []uuid.UUID{}
	items := []types.Item{}
	total := 0
	page = page - 1
	var err error

	if *storageID != uuid.Nil {
		query := fmt.Sprintf(`
    SELECT a.id FROM (
      SELECT DISTINCT i.id as id, i.%s
		  FROM item i
		  JOIN location sl
		  ON i.id = sl.item_id
		  WHERE i.user_id = $1
		  AND sl.storage_id = $2
		  AND i.name ILIKE $3
		  ORDER BY i.%s %s
		  LIMIT $4 OFFSET $5) as a`, orderBy.Column, orderBy.Column, orderBy.Direction)
		err := r.DB.Select(&itemsID, query, userID, storageID, "%"+name+"%", limit, page*limit)
		if errors.Is(err, sql.ErrNoRows) {
			return []types.Item{}, 0, nil
		}
		if err != nil {
			log.Println("Cannot get items: ", err)
			return nil, 0, err
		}
		for _, itemID := range itemsID {
			item, err := r.GetItemByID(&itemID)
			if err != nil || item == nil {
				continue
			}
			items = append(items, *item)
		}

		query = `SELECT count(*) FROM item i JOIN location sl ON i.id = sl.item_id WHERE i.user_id = $1 AND sl.storage_id = $2 AND i.name ILIKE $3
            AND i.name ILIKE $3`
		err = r.DB.Get(&total, query, userID, storageID, "%"+name+"%")
		if err != nil {
			log.Println("Cannot get items: ", err)
		}

		return items, total, nil
	}

	query := fmt.Sprintf(`SELECT i.id 
                      FROM item i 
                      WHERE i.user_id = $1 
                      AND i.name ILIKE $2
                      ORDER BY i.%s %s 
                      LIMIT $3 OFFSET $4`, orderBy.Column, orderBy.Direction)
	err = r.DB.Select(&itemsID, query, userID, "%"+name+"%", limit, page*limit)
	if err != nil {
		log.Println("Cannot get items: ", err)
		return nil, 0, err
	}

	for _, itemID := range itemsID {
		item, err := r.GetItemByID(&itemID)
		if err != nil || item == nil {
			continue
		}
		items = append(items, *item)
	}

	query = `SELECT count(*) FROM item WHERE user_id = $1 AND name ILIKE $2
  `
	err = r.DB.Get(&total, query, userID, "%"+name+"%")
	if err != nil {
		log.Println("Cannot get items: ", err)
	}

	return items, total, nil
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

func (r *PostgresArchiveRepository) AddItemLocation(location *types.Location) (*types.Item, error) {
	query := `INSERT INTO location (storage_id, item_id, user_id) VALUES (:storage_id, :item_id, :user_id)`
	_, err := r.DB.NamedExec(query, location)
	if err != nil {
		log.Printf(`Cannot add item location %s`, err)
		return nil, err
	}

	item, err := r.GetItemByID(location.ItemID)

	return item, err
}

func (r *PostgresArchiveRepository) GetLocation(id *uuid.UUID) (*types.Location, error) {
	var location types.Location
	query := `SELECT * FROM location WHERE id = $1`
	err := r.DB.Get(&location, query, id)
	if err != nil {
		log.Printf(`Cannot add get location %s`, err)
		return nil, err
	}

	return &location, nil
}

func (r *PostgresArchiveRepository) GetItemLocations(itemID *uuid.UUID) ([]types.Location, error) {
	var locations []types.Location
	query := `SELECT * FROM location WHERE item_id = $1`
	err := r.DB.Select(&locations, query, itemID)
	if err != nil {
		log.Printf(`Cannot add get location %s`, err)
		return nil, err
	}

	return locations, nil
}

func (r *PostgresArchiveRepository) DeleteItemLocation(id *uuid.UUID) error {
	query := `DELETE FROM location WHERE id = $1`
	_, err := r.DB.Exec(query, id)
	if err != nil {
		log.Printf(`Cannot add delete location %s`, err)
		return err
	}

	return nil
}

func (r *PostgresArchiveRepository) UpdateItem(item *types.Item) (*types.Item, error) {

	query := `UPDATE item
    set 
  name = :name, 
  description = :description, 
  description_embeddings = :description_embeddings, 
  updated_at = now() 
  where id = :id`
	_, err := r.DB.NamedExec(query, item)
	if err != nil {
		log.Printf(`Cannot update item %s`, err)
		return nil, err
	}

	item, err = r.GetItemByID(item.ID)
	if err != nil {
		return nil, err
	}

	return item, nil
}

func (r *PostgresArchiveRepository) GetItemByID(id *uuid.UUID) (*types.Item, error) {
	item := &types.Item{}

	query := `SELECT * FROM item WHERE id = $1 ORDER BY updated_at DESC`
	err := r.DB.Get(item, query, id)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		log.Printf("Cannot get item: %s", err)
		return nil, err
	}

	return item, nil
}

func (r *PostgresArchiveRepository) GetStorageByUserID(userID *uuid.UUID) ([]types.Storage, error) {
	storages := []types.Storage{}
	query := `SELECT * FROM storage WHERE user_id = $1 ORDER BY updated_at DESC`
	err := r.DB.Select(&storages, query, userID)
	if err != nil {
		return nil, err
	}
	return storages, nil
}

func (r *PostgresArchiveRepository) GetStorageByID(id *uuid.UUID) (*types.Storage, error) {
	storage := &types.Storage{}

	query := `SELECT * FROM storage where id = $1 ORDER BY updated_at DESC`
	err := r.DB.Get(storage, query, id)
	if err != nil {
		log.Printf("Cannot get storage: %s", err)
		return nil, err
	}

	return storage, nil
}

func (r *PostgresArchiveRepository) AddStorage(storage *types.Storage) (*types.Storage, error) {
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

func (r *PostgresArchiveRepository) EditStorage(storage *types.Storage) (*types.Storage, error) {
	query := `UPDATE storage SET alias = :alias, updated_at = now() WHERE id = :id`
	_, err := r.DB.NamedExec(query, storage)
	if err != nil {
		log.Printf("Cannot add storage: %s", err)
		return nil, err
	}
	return storage, nil
}

func (r *PostgresArchiveRepository) DeleteStorageByID(id *uuid.UUID) error {
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
