package main

import (
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
)

func main() {
	config := &aws.Config{Region: aws.String(os.Getenv("AWS_REGION"))}
	sess := session.New(config)
	fmt.Printf("%v\n", *sess.Config.Region)
}
