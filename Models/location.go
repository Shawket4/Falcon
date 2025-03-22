package Models

import "gorm.io/gorm"

type Location struct {
	gorm.Model
	Name    string `json:"name"`
	Address string `json:"address"`
}

type Terminal struct {
	gorm.Model
	Name    string `json:"name" gorm:"unique"`
	Address string `json:"address"`
}
