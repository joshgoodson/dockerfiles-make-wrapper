package main

import (
	"github.com/codegangsta/cli"
)

func RegionFlag() cli.StringFlag {
	return cli.StringFlag{
		Name:   "region, r",
		Value:  "us-east-1",
		Usage:  "AWS region to use.",
		EnvVar: "AWS_REGION",
	}
}
