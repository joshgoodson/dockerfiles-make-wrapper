package main

import (
	"fmt"
	"strconv"

	"github.com/codegangsta/cli"
)

func BeforeAction() func(c *cli.Context) error {
	return func(c *cli.Context) error {
		if DebugMode(c) {
			fmt.Println("DEBUG MODE ON")
		}
		return nil
	}
}

func DefaultAction() func(c *cli.Context) {
	return func(c *cli.Context) {
		cli.ShowAppHelp(c)
	}
}

func DescribeStreamAction() func(c *cli.Context) {
	return func(c *cli.Context) {
		stream := c.Args()[0]

		out, err := DescribeStream(stream)
		if err != nil {
			panic(err)
		}

		fmt.Println(out.StreamDescription)
	}
}

func FeedStreamAction() func(c *cli.Context) {
	return func(c *cli.Context) {
		stream := c.Args()[0]
		numRecords, _ := strconv.Atoi(c.Args()[1])
		tmplPath := "data.tmpl"
		if len(c.Args()) > 2 {
			tmplPath = c.Args()[2]
		}

		out, err := PutRandomRecords(stream, numRecords, tmplPath)
		if err != nil {
			panic(err)
		}

		if DebugMode(c) {
			fmt.Println(out)
		}

		for _, v := range out.Records {
			fmt.Printf("%v:%v\n", *v.ShardId, *v.SequenceNumber)
		}
	}
}

func ShowConfigAction() func(c *cli.Context) {
	return func(c *cli.Context) {
		fmt.Printf("%v\n", ConfigRegion())
	}
}

func ListStreamsAction() func(c *cli.Context) {
	return func(c *cli.Context) {
		out, err := ListStreams()
		if err != nil {
			panic(err)
		}

		fmt.Println(out)
	}
}
