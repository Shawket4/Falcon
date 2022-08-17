package Models

type CarStruct struct {
	CarID                   int    `json:"CardID"`
	CarNoPlate              string `json:"CarNoPlate"`
	TankCapacity            int    `json:"TankCapacity"`
	InsuranceExpirationDate string `json:"InsuranceExpirationDate"`
	DriverName              string `json:"DriverName"`
	ProgressIndex           int    `json:"ProgressIndex"`
	StepCompleteTime        string `json:"StepCompleteTime"`
	NoOfDropOffPoints       int    `json:"NoOfDropOffPoints"`
	Date                    string `json:"Date"`
	IsInTrip                string `json:"IsInTrip"`
}
