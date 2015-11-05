package main

import (
	"bytes"
	"io/ioutil"
	"text/template"
	"time"

	"github.com/Pallinder/go-randomdata"
)

type RandomData struct {
	Index     int
	SillyName string
	EpochTime int64
}

func NewRandomData(index int) *RandomData {
	return &RandomData{
		Index:     index,
		SillyName: randomdata.SillyName(),
		EpochTime: time.Now().UnixNano() / 1000000,
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
