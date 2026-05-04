package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type WatermarkRequest struct {
	Filename string `json:"filename"`
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func watermarkHandler(ctx context.Context, rawMessage json.RawMessage) error {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Printf("Failed to load AWS SDK config: %v", err)
		return err
	}

	var req WatermarkRequest
	if err := json.Unmarshal(rawMessage, &req); err != nil {
		log.Printf("Failed to unmarshal event: %v", err)
		return err
	}

	s3c := s3.NewFromConfig(cfg, func(opts *s3.Options) {
		v := getEnv("AWS_USE_PATH_STYLE_ENDPOINT", "false")
		if strings.ToLower(v) == "true" {
			opts.UsePathStyle = true
		}
	})

	sourceBucket := getEnv("SOURCE_BUCKET", "convert-results")
	resp, err := s3c.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(sourceBucket),
		Key:    aws.String(req.Filename),
	})
	if err != nil {
		log.Printf("Failed to read from source bucket %s/%s: %v", sourceBucket, req.Filename, err)
		return err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Printf("Failed to read object body: %v", err)
		return err
	}

	timestamp := time.Now().UTC().Format("20060102_150405")
	destKey := fmt.Sprintf("watermarks/%s_%s.txt", strings.TrimSuffix(req.Filename, ".txt"), timestamp)
	watermarked := string(body) + "Watermarked\n"

	destBucket := getEnv("S3_BUCKET", "watermark-results")
	if _, err := s3c.PutObject(ctx, &s3.PutObjectInput{
		Bucket:      aws.String(destBucket),
		Key:         aws.String(destKey),
		Body:        bytes.NewReader([]byte(watermarked)),
		ContentType: aws.String("text/plain"),
	}); err != nil {
		log.Printf("s3 upload error: %v", err)
		return err
	}

	log.Printf("file watermarked and saved to S3: %s", destKey)
	return nil
}

func main() {
	lambda.Start(watermarkHandler)
}
