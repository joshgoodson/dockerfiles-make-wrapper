package main

import (
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kinesis"
)

var (
	config *aws.Config
	sess   *session.Session
)

func init() {
	config = &aws.Config{
		Region: aws.String(os.Getenv("AWS_REGION")),
	}
	sess = session.New(config)
}

func ConfigRegion() string {
	return aws.StringValue(sess.Config.Region)
}

func ListStreams() (*kinesis.ListStreamsOutput, error) {
	svc := kinesis.New(sess)

	params := &kinesis.ListStreamsInput{
		Limit: aws.Int64(100),
	}

	resp, err := svc.ListStreams(params)
	if err != nil {
		panic(err)
	}

	return resp, nil
}

func DescribeStream(stream string) (*kinesis.DescribeStreamOutput, error) {
	svc := kinesis.New(sess)

	params := &kinesis.DescribeStreamInput{
		StreamName: aws.String(stream),
	}

	resp, err := svc.DescribeStream(params)
	if err != nil {
		panic(err)
	}

	return resp, nil
}

func PutRandomRecords(stream string, numRecords int, tmplPath string) (*kinesis.PutRecordsOutput, error) {
	svc := kinesis.New(sess)
	records := []*kinesis.PutRecordsRequestEntry{}

	for i := 0; i < numRecords; i++ {
		data := NewRandomData(i)
		dataBytes := data.ToBytesFromTemplate(tmplPath)
		key := fmt.Sprintf("part-key-%v", i)
		records = append(records, &kinesis.PutRecordsRequestEntry{
			Data:         dataBytes,
			PartitionKey: aws.String(key),
		})
	}

	params := &kinesis.PutRecordsInput{
		Records:    records,
		StreamName: aws.String(stream),
	}

	resp, err := svc.PutRecords(params)
	if err != nil {
		panic(err)
	}

	return resp, nil
}
