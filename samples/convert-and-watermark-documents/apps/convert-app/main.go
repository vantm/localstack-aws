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

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

type ConvertRequest struct {
	Name string `json:"name"`
	Age  int    `json:"age"`
}

type WatermarkRequest struct {
	Filename string `json:"filename"`
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func convertHandler(ctx context.Context, rawMessage json.RawMessage) error {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Printf("Failed to load AWS SDK config: %v", err)
		return err
	}

	var req ConvertRequest
	if err := json.Unmarshal(rawMessage, &req); err != nil {
		log.Printf("Failed to unmarshal event: %v", err)
		return err
	}

	queueURL := getEnv("SQS_QUEUE_0", "")
	if queueURL == "" {
		log.Print("SQS_QUEUE_0 not set")
		return fmt.Errorf("SQS_QUEUE_0 not set")
	}

	timestamp := time.Now().UTC().Format("20060102_150405")
	fileName := fmt.Sprintf("%s_%s.txt", req.Name, timestamp)
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

	sqsc := sqs.NewFromConfig(cfg)
	msg, _ := json.Marshal(WatermarkRequest{Filename: fileName})
	if _, err := sqsc.SendMessage(ctx, &sqs.SendMessageInput{
		QueueUrl:    aws.String(queueURL),
		MessageBody: aws.String(string(msg)),
	}); err != nil {
		log.Printf("sqs send error: %v", err)
	} else {
		log.Printf("message sent to SQS: %s", fileName)
	}

	return nil
}

func main() {
	lambda.Start(convertHandler)
}
