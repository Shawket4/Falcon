package Scrapper

import "testing"

type addTest struct {
	input, expected float64
}

var addTests = []addTest{
	addTest{0, 0},
	addTest{62, 63},
	addTest{100, 63},
	addTest{123, 76},
	addTest{189, 89},
	addTest{200, 89},
	addTest{201, 102},
	addTest{250, 102},
	addTest{260, 115},
}

func TestGetFeeFromMilage(t *testing.T) {
	for _, test := range addTests {
		got := GetFeeFromMilage(test.input)
		want := float64(test.expected)
		if got != want {
			t.Errorf("got %f, wanted %f", got, want)
		}
	}

}
