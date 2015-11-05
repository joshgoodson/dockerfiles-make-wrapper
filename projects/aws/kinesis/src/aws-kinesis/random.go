package main

import (
	"bytes"
	"io/ioutil"
	"text/template"
	"time"

	"github.com/Pallinder/go-randomdata"
)

type RandomData struct {
	Index              int
	Noun               string
	Adjective          string
	SillyName          string
	NumberOneToHundred int
	FloatZeroToHundred float64
	Paragraph          string
	Boolean            bool
	EpochTime          int64
	IpV4Address        string
}

func NewRandomData(index int) *RandomData {
	return &RandomData{
		Index:              index,
		Noun:               randomdata.Noun(),
		Adjective:          randomdata.Adjective(),
		SillyName:          randomdata.SillyName(),
		NumberOneToHundred: randomdata.Number(0, 100),
		FloatZeroToHundred: randomdata.Decimal(0, 100),
		Paragraph:          randomdata.Paragraph(),
		Boolean:            randomdata.Boolean(),
		EpochTime:          time.Now().UnixNano() / 1000000,
		IpV4Address:        randomdata.IpV4Address(),
	}
}

func (d *RandomData) ToBytesFromTemplate(path string) []byte {
	json, _ := ioutil.ReadFile(path)

	tmpl, err := template.New("jsonTemplate").Parse(string(json))
	if err != nil {
		panic(err)
	}

	result := bytes.Buffer{}
	err = tmpl.Execute(&result, d)
	if err != nil {
		panic(err)
	}

	return result.Bytes()
}
