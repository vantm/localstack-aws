package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type ConvertRequest struct {
	Name string `json:"name"`
	Age  int    `json:"age"`
}

type ConvertResponse struct {
	Message  string `json:"message"`
	FileName string `json:"file_name"`
}

type AppConfig struct {
	Region   string
	Profile  string
	Endpoint string
	Bucket   string
}

func loadConfig() AppConfig {
	return AppConfig{
		Region:   getEnv("AWS_REGION", "us-east-1"),
		Profile:  getEnv("AWS_PROFILE", ""),
		Endpoint: os.Getenv("AWS_ENDPOINT"),
		Bucket:   getEnv("S3_BUCKET", "convert-app-files"),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func newS3Client(cfg AppConfig) (*s3.Client, error) {
	loadOpts := []func(*config.LoadOptions) error{
		config.WithRegion(cfg.Region),
	}
	if cfg.Profile != "" {
		loadOpts = append(loadOpts, config.WithSharedConfigProfile(cfg.Profile))
	}

	awsCfg, err := config.LoadDefaultConfig(context.Background(), loadOpts...)
	if err != nil {
		return nil, fmt.Errorf("load aws config: %w", err)
	}

	opts := []func(*s3.Options){}
	if cfg.Endpoint != "" {
		opts = append(opts, func(o *s3.Options) {
			o.BaseEndpoint = aws.String(cfg.Endpoint)
			o.UsePathStyle = true
		})
	}

	return s3.NewFromConfig(awsCfg, opts...), nil
}

func convertHandler(s3c *s3.Client, bucket string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}

		var req ConvertRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid JSON: "+err.Error(), http.StatusBadRequest)
			return
		}

		timestamp := time.Now().UTC().Format("20060102_150405")
		fileName := fmt.Sprintf("conversions/%s_%s.txt", req.Name, timestamp)
		content := fmt.Sprintf("Name: %s\nAge: %d\nConverted: %s\n", req.Name, req.Age, time.Now().UTC().Format(time.RFC3339))

		_, err := s3c.PutObject(context.Background(), &s3.PutObjectInput{
			Bucket:      aws.String(bucket),
			Key:         aws.String(fileName),
			Body:        bytes.NewReader([]byte(content)),
			ContentType: aws.String("text/plain"),
		})
		if err != nil {
			log.Printf("s3 upload error: %v", err)
			http.Error(w, "failed to upload file", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(ConvertResponse{
			Message:  "file saved to S3",
			FileName: fileName,
		})
	}
}

func main() {
	cfg := loadConfig()

	s3c, err := newS3Client(cfg)
	if err != nil {
		log.Fatalf("failed to create S3 client: %v", err)
	}

	log.Printf("S3 bucket: %s, region: %s, profile: %s, endpoint: %s", cfg.Bucket, cfg.Region, cfg.Profile, cfg.Endpoint)

	http.HandleFunc("/convert", convertHandler(s3c, cfg.Bucket))
	log.Fatal(http.ListenAndServe(":5001", nil))
}
