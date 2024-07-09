package repository

import (
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

func (r *PostgresArchiveRepository) Add(file *types.File) error {
	var insertedFileId uuid.UUID

	tx := r.DB.MustBegin()

	query := `INSERT INTO file 
  (analysis_date, tags, size, word_count) 
  VALUES (:analysis_date, :tags, :size, :word_count) returning id`
	rows, err := tx.NamedQuery(query, file)
	if err != nil {
		log.Printf(`Cannot create file %s`, err)
		return err
	}

	rows.Next()
	err = rows.Scan(&insertedFileId)
	if err != nil {
		tx.Rollback()
		return err
	}
	rows.Close()

	query = `INSERT INTO summary (file_id, data, embedding) VALUES ($1, $2, $3)`
	_, err = tx.Exec(query, insertedFileId, file.Summary.Data, file.Summary.Embedding)
	if err != nil {
		log.Printf(`Cannot create summary: %s`, err)
		tx.Rollback()
		return err
	}

	query = `INSERT INTO description (file_id, data, embedding) VALUES ($1, $2, $3)`
	_, err = tx.Exec(query, insertedFileId, file.Description.Data, file.Description.Embedding)
	if err != nil {
		log.Printf(`Cannot create summary %s`, err)
		tx.Rollback()
		return err
	}

	err = tx.Commit()
	if err != nil {
		log.Printf(`Cannot commit: %s`, err)
		return err
	}

	return nil
}

func (r *PostgresArchiveRepository) GetFileByID(id uuid.UUID) (*types.File, error) {
	file := &types.File{}
	summary := &types.Summary{}
	description := &types.Description{}
	storageLocation := &types.StorageLocation{}
	storage := &types.Storage{}

	query := `SELECT * FROM file WHERE id = $1`
	err := r.DB.Get(file, query, id)
	if err != nil {
		log.Printf("Cannot get file: %s", err)
		return nil, err
	}

	query = `SELECT * FROM summary WHERE file_id = $1`
	err = r.DB.Get(summary, query, file.ID)
	if err != nil {
		log.Printf("Cannot get summary: %s", err)
	}

	query = `SELECT * FROM description WHERE file_id = $1`
	err = r.DB.Get(description, query, file.ID)
	if err != nil {
		log.Printf("Cannot get description: %s", err)
	}

	query = `SELECT * FROM storage_location WHERE file_id = $1`
	err = r.DB.Get(storageLocation, query, file.ID)
	if err != nil {
		log.Printf("Cannot get storage location: %s", err)
	}

	query = `SELECT * FROM storage WHERE id = $1`
	err = r.DB.Get(storage, query, storageLocation.StorageID)
	if err != nil {
		log.Printf("Cannot get storage: %s", err)
	}

	file.Summary = summary
	file.Description = description
	storageLocation.Storage = storage
	file.StorageLocation = storageLocation

	return file, nil
}

func (r *PostgresArchiveRepository) EditSummary(summary *types.Summary) error {
	query := `UPDATE summary SET file_id=:file_ud, data = :data, embedding = :embedding, updated_at = now() WHERE id = :id`
	_, err := r.DB.NamedExec(query, summary)
	if err != nil {
		log.Printf("Cannot edit summary: %s", err)
		return err
	}
	return nil
}
