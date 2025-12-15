package firbase

import (
	"context"
	"io"
	"log"
	"net/url"
	"os"

	firebase "firebase.google.com/go"
	"github.com/google/uuid"
	"google.golang.org/api/option"
)


func InitFirebaseApp(ctx context.Context, credFilePath string) (firebase.App, error) {
	opt := option.WithCredentialsFile(credFilePath)
	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		log.Fatalf("error initializing firebase app: %v", err)
		return firebase.App{}, err
	}
	return *app, nil
}


func UploadFileToFirebaseStorage(ctx context.Context, app *firebase.App, bucketName, objectName, filePath string) (string, error) {
	client, err := app.Storage(ctx)
	if err != nil {
		log.Fatalf("error getting Storage client: %v", err)
		return "", err
	}

	bucket, err := client.Bucket(bucketName)
	if err != nil {
		log.Fatalf("error getting bucket: %v", err)
		return "", err
	}

	wc := bucket.Object(objectName).NewWriter(ctx)
	defer wc.Close()

	// Generate a download token and set it in metadata so we can construct a public URL
	token := uuid.NewString()
	if wc.ObjectAttrs.Metadata == nil {
		wc.ObjectAttrs.Metadata = map[string]string{}
	}
	wc.ObjectAttrs.Metadata["firebaseStorageDownloadTokens"] = token

	// Open the file to be uploaded
	file, err := os.Open(filePath)
	if err != nil {
		log.Fatalf("error opening file: %v", err)
		return "", err
	}
	defer file.Close()

	// Copy the file content to the writer
	if _, err := io.Copy(wc, file); err != nil {
		log.Fatalf("error uploading file to Firebase Storage: %v", err)
		return "", err
	}

	// Build the Firebase Storage download URL
	escapedObject := url.QueryEscape(objectName)
	url := "https://firebasestorage.googleapis.com/v0/b/" + bucketName + "/o/" + escapedObject + "?alt=media&token=" + token

	log.Printf("File %s uploaded to Firebase Storage bucket %s as %s", filePath, bucketName, objectName)
	return url, nil
}

func DownloadFileFromFirebaseStorage(ctx context.Context, app *firebase.App, bucketName, objectName, destFilePath string) (string , error) {
	client, err := app.Storage(ctx)
	if err != nil {
		log.Fatalf("error getting Storage client: %v", err)
		return "", err
	}

	bucket, err := client.Bucket(bucketName)
	if err != nil {
		log.Fatalf("error getting bucket: %v", err)
		return "", err
	}

	rc, err := bucket.Object(objectName).NewReader(ctx)
	if err != nil {
		log.Fatalf("error creating reader for object: %v", err)
		return "", err
	}
	defer rc.Close()

	// Create the destination file
	destFile, err := os.Create(destFilePath)
	if err != nil {
		log.Fatalf("error creating destination file: %v", err)
		return "", err
	}
	defer destFile.Close()

	// Copy the content from the reader to the destination file
	if _, err := io.Copy(destFile, rc); err != nil {
		log.Fatalf("error downloading file from Firebase Storage: %v", err)
		return "", err
	}

	log.Printf("File %s downloaded from Firebase Storage bucket %s to %s", objectName, bucketName, destFilePath)
	return destFilePath, nil
}