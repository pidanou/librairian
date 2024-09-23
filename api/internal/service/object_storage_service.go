package service

import (
	"bytes"
	"fmt"

	storage_go "github.com/supabase-community/storage-go"
)

type IObjectStorageService interface {
	GetImage(bucket, path string) ([]byte, error)
	UploadImage(bucket string, path string, body []byte) error
}

// Supabase implenementation
type ObjectStorageService struct {
	StorageClient *storage_go.Client
}

func NewSupabaseImageStorageService(projectID string, serviceKey string) *ObjectStorageService {

	url := fmt.Sprintf("https://%s.supabase.co/storage/v1", projectID)

	storageClient := storage_go.NewClient(url, serviceKey, nil)

	return &ObjectStorageService{
		StorageClient: storageClient,
	}
}

func (r *ObjectStorageService) GetImage(bucket, path string) ([]byte, error) {
	return r.StorageClient.DownloadFile(bucket, path)
}

func (r *ObjectStorageService) UploadImage(bucket string, path string, body []byte) error {
	_, err := r.StorageClient.UploadFile(bucket, path, bytes.NewReader(body))
	if err != nil {
		return err
	}
	return nil
}
