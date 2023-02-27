package Models

import (
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type Car struct {
	gorm.Model
	CarNoPlate                      string         `json:"car_no_plate"`
	CarType                         string         `json:"car_type"`
	Transporter                     string         `json:"transporter"`
	TankCapacity                    int            `json:"tank_capacity"`
	Compartments                    []int          `gorm:"-" json:"compartments"`
	JSONCompartments                datatypes.JSON `json:"json_compartments"`
	LicenseExpirationDate           string         `json:"license_expiration_date"`
	CalibrationExpirationDate       string         `json:"calibration_expiration_date"`
	TankLicenseExpirationDate       string         `json:"tank_license_expiration_date"`
	CarLicenseImageName             string         `json:"car_license_image_name"`
	CalibrationLicenseImageName     string         `json:"calibration_license_image_name"`
	CarLicenseImageNameBack         string         `json:"car_license_image_name_back"`
	CalibrationLicenseImageNameBack string         `json:"calibration_license_image_name_back"`
	TankLicenseImageName            string         `json:"tank_license_image_name"`
	TankLicenseImageNameBack        string         `json:"tank_license_image_name_back"`
	IsInTrip                        bool           `json:"is_in_trip"`
	IsApproved                      bool           `json:"is_approved"`
}
