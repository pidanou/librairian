package service

import (
	"fmt"

	storage_go "github.com/supabase-community/storage-go"
)

type ObjectStorer interface {
	GetImage(bucket, path string) ([]byte, error)
}

// Supabase implenementation
type SupabaseObjectStorageService struct {
	StorageClient *storage_go.Client
}

func NewSupabaseImageStorageService(projectID string, serviceKey string) *SupabaseObjectStorageService {

	url := fmt.Sprintf("https://%s.supabase.co/storage/v1", projectID)

	storageClient := storage_go.NewClient(url, serviceKey, nil)

	return &SupabaseObjectStorageService{
		StorageClient: storageClient,
	}
}

func (r *SupabaseObjectStorageService) GetImage(bucket, path string) ([]byte, error) {
	return r.StorageClient.DownloadFile(bucket, path)
}
