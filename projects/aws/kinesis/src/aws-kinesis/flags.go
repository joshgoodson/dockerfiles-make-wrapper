package main

import (
	"github.com/codegangsta/cli"
)

func DebugFlag() cli.BoolTFlag {
	return cli.BoolTFlag{
		Name:   "debug, d",
		Usage:  "debug mode forces verbose output",
		EnvVar: "DEBUG",
	}
}

func RegionFlag() cli.StringFlag {
	return cli.StringFlag{
		Name:   "region, r",
		Value:  "us-east-1",
		Usage:  "AWS region to use.",
		EnvVar: "AWS_REGION",
	}
}

func DebugMode(c *cli.Context) bool {
	return c.GlobalBool("debug") == true
}
