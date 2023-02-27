package Structs

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

type TimeLineStruct struct {
	History []struct {
		P []struct {
			A string `json:"a"`
			O string `json:"o"`
		} `json:"p"`
		D   string `json:"d"`
		S   string `json:"s"`
		L   string `json:"l"`
		F   string `json:"f"`
		Rpm string `json:"rpm"`
	} `json:"history"`
	DisconnectedPoints []interface{} `json:"DisconnectedPoints"`
	Stops              []struct {
		Lon      string `json:"lon"`
		Lat      string `json:"lat"`
		ID       string `json:"id"`
		From     string `json:"from"`
		To       string `json:"to"`
		Duration string `json:"duration"`
		Address  string `json:"address"`
	} `json:"stops"`
	Fuel    []interface{} `json:"Fuel"`
	Sensors []struct {
		Lon      string `json:"lon"`
		Lat      string `json:"lat"`
		StrtDate string `json:"strtDate"`
		EndDate  string `json:"endDate"`
		Duration string `json:"duration"`
		ID       string `json:"id"`
		SensorID string `json:"SensorID"`
		TypeName string `json:"typeName"`
	} `json:"Sensors"`
	HistoryWO []interface{} `json:"HistoryWO"`
}

type Coordinate struct {
	Latitude  string
	Longitude string
	DateTime  string
}

type HistoryQueryData struct {
	VehicleID string
}
