package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"text/template"
	"time"

	"github.com/Pallinder/go-randomdata"
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

func PutRandomRecords(stream string, numRecords int) (*kinesis.PutRecordsOutput, error) {
	svc := kinesis.New(sess)
	records := []*kinesis.PutRecordsRequestEntry{}

	for i := 0; i < numRecords; i++ {
		data, partKey, err := makeRandomDataBytes(i)
		if err != nil {
			panic(err)
		}

		records = append(records, &kinesis.PutRecordsRequestEntry{
			Data:         data,
			PartitionKey: aws.String(partKey),
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

type randomData struct {
	Index int
	Data  string
	Time  int64
}

func makeRandomDataBytes(index int) ([]byte, string, error) {
	data := randomData{
		Index: index,
		Data:  randomdata.SillyName(),
		Time:  time.Now().UnixNano() / 1000000,
	}

	json, _ := ioutil.ReadFile("data.tmpl")

	tmpl, err := template.New("jsonTemplate").Parse(string(json))
	if err != nil {
		panic(err)
	}

	partKey := fmt.Sprintf("part-key-%v", index)
	result := bytes.Buffer{}
	err = tmpl.Execute(&result, data)
	if err != nil {
		panic(err)
	}

	return result.Bytes(), partKey, nil
}
