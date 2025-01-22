package service

import (
	"context"
	b64 "encoding/base64"
	"fmt"
	"log"
	"net/http"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

// Generate captions of an image
type IImageCaptionService interface {
	CreateCaption(image []byte) (string, error)
}

// GCP implementation
type ImageCaptionService struct {
	URL        string
	ProjectID  string
	Location   string
	HttpClient *http.Client
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

func NewImageCaptionsService(projectID string, jsonCred string, location string) *ImageCaptionService {
	sDec, err := b64.StdEncoding.DecodeString(jsonCred)
	if err != nil {
		log.Fatal(err)
	}

	ctx := context.Background()
	creds, err := google.CredentialsFromJSON(ctx, []byte(sDec), "https://www.googleapis.com/auth/cloud-platform")
	if err != nil {
		log.Fatal(err)
	}
	httpClient := oauth2.NewClient(ctx, creds.TokenSource)
	url := fmt.Sprintf(
		"https://%s-aiplatform.googleapis.com/v1/projects/%s/locations/%s/publishers/google/models/imagetext:predict",
		location,
		projectID,
		location,
	)
	return &ImageCaptionService{URL: url, ProjectID: projectID, Location: location, HttpClient: httpClient}
}

// Will add captions later
func (r *ImageCaptionService) CreateCaption(image []byte) (string, error) {
	// base64Image := b64.StdEncoding.EncodeToString(image)
	//
	// imageCaptionRequest := ImageCaptionRequest{
	// 	Instances: []ImageInstance{
	// 		{
	// 			Image: ImageData{
	// 				BytesBase64Encoded: base64Image,
	// 			},
	// 		},
	// 	},
	// 	Parameters: Parameters{
	// 		SampleCount: 1,
	// 		Language:    "fr",
	// 	},
	// }
	//
	// jsonData, err := json.Marshal(imageCaptionRequest)
	// if err != nil {
	// 	fmt.Println(err)
	// 	return "", fmt.Errorf("failed to marshal image caption request: %v", err)
	// }
	//
	// req, err := http.NewRequest("POST", r.URL, bytes.NewBuffer(jsonData))
	// if err != nil {
	// 	fmt.Println(err)
	// 	return "", fmt.Errorf("failed to create HTTP request: %v", err)
	// }
	//
	// req.Header.Set("Content-Type", "application/json")
	//
	// resp, err := r.HttpClient.Do(req)
	// if err != nil {
	// 	fmt.Println(err)
	// 	return "", fmt.Errorf("failed to send HTTP request: %v", err)
	// }
	// defer resp.Body.Close()
	//
	// bodyBytes, err := io.ReadAll(resp.Body)
	// if err != nil {
	// 	return "", fmt.Errorf("failed to read response body: %v", err)
	// }
	//
	// var result map[string]interface{}
	// if err := json.Unmarshal(bodyBytes, &result); err != nil {
	// 	return "", fmt.Errorf("failed to parse response body: %v", err)
	// }
	//
	// predictions, ok := result["predictions"].([]interface{})
	// if !ok || len(predictions) == 0 {
	// 	return "", fmt.Errorf("no predictions found in response")
	// }
	//
	// caption, ok := predictions[0].(string)
	// if !ok {
	// 	return "", fmt.Errorf("failed to extract caption from prediction")
	// }

	return "", nil
}
