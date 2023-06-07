package Models

import "gorm.io/gorm"

type Location struct {
	gorm.Model
	Name string `json:"name"`
}

type Terminal struct {
	gorm.Model
	Name string `json:"name"`
}
