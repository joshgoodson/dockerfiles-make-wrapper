package main

import (
	"fmt"
	"strconv"
	"time"

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

		// determine batch size
		numRecords := 1
		if len(c.Args()) > 1 {
			aRecords, _ := strconv.Atoi(c.Args()[1])
			numRecords = aRecords
		}
		if fRecords := c.Int("records"); fRecords > numRecords && fRecords > 0 {
			numRecords = fRecords
		}

		// determine sleep time
		sleep := 1000
		if len(c.Args()) > 2 {
			aSleep, _ := strconv.Atoi(c.Args()[2])
			sleep = aSleep
		}
		if fSleep := c.Int("sleep"); fSleep >= 1000 {
			sleep = fSleep
		}

		// determine template path
		tmplPath := "data.tmpl"
		if len(c.Args()) > 3 {
			tmplPath = c.Args()[3]
		}

		for {
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

			time.Sleep(time.Duration(sleep) * time.Millisecond)
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
