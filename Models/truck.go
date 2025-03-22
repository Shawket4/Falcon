package Models

import (
	"gorm.io/gorm"
)

// Truck represents a complete truck with head and trailer
type Truck struct {
	gorm.Model
	TruckNo   string         `json:"truck_no" gorm:"type:varchar(50);uniqueIndex"`
	Make      string         `json:"make"`
	Year      int            `json:"year"`
	Positions []TirePosition `json:"positions"`
}

// Tire represents a single tire in the system
type Tire struct {
	gorm.Model
	Serial          string `json:"serial" gorm:"type:varchar(100);uniqueIndex"`
	Brand           string `json:"brand"`
	Size            string `json:"size"`
	ManufactureDate string `json:"manufacture_date"`
	PurchaseDate    string `json:"purchase_date"`
	Status          string `json:"status"` // "in-use", "spare", "retired"
}

// TirePosition represents a specific position on a truck where a tire can be mounted
type TirePosition struct {
	gorm.Model
	TruckID       uint   `json:"truck_id"`
	Truck         *Truck `json:"-" gorm:"foreignKey:TruckID"`
	PositionType  string `json:"position_type"`  // "steering", "head_axle_1", "head_axle_2", "trailer_axle_1", etc.
	PositionIndex int    `json:"position_index"` // For multiple tires in the same position type
	Side          string `json:"side"`           // "left", "right", "inner_left", "inner_right", "none" (for spares)
	TireID        *uint  `json:"tire_id"`        // The currently mounted tire (null if empty)
	Tire          *Tire  `json:"tire,omitempty" gorm:"foreignKey:TireID"`
}
