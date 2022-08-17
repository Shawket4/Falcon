package Structs

type Service struct {
	EventId                string
	IsAlerted              int
	CarNoPlate             string `json:"CarNoPlate"`
	ServiceType            string `json:"ServiceType"`
	DateOfService          string `json:"DateOfService"`
	ServiceCenter          string `json:"ServiceCenter"`
	ServiceOdometerReading string `json:"ServiceOdometerReading"`
	CurrentOdometerReading string `json:"CurrentOdometerReading"`
	AlertAfter             string `json:"AlertAfter"`
}

type DailyDelivery struct {
	DeliveryId      string
	Date            string
	DriverName      string
	AmountDelivered string
	CarNoPlate      string
	TrailerNoPlate  string
	PickUpPoint     string
	DepositPoint1   string
	DepositPoint2   string
	DepositPoint3   string
	Distance        string
	Fees            string
	Notes           string
}
