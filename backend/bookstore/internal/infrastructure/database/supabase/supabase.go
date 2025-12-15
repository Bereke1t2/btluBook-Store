package supabase



import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
)
type SupabaseClient struct {
	BaseURL   string
	AnonKey   string
}
func NewSupabaseClient(baseURL, anonKey string) *SupabaseClient {
	return &SupabaseClient{
		BaseURL:   baseURL,
		AnonKey:   anonKey,
	}
}

// Upload file to Supabase Storage
func (c *SupabaseClient) UploadToSupabase(filePath, fileName , bucketName string) (string, error) {
	print("Uploading to Supabase Storage...")
	// Read file data
	fileData, err := os.ReadFile(filePath)
	if err != nil {
		return "", fmt.Errorf("failed to read file: %v", err)
	}

	// Create upload URL
	uploadURL := fmt.Sprintf("%s/storage/v1/object/%s/%s", c.BaseURL, bucketName, fileName)
	anonKey := c.AnonKey
	// Create HTTP request
	req, err := http.NewRequest("POST", uploadURL, bytes.NewReader(fileData))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %v", err)
	}

	// Set headers
	req.Header.Set("Authorization", "Bearer "+anonKey)
	req.Header.Set("Content-Type", "application/octet-stream")
	req.Header.Set("Cache-Control", "no-cache")

	// Send request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to upload: %v", err)
	}
	defer resp.Body.Close()

	// Check response
	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("upload failed (%d): %s", resp.StatusCode, string(body))
	}

	// Generate public URL for accessing the file
	publicURL := fmt.Sprintf("%s/storage/v1/object/public/%s/%s", c.BaseURL, bucketName, fileName)

	log.Printf("✅ File uploaded successfully!")
	log.Printf("📁 Public URL: %s", publicURL)

	return publicURL, nil
}

// Download file from Supabase Storage
func (c *SupabaseClient) DownloadFromSupabase(fileURL, savePath string) error {
	// Create HTTP request
	req, err := http.NewRequest("GET", fileURL, nil)
	if err != nil {
		return fmt.Errorf("failed to create request: %v", err)
	}

	// Send request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to download: %v", err)
	}
	defer resp.Body.Close()

	// Check response
	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("download failed (%d): %s", resp.StatusCode, string(body))
	}

	// Create directory if it doesn't exist
	dir := filepath.Dir(savePath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create directory: %v", err)
	}

	// Create file
	file, err := os.Create(savePath)
	if err != nil {
		return fmt.Errorf("failed to create file: %v", err)
	}
	defer file.Close()

	// Copy response body to file
	_, err = io.Copy(file, resp.Body)
	if err != nil {
		return fmt.Errorf("failed to save file: %v", err)
	}

	log.Printf("✅ File downloaded successfully!")
	log.Printf("📁 Saved to: %s", savePath)

	return nil
}

// Download by file name (alternative method)
func (c *SupabaseClient) DownloadFileByName(fileName, bucketName, savePath string) error {
	// Generate public URL
	fileURL := fmt.Sprintf("%s/storage/v1/object/public/%s/%s", c.BaseURL, bucketName, fileName)

	return c.DownloadFromSupabase(fileURL, savePath)
}

// List files in a bucket (optional)
func (c *SupabaseClient) ListFilesInBucket(bucketName string) ([]string, error) {
	supabaseURL := c.BaseURL
	anonKey := c.AnonKey
	// Create list URL
	listURL := fmt.Sprintf("%s/storage/v1/object/list/%s", supabaseURL, bucketName)
	
	// Create HTTP request
	req, err := http.NewRequest("POST", listURL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %v", err)
	}

	// Set headers
	req.Header.Set("Authorization", "Bearer "+anonKey)
	req.Header.Set("Content-Type", "application/json")

	// Send request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to list files: %v", err)
	}
	defer resp.Body.Close()

	// Parse response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %v", err)
	}

	log.Printf("📁 Files in bucket '%s': %s", bucketName, string(body))
	
	// Note: You would need to parse the JSON response properly
	// This returns the raw response for simplicity
	return []string{string(body)}, nil
}