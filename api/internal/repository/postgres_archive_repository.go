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

	tx := r.DB.MustBegin()

	query := `INSERT INTO item
  (user_id, name, description, description_embeddings, attachments)
  VALUES (:user_id, :name, :description, :description_embeddings, :attachments) returning id`
	rows, err := tx.NamedQuery(query, item)
	if err != nil {
		log.Printf(`Cannot create item %s`, err)
		return nil, err
	}
	defer rows.Close()

	rows.Next()
	err = rows.Scan(&insertedItemId)
	if err != nil {
		tx.Rollback()
		return nil, err
	}
	rows.Close()

	for _, sl := range item.Locations {
		query = `INSERT INTO location (location, storage_id, item_id, user_id) VALUES ($1, $2, $3, $4)`
		_, err = tx.Exec(query, sl.Location, sl.Storage.ID, insertedItemId, sl.UserID)
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

func (r *PostgresArchiveRepository) GetItems(userID *uuid.UUID, storageID *uuid.UUID, name string, page int, limit int, orderBy types.OrderBy) ([]types.Item, int, error) {
	itemsID := []uuid.UUID{}
	items := []types.Item{}
	total := 0
	page = page - 1
	var err error

	if *storageID != uuid.Nil {
		query := fmt.Sprintf(`SELECT i.id 
                      FROM item i 
                      JOIN location sl 
                      ON i.id = sl.item_id 
                      WHERE i.user_id = $1 
                      AND sl.storage_id = $2  
                      AND i.name ILIKE $3
                      ORDER BY i.%s %s 
                      LIMIT $4 OFFSET $5`, orderBy.Column, orderBy.Direction)
		err := r.DB.Select(&itemsID, query, userID, storageID, "%"+name+"%", limit, page*limit)
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

		query = `SELECT count(*) FROM item i JOIN location sl ON i.id = sl.item_id WHERE i.user_id = $1 AND sl.storage_id = $2                       AND i.name ILIKE $3
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

func (r *PostgresArchiveRepository) UpdateItem(item *types.Item) (*types.Item, error) {
	tx := r.DB.MustBegin()

	query := `UPDATE item
    set 
  name = :name, 
  description = :description, 
  description_embeddings = :description_embeddings, 
  attachments = :attachments,
  updated_at = now() 
  where id = :id`
	_, err := tx.NamedExec(query, item)
	if err != nil {
		log.Printf(`Cannot update item %s`, err)
		return nil, err
	}

	slList := []uuid.UUID{}

	for _, sl := range item.Locations {
		if sl.ID == nil {
			sl.ItemID = item.ID
			sl.UserID = item.UserID
			query = `INSERT INTO location(item_id, user_id, location, storage_id, created_at, updated_at) VALUES (:item_id, :user_id, :location, :storage_id, now(), now()) RETURNING id`
		} else {
			query = `UPDATE location set location = :location, storage_id = :storage_id, updated_at = now() where id = :id returning id`
		}
		rows, err := tx.NamedQuery(query, sl)
		defer rows.Close()
		if err != nil {
			log.Printf(`Cannot update storage location %s`, err)
			tx.Rollback()
			return nil, err
		}
		var id uuid.UUID
		for rows.Next() {
			_ = rows.Scan(&id)
			slList = append(slList, id)
		}
	}

	query, args, err := sqlx.In(`DELETE FROM location where id NOT IN (?) and item_id = ?`, slList, item.ID)
	query = tx.Rebind(query)
	_, err = tx.Exec(query, args...)
	if err != nil {
		log.Printf(`Cannot delete storage location %s`, err)
		tx.Rollback()
		return nil, err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf(`Cannot commit: %s`, err)
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
	storageLocation := []types.Location{}
	storage := &types.Storage{}

	query := `SELECT * FROM item WHERE id = $1 ORDER BY updated_at DESC`
	err := r.DB.Get(item, query, id)
	if err != nil {
		log.Printf("Cannot get item: %s", err)
		return nil, err
	}

	query = `SELECT * FROM location WHERE item_id = $1`
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

	item.Locations = storageLocation

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

func (r *PostgresArchiveRepository) GetAttachmentByID(id *uuid.UUID) (*types.Attachment, error) {
	attachment := &types.Attachment{}
	query := `SELECT * FROM attachment WHERE id = $1`
	err := r.DB.Get(attachment, query, id)
	if err != nil {
		log.Printf(`Cannot get attachment by id %s`, err)
		return nil, err
	}
	return attachment, nil
}

func (r *PostgresArchiveRepository) GetItemAttachments(id *uuid.UUID) ([]types.Attachment, error) {
	attachments := []types.Attachment{}
	query := `SELECT * FROM attachment WHERE item_id = $1`
	err := r.DB.Select(&attachments, query, id)
	if errors.Is(err, sql.ErrNoRows) {
		return []types.Attachment{}, nil
	}
	if err != nil {
		return nil, err
	}
	return attachments, nil
}

func (r *PostgresArchiveRepository) AddAttachments(attachments []types.Attachment) []types.Attachment {
	insertedAttachments := []types.Attachment{}
	query := `INSERT INTO attachment (user_id, created_at, updated_at, item_id, path, labels, labels_embeddings) 
  VALUES (:user_id, now(), now(), :item_id, :path, :labels, :labels_embeddings) RETURNING *`

	for _, attachment := range attachments {
		rows, err := r.DB.NamedQuery(query, attachment)
		if err != nil {
			log.Printf(`Cannot add attachment %s`, err)
			continue
		}
		defer rows.Close()

		if rows.Next() {
			var inserted types.Attachment
			if err := rows.StructScan(&inserted); err != nil {
				log.Printf(`Cannot scan inserted attachment %s`, err)
				continue
			}
			insertedAttachments = append(insertedAttachments, inserted)
		} else {
			log.Printf("No attachment inserted for user_id %d", attachment.UserID)
		}
	}

	return insertedAttachments
}

func (r *PostgresArchiveRepository) DeleteAttachmentByID(id *uuid.UUID) error {
	query := `DELETE FROM attachment WHERE id = $1`
	_, err := r.DB.Exec(query, id)
	if err != nil {
		log.Printf(`Cannot delete attachment %s`, err)
	}
	return err
}
