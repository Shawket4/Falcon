package Models

import (
	"fmt"
	"log"

	"gorm.io/gorm"
)

type FuelEvent struct {
	gorm.Model
	CarID          uint    `json:"car_id"`
	CarNoPlate     string  `json:"car_no_plate"`
	Date           string  `json:"date"`
	Liters         float64 `json:"liters"`
	PricePerLiter  float64 `json:"price_per_liter"`
	Price          float64 `json:"price"`
	FuelRate       float64 `json:"fuel_rate"`
	Transporter    string  `json:"transporter"`
	OdometerBefore int     `json:"odometer_before"`
	OdometerAfter  int     `json:"odometer_after"`
}

func (input *FuelEvent) Add() (*FuelEvent, error) {
	if err := DB.Create(input).Error; err != nil {
		log.Println(err.Error())
		return &FuelEvent{}, err
	}
	return input, nil
}

func (input *FuelEvent) Edit() (*FuelEvent, error) {
	var CurrentFuelEvent FuelEvent
	if err := DB.Model(&FuelEvent{}).Where("id = ?", input.ID).Find(&CurrentFuelEvent).Error; err != nil {
		log.Println(err.Error())
		return &FuelEvent{}, err
	}
	fmt.Println(CurrentFuelEvent)
	CurrentFuelEvent.CarNoPlate = input.CarNoPlate
	CurrentFuelEvent.Date = input.Date
	CurrentFuelEvent.Liters = input.Liters
	CurrentFuelEvent.PricePerLiter = input.PricePerLiter
	CurrentFuelEvent.Price = input.Price
	CurrentFuelEvent.FuelRate = input.FuelRate
	CurrentFuelEvent.OdometerBefore = input.OdometerBefore
	CurrentFuelEvent.OdometerAfter = input.OdometerAfter

	if err := DB.Save(&CurrentFuelEvent).Error; err != nil {
		log.Println(err.Error())
		return &FuelEvent{}, err
	}
	return &CurrentFuelEvent, nil
}
