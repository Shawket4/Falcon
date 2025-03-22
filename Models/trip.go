package Models

import (
	"gorm.io/gorm"
)

// TripStruct represents a trip record with additional fields for terminal and drop-off points
type TripStruct struct {
	gorm.Model
	CarID        uint   `json:"car_id"`
	DriverID     uint   `json:"driver_id"`
	CarNoPlate   string `json:"car_no_plate"`
	DriverName   string `json:"driver_name"`
	Transporter  string `json:"transporter"`
	TankCapacity int    `json:"tank_capacity"`

	// Company and related fields for dropdown selection
	Company      string `json:"company"`
	Terminal     string `json:"terminal"`       // Added Terminal field (was PickUpPoint)
	DropOffPoint string `json:"drop_off_point"` // Added DropOffPoint field

	// Location details
	LocationName string `json:"location_name"`
	Capacity     int    `json:"capacity"`
	GasType      string `json:"gas_type"`

	// Trip details
	Date      string  `json:"date"`
	Revenue   float64 `json:"revenue"`
	Mileage   float64 `json:"mileage"`
	ReceiptNo string  `json:"receipt_no"`

	// Calculated fields
	Distance float64 `json:"distance" gorm:"-"` // Distance from fee mapping, not stored
	Fee      float64 `json:"fee" gorm:"-"`      // Fee from fee mapping, not stored
}

// TableName specifies the table name for the Trip model
func (TripStruct) TableName() string {
	return "trips"
}

// FeeMapping represents a mapping between terminals, drop-off points, distance, and fee
type FeeMapping struct {
	gorm.Model
	Company      string  `json:"company"`        // Company associated with this mapping
	Terminal     string  `json:"terminal"`       // Pickup terminal
	DropOffPoint string  `json:"drop_off_point"` // Drop-off location
	Distance     float64 `json:"distance"`       // Distance in kilometers
	Fee          float64 `json:"fee"`            // Associated fee for this mapping
}

// Ensure uniqueness of company, terminal, and drop-off point combination
func (FeeMapping) TableName() string {
	return "fee_mappings"
}

// Setup indexes for FeeMapping
func SetupFeeMappingIndexes(db *gorm.DB) error {
	// Create unique index for company, terminal, and drop-off point
	return db.Exec("CREATE UNIQUE INDEX IF NOT EXISTS idx_company_terminal_dropoff ON fee_mappings (company, terminal, drop_off_point) WHERE deleted_at IS NULL").Error
}
