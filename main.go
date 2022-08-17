package main

import (
	"Falcon/Database"
	"Falcon/FiberConfig"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	// CheckExpirationDates Each Minute
	// go func() {
	// 	for {
	// 		// CheckExpirationDates()
	// 		// AbstractFunctions.DetectServiceMilage()
	// 		time.Sleep(time.Minute)
	// 	}
	// }()
	Database.Connect()
	// Database.ConnectAdmin()
	FiberConfig.FiberConfig()
}
