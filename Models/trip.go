package Models

import (
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type RoutePoint struct {
	gorm.Model
	FinalStructResponseID uint
	Latitude              string `json:"latitude"`
	Longitude             string `json:"longitude"`
	TimeStamp             string `json:"time_stamp"`
}

type RouteResponse struct {
	History []struct {
		Point []struct {
			Latitude  string `yaml:"a"`
			Longitude string `yaml:"o"`
		} `yaml:"p"`
		DateTime string `yaml:"d"`
	} `yaml:"history"`
}

type FinalStructResponse struct {
	gorm.Model
	TripStructID uint
	Points       []RoutePoint
	TripSummary  TripSummary `json:"trip_summary"`
	Mileage      float64     `json:"mileage"`
	DriverFees   float64     `json:"driver_fees"`
}

type TripSummary struct {
	gorm.Model
	FinalStructResponseID uint
	TotalMileage          string `yaml:"TotalMileage"`
	TotalActiveTime       string `yaml:"TotalActiveTime"`
	TotalPassiveTime      string `yaml:"TotalPassiveTime"`
	TotalIdleTime         string `yaml:"TotalIdleTime"`
	NumberofStops         string `yaml:"NumberofStops"`
	TotalDisConnectedTime string `yaml:"TotalDisConnectedTime"`
	Sensor1               string `yaml:"Sensor1"`
	Sensor2               string `yaml:"Sensor2"`
}

type Expense struct {
	gorm.Model
	TripStructID uint
	Cost         float64 `json:"cost"`
	Description  string  `json:"description"`
	Date         string  `json:"date"`
}

type Loan struct {
	gorm.Model
	TripStructID uint
	Amount       float64 `json:"amount"`
	Method       string  `json:"method"`
	Date         string  `json:"date"`
}

type TripStruct struct {
	gorm.Model
	CarID            uint   `json:"car_id"`
	DriverID         uint   `json:"driver_id"`
	CarNoPlate       string `json:"car_no_plate"`
	DriverName       string `json:"driver_name"`
	Transporter      string `json:"transporter"`
	TankCapacity     int    `json:"tank_capacity"`
	PickUpPoint      string `json:"pick_up_point"`
	ProgressIndex    int    `json:"progress_index"`
	StepCompleteTime struct {
		//{"TruckLoad": ["", "Exxon Mobile Mostrod", true], "DropOffPoints": [["", "هاي ميكس بدر", true], ["", "هاي ميكس بدر", true]]}
		Terminal struct {
			TimeStamp    string `json:"time_stamp"`
			TerminalName string `json:"terminal_name"`
			Status       bool   `json:"status"`
		} `json:"terminal"`
		DropOffPoints []struct {
			TimeStamp    string `json:"time_stamp"`
			LocationName string `json:"location_name"`
			Capacity     int    `json:"capacity"`
			GasType      string `json:"gas_type"`
			Status       bool   `json:"status"`
		} `json:"drop_off_points"`
	} `gorm:"-" json:"step_complete_time"`
	StepCompleteTimeDB datatypes.JSON      `json:"step_complete_time_db"`
	NoOfDropOffPoints  int                 `json:"no_of_drop_off_points"`
	Date               string              `json:"date"`
	FeeRate            float64             `json:"fee_rate"`
	StartTime          string              `json:"start_time"`
	EndTime            string              `json:"end_time"`
	Mileage            float64             `json:"mileage"`
	DriverFees         float64             `json:"driver_fees"`
	IsClosed           bool                `json:"is_closed"`
	Route              FinalStructResponse `json:"route"`
	Expenses           []Expense
	Loans              []Loan
	ReceiptNo          string `json:"receipt_no"`
}
