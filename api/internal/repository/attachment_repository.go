package repository

import (
	"database/sql"
	"errors"
	"log"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/pidanou/librairian/internal/types"
)

type PostgresAttachmentRepository struct {
	DB *sqlx.DB
}

func NewPostgresAttachmentRepository(db *sqlx.DB) *PostgresAttachmentRepository {
	return &PostgresAttachmentRepository{DB: db}
}

func (r *PostgresAttachmentRepository) GetAttachmentByID(id *uuid.UUID) (*types.Attachment, error) {
	attachment := &types.Attachment{}
	query := `SELECT * FROM attachment WHERE id = $1`
	err := r.DB.Get(attachment, query, id)
	if err != nil {
		log.Printf(`Cannot get attachment by id %s`, err)
		return nil, err
	}
	return attachment, nil
}

func (r *PostgresAttachmentRepository) GetItemAttachments(id *uuid.UUID) ([]types.Attachment, error) {
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

func (r *PostgresAttachmentRepository) AddAttachments(attachments []types.Attachment) ([]types.Attachment, error) {
	insertedAttachments := []types.Attachment{}
	query := `INSERT INTO attachment (user_id, created_at, updated_at, item_id, path, captions, captions_embeddings, size) 
  VALUES (:user_id, now(), now(), :item_id, :path, :captions, :captions_embeddings, :size) RETURNING *`

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

	return insertedAttachments, nil
}

func (r *PostgresAttachmentRepository) DeleteAttachmentByID(id *uuid.UUID) error {
	query := `DELETE FROM attachment WHERE id = $1`
	_, err := r.DB.Exec(query, id)
	if err != nil {
		log.Printf(`Cannot delete attachment %s`, err)
	}
	return err
}
