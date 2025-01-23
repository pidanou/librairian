package service

import (
	"fmt"
	"log"

	b64 "encoding/base64"

	"github.com/supabase-community/supabase-go"
)

// Generate captions of an image
type IImageCaptionService interface {
	CreateCaption(image []byte) (string, error)
}

// GCP implementation
type ImageCaptionService struct {
	Client *supabase.Client
}

type ImageData struct {
	BytesBase64Encoded string `json:"bytesBase64Encoded"`
}

type ImageInstance struct {
	Image ImageData `json:"image"`
}

type Parameters struct {
	SampleCount int    `json:"sampleCount"`
	Language    string `json:"language"`
}

type ImageCaptionRequest struct {
	Instances  []ImageInstance `json:"instances"`
	Parameters Parameters      `json:"parameters"`
}

func NewImageCaptionsService(API_URL, API_KEY string) *ImageCaptionService {
	client, err := supabase.NewClient(API_URL, API_KEY, &supabase.ClientOptions{})
	if err != nil {
		log.Panic("cannot initalize client", err)
	}
	return &ImageCaptionService{
		Client: client,
	}
}

// Will add captions later
func (r *ImageCaptionService) CreateCaption(image []byte) (string, error) {
	base64Image := b64.StdEncoding.EncodeToString(image)

	imageCaptionRequest := map[string]interface{}{"bytes": base64Image}

	resp, err := r.Client.Functions.Invoke("generate-captions", imageCaptionRequest)
	if err != nil {
		fmt.Println(err)
		return "", fmt.Errorf("failed to send HTTP request: %v", err)
	}

	return resp, nil
}
