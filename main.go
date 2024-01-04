package main

import (
	"Falcon/FiberConfig"
	"Falcon/Models"
	"Falcon/Scrapper"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	// CheckExpirationDates Each Minute
	// go func() {
	// 	for {
	// 		Scrapper.GetVehicleData()
	// 		// AbstractFunctions.DetectServiceMilage()
	// 		time.Sleep(time.Minute * 10)
	// 	}
	// }()
	// go func() {
	// 	for {
	// 		Notifications.GetExpiringDocuments()
	// 		time.Sleep(time.Hour)
	// 	}
	// }()
	go func() {
		for {
			Scrapper.GetVehicleData()
			time.Sleep(time.Second * 10)
			// Scrapper.CalculateDistanceWorker()
			time.Sleep(time.Hour)
		}
	}()
	// go func() {
	// 	time.Sleep(time.Second * 30)
	// 	for {
	// 		if err := Scrapper.CheckLandMarks(); err != nil {
	// 			log.Println(err)
	// 		}
	// 		time.Sleep(time.Hour * 12)
	// 	}
	// }()
	Models.Connect()
	FiberConfig.FiberConfig()
}
