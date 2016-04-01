package main

import (
	"github.com/codegangsta/cli"
)

func DebugFlag() cli.BoolFlag {
	return cli.BoolFlag{
		Name:   "debug, d",
		Usage:  "debug mode forces verbose output",
		EnvVar: "DEBUG",
	}
}

func RegionFlag() cli.StringFlag {
	return cli.StringFlag{
		Name:   "region, r",
		Value:  "us-east-1",
		Usage:  "AWS region to use",
		EnvVar: "AWS_REGION",
	}
}

func SleepFlag() cli.IntFlag {
	return cli.IntFlag{
		Name:   "sleep",
		Value:  1000,
		Usage:  "Time to sleep between operations",
		EnvVar: "PUT_SLEEP",
	}
}

func RecordsFlag() cli.IntFlag {
	return cli.IntFlag{
		Name:   "records",
		Value:  1,
		Usage:  "Number of records per batch to put",
		EnvVar: "PUT_RECORDS",
	}
}

func DebugMode(c *cli.Context) bool {
	return c.GlobalBool("debug") == true
}
