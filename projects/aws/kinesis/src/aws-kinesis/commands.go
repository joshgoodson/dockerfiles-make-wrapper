package main

import (
	"github.com/codegangsta/cli"
)

func DescribeStreamCommand() cli.Command {
	return cli.Command{
		Name:    "describe-stream",
		Aliases: []string{"describe"},
		Usage:   "describes the given stream",
		Action:  DescribeStreamAction(),
	}
}

func FeedStreamCommand() cli.Command {
	return cli.Command{
		Name:    "feed-stream",
		Aliases: []string{"feed"},
		Usage:   "feeds a stream with data",
		Action:  FeedStreamAction(),
	}
}

func ShowConfigCommand() cli.Command {
	return cli.Command{
		Name:    "show-config",
		Aliases: []string{"config"},
		Usage:   "display current aws config values",
		Action:  ShowConfigAction(),
	}
}

func ListStreamsCommand() cli.Command {
	return cli.Command{
		Name:    "list-streams",
		Aliases: []string{"list"},
		Usage:   "lists current streams",
		Action:  ListStreamsAction(),
	}
}
