package bytesconv_test

import (
	"testing"

	"github.com/KasonBraley/kit/bytesconv"
)

func TestStringToBytes(t *testing.T) {
	got := bytesconv.StringToBytes("test")
	want := []byte("test")
	if string(got) != string(want) {
		t.Errorf("StringToBytes() = %v, want %v", got, want)
	}
}

func TestBytesToString(t *testing.T) {
	got := bytesconv.BytesToString([]byte("test"))
	want := "test"
	if got != want {
		t.Errorf("BytesToString() = %v, want %v", got, want)
	}
}
