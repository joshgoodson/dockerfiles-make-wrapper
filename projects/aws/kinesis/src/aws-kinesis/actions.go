package main

import (
	"fmt"
	"strconv"

	"github.com/codegangsta/cli"
)

func BeforeAction() func(c *cli.Context) error {
	return func(c *cli.Context) error {
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

		out, err := PutRandomRecords(stream, numRecords)
		if err != nil {
			panic(err)
		}

		fmt.Println(out)
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
