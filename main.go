package main

import (
	"Falcon/FiberConfig"
	"Falcon/Models"
	"Falcon/Notifications"
	"Falcon/Scrapper"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	// CheckExpirationDates Each Minute
	go func() {
		for {
			Scrapper.GetVehicleData()
			// AbstractFunctions.DetectServiceMilage()
			time.Sleep(time.Minute * 10)
		}
	}()
	go func() {
		for {
			Notifications.GetExpiringDocuments()
			time.Sleep(time.Hour)
		}
	}()
	//go func() {
	//	for {
	//		Scrapper.GetVehicleHistoryData()
	//		time.Sleep(time.Second * 30)
	//	}
	//}()
	Models.Connect()
	FiberConfig.FiberConfig()
}
