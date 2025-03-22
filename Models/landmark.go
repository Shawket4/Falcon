package Models

import "gorm.io/gorm"

type LandMark struct {
	gorm.Model
	Name      string
	Latitude  string `json:"latitude"`
	Longitude string `json:"longitude"`
}
