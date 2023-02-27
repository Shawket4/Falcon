package Models

import (
	"log"

	"gorm.io/gorm"
)

type Service struct {
	gorm.Model
	CarID           uint   `json:"car_id"`
	CarNoPlate      string `json:"car_no_plate"`
	ServiceType     string `json:"service_type"`
	DateOfService   string `json:"date_of_service"`
	OdometerReading int    `json:"odometer_reading"`
	Transporter     string `json:"transporter"`
	// CurrentOdometerReading int    `json:"CurrentOdometerReading"`
	ProofImageName string `json:"proof_image_name"`
}

func (input *Service) Add() (*Service, error) {
	if err := DB.Create(&input).Error; err != nil {
		log.Println(err.Error())
		return &Service{}, err
	}
	return input, nil
}

func (input *Service) Edit() (*Service, error) {
	if err := DB.Save(&input).Error; err != nil {
		log.Println(err.Error())
		return nil, err
	}
	return input, nil
}
