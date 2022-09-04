package main

import (
	"Falcon/Database"
	"Falcon/FiberConfig"
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
			time.Sleep(time.Second * 10)
		}
	}()
	Database.Connect()
	// Database.ConnectAdmin()
	FiberConfig.FiberConfig()
}
