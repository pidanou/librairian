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

func (r *PostgresArchiveRepository) AddFile(file *types.File) (*types.File, error) {
	var insertedFileId uuid.UUID

	tx := r.DB.MustBegin()

	query := `INSERT INTO file 
  (user_id, name, analysis_date, tags, size, word_count) 
  VALUES (:user_id, :name, :analysis_date, :tags, :size, :word_count) returning id`
	rows, err := tx.NamedQuery(query, file)
	if err != nil {
		log.Printf(`Cannot create file %s`, err)
		return nil, err
	}

	rows.Next()
	err = rows.Scan(&insertedFileId)
	if err != nil {
		tx.Rollback()
		return nil, err
	}
	rows.Close()

	query = `INSERT INTO description (file_id, data, embedding, user_id) VALUES ($1, $2, $3, $4)`
	_, err = tx.Exec(query, insertedFileId, file.Description.Data, file.Description.Embedding, file.Description.UserID)
	if err != nil {
		log.Printf(`Cannot create description %s`, err)
		tx.Rollback()
		return nil, err
	}

	for _, sl := range file.StorageLocation {
		query = `INSERT INTO storage_location (location, storage_id, file_id, user_id) VALUES ($1, $2, $3, $4)`
		_, err = tx.Exec(query, sl.Location, sl.StorageID, insertedFileId, sl.UserID)
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

	file, err = r.GetFileByID(&insertedFileId)
	if err != nil {
		return nil, errors.New("Cannot get created file")
	}

	return file, nil
}

func (r *PostgresArchiveRepository) DeleteFile(id *uuid.UUID) error {
	query := `DELETE FROM file WHERE id = $1`
	_, err := r.DB.Exec(query, id)
	if err != nil {
		log.Printf("Cannot delete file: %s", err)
		return err
	}

	return nil
}

func (r *PostgresArchiveRepository) UpdateFile(file *types.File) (*types.File, error) {
	tx := r.DB.MustBegin()

	query := `UPDATE file 
  set user_id = :user_id, analysis_date = :analysis_date, updated_at = now(), tags = :tags, size = :size, word_count = :word_count where id = :id`
	_, err := tx.NamedExec(query, file)
	if err != nil {
		log.Printf(`Cannot update file %s`, err)
		return nil, err
	}

	query = `UPDATE description set data = :data, embedding = :embedding, updated_at = now() where id = :id`
	_, err = tx.NamedExec(query, file.Description)
	if err != nil {
		log.Printf(`Cannot update description %s`, err)
		tx.Rollback()
		return nil, err
	}

	for _, sl := range file.StorageLocation {
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
	return file, nil
}

func (r *PostgresArchiveRepository) GetFileByID(id *uuid.UUID) (*types.File, error) {
	file := &types.File{}
	description := &types.Description{}
	storageLocation := []types.StorageLocation{}
	storage := &types.Storage{}

	query := `SELECT * FROM file WHERE id = $1`
	err := r.DB.Get(file, query, id)
	if err != nil {
		log.Printf("Cannot get file: %s", err)
		return nil, err
	}

	query = `SELECT * FROM description WHERE file_id = $1`
	err = r.DB.Get(description, query, file.ID)
	if err != nil {
		log.Printf("Cannot get description: %s", err)
	}

	query = `SELECT * FROM storage_location WHERE file_id = $1`
	err = r.DB.Select(&storageLocation, query, file.ID)
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

	file.Description = description
	file.StorageLocation = storageLocation

	return file, nil
}

func (r *PostgresArchiveRepository) EditFileMetadata(file *types.File) (*types.File, error) {
	tx := r.DB.MustBegin()
	query := `UPDATE file set user_id = :user_id, name = :name, analysis_date = :analysis_date, updated_at = now(), tags = :tags, size = :size, word_count = :word_count where id = :id`
	_, err := tx.NamedExec(query, file)
	if err != nil {
		log.Printf("Cannot edit file: %s", err)
		tx.Rollback()
		return nil, err
	}

	for _, sl := range file.StorageLocation {
		query = `UPDATE storage_location set location = :location, storage_id = :storage_id, updated_at = now() where id = :id`
		_, err = tx.NamedExec(query, sl)
		if err != nil {
			log.Printf("Cannot edit storage location: %s", err)
			tx.Rollback()
			return nil, err
		}
	}
	tx.Commit()

	file, err = r.GetFileByID(file.ID)
	if err != nil {
		log.Printf("Cannot get file: %s", err)
		return nil, err
	}

	return file, nil
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
