package main

import (
	"os"

	"github.com/codegangsta/cli"
)

func main() {
	app := cli.NewApp()
	app.Name = "aws-kinesis"
	app.Author = "Brian Claridge"
	app.Email = "brian@claridge.net"
	app.Usage = "A cli app that plays with kinesis"
	app.ArgsUsage = ""
	app.Flags = []cli.Flag{
		RegionFlag(),
	}
	app.Commands = []cli.Command{
		DescribeStreamCommand(),
		FeedStreamCommand(),
		ShowConfigCommand(),
		ListStreamsCommand(),
	}
	app.Action = ShowConfigAction()
	app.Before = BeforeAction()
	app.Run(os.Args)
}
