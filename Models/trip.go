package Models

import (
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type TripStruct struct {
	gorm.Model
	CarID        uint   `json:"car_id"`
	DriverID     uint   `json:"driver_id"`
	CarNoPlate   string `json:"car_no_plate"`
	DriverName   string `json:"driver_name"`
	Transporter  string `json:"transporter"`
	TankCapacity int    `json:"tank_capacity"`

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
	StepCompleteTimeDB datatypes.JSON `json:"step_complete_time_db"`
	NoOfDropOffPoints  int            `json:"no_of_drop_off_points"`
	Date               string         `json:"date"`
	FeeRate            float64        `json:"fee_rate"`
	Mileage            float64        `json:"mileage"`
	StartTime          string         `json:"start_time"`
	EndTime            string         `json:"end_time"`
	IsClosed           bool           `json:"is_closed"`
}
