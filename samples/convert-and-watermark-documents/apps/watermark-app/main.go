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

	"github.com/aws/aws-lambda-go/events"
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

func watermarkHandler(ctx context.Context, sqsEvent events.SQSEvent) (events.SQSEventResponse, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Printf("Failed to load AWS SDK config: %v", err)
		return events.SQSEventResponse{}, err
	}

	s3c := s3.NewFromConfig(cfg, func(opts *s3.Options) {
		v := getEnv("AWS_USE_PATH_STYLE_ENDPOINT", "false")
		if strings.ToLower(v) == "true" {
			opts.UsePathStyle = true
		}
	})

	sourceBucket := getEnv("S3_BUCKET_0", "convert-results")
	destBucket := getEnv("S3_BUCKET_1", "watermark-results")

	var batchItemFailures []events.SQSBatchItemFailure

	for _, record := range sqsEvent.Records {
		var req WatermarkRequest
		if err := json.Unmarshal([]byte(record.Body), &req); err != nil {
			log.Printf("Failed to unmarshal SQS message %s: %v", record.MessageId, err)
			batchItemFailures = append(batchItemFailures, events.SQSBatchItemFailure{
				ItemIdentifier: record.MessageId,
			})
			continue
		}

		resp, err := s3c.GetObject(ctx, &s3.GetObjectInput{
			Bucket: aws.String(sourceBucket),
			Key:    aws.String(req.Filename),
		})
		if err != nil {
			log.Printf("Failed to read from source bucket %s/%s: %v", sourceBucket, req.Filename, err)
			batchItemFailures = append(batchItemFailures, events.SQSBatchItemFailure{
				ItemIdentifier: record.MessageId,
			})
			continue
		}

		body, readErr := io.ReadAll(resp.Body)
		resp.Body.Close()
		if readErr != nil {
			log.Printf("Failed to read object body: %v", readErr)
			batchItemFailures = append(batchItemFailures, events.SQSBatchItemFailure{
				ItemIdentifier: record.MessageId,
			})
			continue
		}

		timestamp := time.Now().UTC().Format("20060102_150405")
		destKey := fmt.Sprintf("watermarks/%s_%s.txt", strings.TrimSuffix(req.Filename, ".txt"), timestamp)
		watermarked := string(body) + "Watermarked\n"

		if _, err := s3c.PutObject(ctx, &s3.PutObjectInput{
			Bucket:      aws.String(destBucket),
			Key:         aws.String(destKey),
			Body:        bytes.NewReader([]byte(watermarked)),
			ContentType: aws.String("text/plain"),
		}); err != nil {
			log.Printf("s3 upload error: %v", err)
			batchItemFailures = append(batchItemFailures, events.SQSBatchItemFailure{
				ItemIdentifier: record.MessageId,
			})
			continue
		}

		log.Printf("file watermarked and saved to S3: %s", destKey)
	}

	return events.SQSEventResponse{BatchItemFailures: batchItemFailures}, nil
}

func main() {
	lambda.Start(watermarkHandler)
}
