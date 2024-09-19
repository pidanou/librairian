package repository

import (
	"fmt"

	storage_go "github.com/supabase-community/storage-go"
)

type SupabaseImageStorageRepository struct {
	StorageClient *storage_go.Client
}

func NewSupabaseImageStorageRepository(projectID string, serviceKey string) *SupabaseImageStorageRepository {

	url := fmt.Sprintf("https://%s.supabase.co/storage/v1", projectID)

	storageClient := storage_go.NewClient(url, serviceKey, nil)

	return &SupabaseImageStorageRepository{
		StorageClient: storageClient,
	}
}

func (r *SupabaseImageStorageRepository) GetImage(bucket, path string) ([]byte, error) {
	return r.StorageClient.DownloadFile(bucket, path)
}
