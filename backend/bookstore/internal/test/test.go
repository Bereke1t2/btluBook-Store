package test

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"
)

// DebugSetup tests Supabase connection
func DebugSetup() {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		log.Printf("⚠️ Could not load .env file: %v", err)
	}

	supabaseURL := os.Getenv("SUPABASE_URL")
	anonKey := os.Getenv("SUPABASE_API_KEY")
	serviceKey := os.Getenv("SUPABASE_SERVICE_KEY")

	fmt.Println("=== DEBUG SETUP ===")
	
	if supabaseURL == "" {
		log.Println("❌ SUPABASE_URL is empty!")
	} else {
		fmt.Printf("✅ Project URL: %s\n", supabaseURL)
	}
	
	if anonKey == "" {
		log.Println("❌ SUPABASE_API_KEY is empty!")
	} else {
		fmt.Printf("✅ Anon Key: %s...\n", SafeSubstring(anonKey, 20))
		fmt.Printf("✅ Anon Key starts with 'eyJ': %v\n", len(anonKey) >= 3 && anonKey[:3] == "eyJ")
	}

	if serviceKey == "" {
		log.Println("❌ SUPABASE_SERVICE_KEY is empty!")
	} else {
		fmt.Printf("✅ Service Key: %s...\n", SafeSubstring(serviceKey, 20))
		fmt.Printf("✅ Service Key starts with 'eyJ': %v\n", len(serviceKey) >= 3 && serviceKey[:3] == "eyJ")
	}
	
	fmt.Printf("✅ URL format correct: %v\n", len(supabaseURL) > 10)
	fmt.Println("=== =========== ===")

	// Test connection
	if supabaseURL != "" && anonKey != "" {
		testConnection(supabaseURL, anonKey)
	}
}

func testConnection(supabaseURL, anonKey string) {
	// Test by listing buckets
	testURL := fmt.Sprintf("%s/storage/v1/bucket", supabaseURL)
	req, err := http.NewRequest("GET", testURL, nil)
	if err != nil {
		log.Printf("❌ Connection test failed to create request: %v", err)
		return
	}
	
	req.Header.Set("Authorization", "Bearer "+anonKey)
	
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("❌ Connection test failed: %v", err)
		return
	}
	defer resp.Body.Close()
	
	log.Printf("✅ Connection test: SUCCESS (%d)", resp.StatusCode)
}

// TestUpload tests file upload with ANON key
func TestUpload() error {
	if err := godotenv.Load(); err != nil {
		return fmt.Errorf("load .env: %v", err)
	}

	supabaseURL := os.Getenv("SUPABASE_URL")
	apiKey := os.Getenv("SUPABASE_API_KEY") // Using ANON key
	bucketName := "books"

	if supabaseURL == "" || apiKey == "" {
		return fmt.Errorf("supabase credentials not found in environment")
	}

	log.Println("🔄 Testing upload with ANON KEY...")

	// Create a test file
	testContent := []byte("This is a test file content for Supabase upload with ANON key")
	testFilePath := "./test-upload-file.txt"
	
	if err := os.WriteFile(testFilePath, testContent, 0644); err != nil {
		return fmt.Errorf("create test file: %v", err)
	}
	defer os.Remove(testFilePath)

	// Upload the file
	fileURL, err := UploadToSupabase(supabaseURL, apiKey, bucketName, testFilePath, "test-upload.txt")
	if err != nil {
		return fmt.Errorf("anon key upload failed: %v", err)
	}

	log.Printf("✅ Anon key upload successful!")
	log.Printf("📁 File URL: %s", fileURL)
	return nil
}

// TestUploadWithServiceKey uses service_role key to bypass RLS
func TestUploadWithServiceKey() error {
	if err := godotenv.Load(); err != nil {
		return fmt.Errorf("load .env: %v", err)
	}

	supabaseURL := os.Getenv("SUPABASE_URL")
	serviceKey := os.Getenv("SUPABASE_SERVICE_KEY") // Use service key
	bucketName := "books"

	if supabaseURL == "" || serviceKey == "" {
		return fmt.Errorf("supabase URL or service key not found in environment")
	}

	log.Println("🔄 Testing upload with SERVICE KEY...")
	log.Printf("🔑 Using service key: %s...", SafeSubstring(serviceKey, 20))

	// Create test file
	testContent := []byte("Test upload with service role key - should bypass RLS!")
	testFilePath := "./test-service-upload.txt"
	
	if err := os.WriteFile(testFilePath, testContent, 0644); err != nil {
		return fmt.Errorf("create test file: %v", err)
	}
	defer os.Remove(testFilePath)

	// Upload using service key
	fileURL, err := UploadToSupabase(supabaseURL, serviceKey, bucketName, testFilePath, "service-test.txt")
	if err != nil {
		return fmt.Errorf("service key upload failed: %v", err)
	}

	log.Printf("✅ Service key upload successful!")
	log.Printf("📁 File URL: %s", fileURL)
	return nil
}

// UploadToSupabaseWithKey allows specifying which key to use
func UploadToSupabaseWithKey(useServiceKey bool, bucketName, filePath, fileName string) (string, error) {
	if err := godotenv.Load(); err != nil {
		return "", fmt.Errorf("load .env: %v", err)
	}

	supabaseURL := os.Getenv("SUPABASE_URL")
	var apiKey string

	if useServiceKey {
		apiKey = os.Getenv("SUPABASE_SERVICE_KEY")
		log.Printf("🔑 Using SERVICE ROLE key")
	} else {
		apiKey = os.Getenv("SUPABASE_API_KEY") 
		log.Printf("🔑 Using ANON key")
	}

	if supabaseURL == "" || apiKey == "" {
		return "", fmt.Errorf("credentials not found")
	}

	return UploadToSupabase(supabaseURL, apiKey, bucketName, filePath, fileName)
}

// UploadToSupabase uploads a file to Supabase Storage
func UploadToSupabase(supabaseURL, apiKey, bucketName, filePath, fileName string) (string, error) {
	// Read file data
	fileData, err := os.ReadFile(filePath)
	if err != nil {
		return "", fmt.Errorf("read file: %v", err)
	}

	// Create upload URL
	uploadURL := fmt.Sprintf("%s/storage/v1/object/%s/%s", supabaseURL, bucketName, fileName)
	
	log.Printf("📤 Uploading to: %s", uploadURL)
	log.Printf("📦 Bucket: %s", bucketName)
	log.Printf("📄 File: %s", fileName)

	// Create HTTP request
	req, err := http.NewRequest("POST", uploadURL, bytes.NewReader(fileData))
	if err != nil {
		return "", fmt.Errorf("create request: %v", err)
	}

	// Set headers
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/octet-stream")
	req.Header.Set("Cache-Control", "no-cache")

	// Send request with timeout
	client := &http.Client{
		Timeout: 30 * time.Second,
	}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("send request: %v", err)
	}
	defer resp.Body.Close()

	// Read response body
	body, _ := io.ReadAll(resp.Body)
	
	log.Printf("📨 Response status: %d", resp.StatusCode)
	
	// Check response
	if resp.StatusCode != 200 {
		// Try to parse error message
		var errorResp map[string]interface{}
		if err := json.Unmarshal(body, &errorResp); err == nil {
			if msg, ok := errorResp["message"].(string); ok {
				return "", fmt.Errorf("upload failed (%d): %s", resp.StatusCode, msg)
			}
		}
		return "", fmt.Errorf("upload failed (%d): %s", resp.StatusCode, string(body))
	}

	// Generate public URL
	publicURL := fmt.Sprintf("%s/storage/v1/object/public/%s/%s", supabaseURL, bucketName, fileName)
	log.Printf("✅ Upload successful!")
	log.Printf("🔗 Public URL: %s", publicURL)
	
	return publicURL, nil
}

// ListBuckets lists available storage buckets
func ListBuckets() error {
	if err := godotenv.Load(); err != nil {
		return fmt.Errorf("load .env: %v", err)
	}
	
	supabaseURL := os.Getenv("SUPABASE_URL")
	apiKey := os.Getenv("SUPABASE_API_KEY")

	if supabaseURL == "" || apiKey == "" {
		return fmt.Errorf("credentials not found")
	}

	url := fmt.Sprintf("%s/storage/v1/bucket", supabaseURL)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return err
	}

	req.Header.Set("Authorization", "Bearer "+apiKey)
	
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	
	if resp.StatusCode == 200 {
		log.Printf("📦 Available buckets: %s", string(body))
	} else {
		log.Printf("❌ Failed to list buckets (%d): %s", resp.StatusCode, string(body))
	}
	
	return nil
}

// CreateBucket creates a new bucket (admin function)
func CreateBucket(bucketName string) error {
	if err := godotenv.Load(); err != nil {
		return fmt.Errorf("load .env: %v", err)
	}
	
	supabaseURL := os.Getenv("SUPABASE_URL")
	serviceKey := os.Getenv("SUPABASE_SERVICE_KEY")

	if serviceKey == "" {
		return fmt.Errorf("service role key required for bucket creation")
	}

	url := fmt.Sprintf("%s/storage/v1/bucket", supabaseURL)
	
	body, _ := json.Marshal(map[string]interface{}{
		"name":  bucketName,
		"public": true,
	})

	req, err := http.NewRequest("POST", url, bytes.NewReader(body))
	if err != nil {
		return err
	}

	req.Header.Set("Authorization", "Bearer "+serviceKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	body, _ = io.ReadAll(resp.Body)
	
	if resp.StatusCode == 200 {
		log.Printf("✅ Bucket '%s' created successfully!", bucketName)
	} else {
		log.Printf("❌ Failed to create bucket (%d): %s", resp.StatusCode, string(body))
	}
	
	return nil
}

// SafeSubstring safely gets substring without panic
func SafeSubstring(s string, length int) string {
	if len(s) <= length {
		return s
	}
	return s[:length]
}