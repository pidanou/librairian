package service

import (
	"bytes"
	"fmt"

	storage_go "github.com/supabase-community/storage-go"
)

type IObjectArchiveService interface {
	GetImage(bucket, path string) ([]byte, error)
	UploadImage(bucket string, path string, body []byte) error
}

// Supabase implenementation
type ObjectArchiveService struct {
	StorageClient *storage_go.Client
}

func NewSupabaseImageArchiveService(projectID string, serviceKey string) *ObjectArchiveService {

	url := fmt.Sprintf("https://%s.supabase.co/storage/v1", projectID)

	storageClient := storage_go.NewClient(url, serviceKey, nil)

	return &ObjectArchiveService{
		StorageClient: storageClient,
	}
}

func (r *ObjectArchiveService) GetImage(bucket, path string) ([]byte, error) {
	return r.StorageClient.DownloadFile(bucket, path)
}

func (r *ObjectArchiveService) UploadImage(bucket string, path string, body []byte) error {
	_, err := r.StorageClient.UploadFile(bucket, path, bytes.NewReader(body))
	if err != nil {
		return err
	}
	return nil
}
