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
	City               string
	State              string
	StringNumber1      string
	StringNumber2      string
	StringNumber3      string
	StringNumber4      string
	StringNumber5      string
	StringNumber10     string
	StringNumber15     string
	StringNumber20     string
	NumberOneToHundred int
	FloatZeroToOne     float64
	FloatZeroToHundred float64
	Paragraph          string
	Boolean            bool
	TimeEpoch          int64
	TimeRFC3339        string
	IpV4Address        string
}

func NewRandomData(index int) *RandomData {
	return &RandomData{
		Index:              index,
		Noun:               randomdata.Noun(),
		Adjective:          randomdata.Adjective(),
		SillyName:          randomdata.SillyName(),
		City:               randomdata.City(),
		State:              randomdata.State(1),
		StringNumber1:      randomdata.StringNumberExt(1, "", 1),
		StringNumber2:      randomdata.StringNumberExt(1, "", 2),
		StringNumber3:      randomdata.StringNumberExt(1, "", 3),
		StringNumber4:      randomdata.StringNumberExt(1, "", 4),
		StringNumber5:      randomdata.StringNumberExt(1, "", 5),
		StringNumber10:     randomdata.StringNumberExt(1, "", 10),
		StringNumber15:     randomdata.StringNumberExt(1, "", 15),
		StringNumber20:     randomdata.StringNumberExt(1, "", 20),
		NumberOneToHundred: randomdata.Number(0, 100),
		FloatZeroToOne:     randomdata.Decimal(0, 1, 2),
		FloatZeroToHundred: randomdata.Decimal(0, 100, 2),
		Paragraph:          randomdata.Paragraph(),
		Boolean:            randomdata.Boolean(),
		TimeEpoch:          time.Now().UnixNano() / 1000000,
		TimeRFC3339:        time.Now().Format(time.RFC3339),
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
