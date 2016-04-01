package main

import (
	"testing"
)

func TestToBytesFromTemplate(t *testing.T) {
	t.Log("TestToBytesFromTemplate")
	data := NewRandomData(0)
	dataBytes := data.ToBytesFromTemplate("data.tmpl")
	t.Log(string(dataBytes))
}

func TestToBytesFromTemplateWithCustom(t *testing.T) {
	t.Log("TestToBytesFromTemplate")
	data := NewRandomData(0)
	dataBytes := data.ToBytesFromTemplate("/tmp/data.tmpl")
	t.Log(string(dataBytes))
}
