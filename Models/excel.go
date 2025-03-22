package Models

type ExcelTrip struct {
	Date           string `json:"Date"`
	StartTime      string `json:"StarTime"`
	EndTime        string `json:"EndTime"`
	Customer       string `json:"Customer"`
	PickUpLocation string `json:"PickUpLocation"`
	// Transporter    string  `json:"Transporter"`
	TruckNo string `json:"TruckNo"`
	// TruckId    string  `json:"TruckId"`
	Diesel     float64 `json:"Diesel"`
	Gas80      float64 `json:"Gas80"`
	Gas92      float64 `json:"Gas92"`
	Gas95      float64 `json:"Gas95"`
	Mazoot     float64 `json:"Mazoot"`
	Total      float64 `json:"Total"`
	DriverName string  `json:"DriverName"`
	Revenue    float64 `json:"Revenue"`
	Mileage    float64 `json:"Mileage"`
}
