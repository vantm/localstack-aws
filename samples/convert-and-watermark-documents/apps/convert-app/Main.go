package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"

	"github.com/aws/aws-lambda-go/lambda"
)

type ConvertRequest struct {
	Name string `json:"name"`
	Age  int    `json:"age"`
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func convertHandler(ctx context.Context, event json.RawMessage) error {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Printf("Failed to load AWS SDK config: %v", err)
		return err
	}

	var req ConvertRequest
	if err := json.Unmarshal(event, &req); err != nil {
		log.Printf("Failed to unmarshal event: %v", err)
		return err
	}

	timestamp := time.Now().UTC().Format("20060102_150405")
	fileName := fmt.Sprintf("conversions/%s_%s.txt", req.Name, timestamp)
	content := fmt.Sprintf("Name: %s\nAge: %d\nConverted: %s\n", req.Name, req.Age, time.Now().UTC().Format(time.RFC3339))

	s3c := s3.NewFromConfig(cfg, func(opts *s3.Options) {
		v := getEnv("AWS_USE_PATH_STYLE_ENDPOINT", "false")
		if strings.ToLower(v) == "true" {
			opts.UsePathStyle = true
		}
	})

	bucket := getEnv("S3_BUCKET", "convert-results")
	if _, err := s3c.PutObject(ctx, &s3.PutObjectInput{
		Bucket:      aws.String(bucket),
		Key:         aws.String(fileName),
		Body:        bytes.NewReader([]byte(content)),
		ContentType: aws.String("text/plain"),
	}); err != nil {
		log.Printf("s3 upload error: %v", err)
		return err
	}

	log.Printf("file saved to S3")
	return nil
}

func main() {
	lambda.Start(convertHandler)
}
