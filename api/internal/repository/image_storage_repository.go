package repository

import (
	"fmt"

	storage_go "github.com/supabase-community/storage-go"
)

type SupabaseImageArchiveRepository struct {
	StorageClient *storage_go.Client
}

func NewSupabaseImageArchiveRepository(projectID string, serviceKey string) *SupabaseImageArchiveRepository {

	url := fmt.Sprintf("https://%s.supabase.co/storage/v1", projectID)

	storageClient := storage_go.NewClient(url, serviceKey, nil)

	return &SupabaseImageArchiveRepository{
		StorageClient: storageClient,
	}
}

func (r *SupabaseImageArchiveRepository) GetImage(bucket, path string) ([]byte, error) {
	return r.StorageClient.DownloadFile(bucket, path)
}
