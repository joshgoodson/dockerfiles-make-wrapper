package main

import (
	"bytes"
	"fmt"
	"os"
	"strconv"
	"text/template"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kinesis"
	"github.com/codegangsta/cli"
)

var (
	config *aws.Config
	sess   *session.Session
)

func main() {
	app := cli.NewApp()
	app.Name = "aws-kinesis"
	app.Usage = "A cli app that plays with kinesis"
	app.ArgsUsage = ""
	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:   "region, r",
			Value:  "us-east-1",
			Usage:  "AWS region to use.",
			EnvVar: "AWS_REGION",
		},
	}

	app.Commands = []cli.Command{
		{
			Name:    "feed-data",
			Aliases: []string{"feed"},
			Usage:   "feeds a stream with data",
			Action: func(c *cli.Context) {
				if err := PutRecordsAction(c, sess); err != nil {
					fmt.Println(err.Error())
				}
			},
		},
		{
			Name:    "show-config",
			Aliases: []string{"config"},
			Usage:   "display current aws config values",
			Action: func(c *cli.Context) {
				DisplayConfigAction(c, sess)
			},
		},
		{
			Name:    "list-streams",
			Aliases: []string{"list"},
			Usage:   "lists current streams",
			Action: func(c *cli.Context) {
				if err := ListStreamsAction(c, sess); err != nil {
					fmt.Println(err.Error())
				}
			},
		},
	}

	app.Action = func(c *cli.Context) {
		cli.ShowAppHelp(c)
	}

	app.Before = func(c *cli.Context) error {
		config = &aws.Config{
			Region: aws.String(os.Getenv("AWS_REGION")),
		}
		sess = session.New(config)
		return nil
	}

	app.Run(os.Args)
}

func DisplayConfigAction(c *cli.Context, sess *session.Session) {
	fmt.Printf("%v\n", *sess.Config.Region)
}

func ListStreamsAction(c *cli.Context, sess *session.Session) error {
	svc := kinesis.New(sess)

	params := &kinesis.ListStreamsInput{
		Limit: aws.Int64(100),
	}

	resp, err := svc.ListStreams(params)

	if err != nil {
		return err
	}

	fmt.Println(resp)

	return nil
}

func PutRecordsAction(c *cli.Context, sess *session.Session) error {
	svc := kinesis.New(sess)

	stream := *aws.String(c.Args()[0])
	numRecords, _ := strconv.Atoi(c.Args()[1])

	records := []*kinesis.PutRecordsRequestEntry{}

	for i := 0; i < numRecords; i++ {
		data, _ := makeDataBytes(i, fmt.Sprintf("record-data-%v", i))
		records = append(records, &kinesis.PutRecordsRequestEntry{
			Data:         data,
			PartitionKey: aws.String(fmt.Sprintf("part-key-%s", i)),
		})
	}

	params := &kinesis.PutRecordsInput{
		Records:    records,
		StreamName: aws.String(stream),
	}

	resp, err := svc.PutRecords(params)

	if err != nil {
		return err
	}

	fmt.Println(resp)

	return nil
}

type recordData struct {
	Index int
	Data  string
	Time  int64
}

func makeDataBytes(index int, dataValue string) ([]byte, error) {
	data := recordData{
		Index: index,
		Data:  dataValue,
		Time:  0,
	}

	json := `
	{
		"Index": "{{.Index}}",
		"Data": "{{.Data}}",
		"Time": {{.Time}}
	}
	`

	tmpl, err := template.New("jsonTemplate").Parse(json)
	if err != nil {
		panic(err)
	}

	result := bytes.Buffer{}
	err = tmpl.Execute(&result, data)

	return result.Bytes(), err
}
