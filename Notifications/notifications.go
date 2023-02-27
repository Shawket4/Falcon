package Notifications

import (
	Apis "Falcon/Apis"
	"Falcon/Controllers"
	"Falcon/Database"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
)

type Notification struct {
	Message      string   `json:"Message"`
	Type         []string `json:"Type"`
	DateOfExpiry string   `json:"DateOfExpiry"`
	DaysLeft     int      `json:"DaysLeft"`
	Transporter  string   `json:"Transporter"`
	Name         string   `json:"Name"`
	Driver       Apis.Driver
	Car          Apis.Car
}

var Notifications []Notification
var NotificationsTemp []Notification

func GetExpiringDocuments() {
	NotificationsTemp = []Notification{}
	currentDay := time.Now().Format("2006-01-02")
	fmt.Println(currentDay)
	db := Database.ConnectToDB()
	defer db.Close()

	carsDocuments, err := db.Query("SELECT `LicenseExpirationDate`, `CalibrationExpirationDate`, `TankLicenseExpirationDate`, `CarNoPlate`, `Transporter` FROM `Cars` WHERE `IsApproved` = 1;")
	if err != nil {
		log.Println(err.Error())
	}
	defer carsDocuments.Close()
	for carsDocuments.Next() {
		var carDocuments struct {
			LicenseExpirationDate     string
			CalibrationExpirationDate string
			TankLicenseExpirationDate string
			CarNoPlate                string
			Transporter               string
		}
		err := carsDocuments.Scan(&carDocuments.LicenseExpirationDate, &carDocuments.CalibrationExpirationDate, &carDocuments.TankLicenseExpirationDate, &carDocuments.CarNoPlate, &carDocuments.Transporter)
		if err != nil {
			log.Println(err.Error())
		}
		LicenseDaysLeft := Apis.DaysBetweenDates(currentDay, carDocuments.LicenseExpirationDate)
		CalibrationLicenseDaysLeft := Apis.DaysBetweenDates(currentDay, carDocuments.CalibrationExpirationDate)
		TankLicenseDaysLeft := Apis.DaysBetweenDates(currentDay, carDocuments.TankLicenseExpirationDate)
		car, err := db.Query("SELECT `CarId`, `CarNoPlate`, `Transporter`, `TankCapacity`, `Compartments`, `LicenseExpirationDate`, `CalibrationExpirationDate`, `TankLicenseExpirationDate`, `IsApproved`, `CarLicenseImageName`, `CalibrationLicenseImageName`, `CarLicenseImageNameBack`, `CalibrationLicenseImageNameBack`, `TankLicenseImageName`, `TankLicenseImageNameBack` FROM `Cars` WHERE `CarNoPlate` = ? AND `IsApproved` = 1;", carDocuments.CarNoPlate)
		if err != nil {
			log.Println(err.Error())
		}

		defer car.Close()
		if LicenseDaysLeft <= 10 {
			var notification Notification
			for car.Next() {
				var jsonCompartments string
				err = car.Scan(&notification.Car.CarId, &notification.Car.CarNoPlate, &notification.Car.Transporter, &notification.Car.TankCapacity, &jsonCompartments, &notification.Car.LicenseExpirationDate, &notification.Car.CalibrationExpirationDate, &notification.Car.TankLicenseExpirationDate, &notification.Car.IsApproved, &notification.Car.CarLicenseImageName, &notification.Car.CalibrationLicenseImageName, &notification.Car.CarLicenseImageNameBack, &notification.Car.CalibrationLicenseImageNameBack, &notification.Car.TankLicenseImageName, &notification.Car.TankLicenseImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
				// Covert jsonCompartments To An Array of string
				err = json.Unmarshal([]byte(jsonCompartments), &notification.Car.Compartments)
				if err != nil {
					log.Println(err.Error())
				}
			}
			notification.DaysLeft = LicenseDaysLeft
			notification.DateOfExpiry = carDocuments.LicenseExpirationDate
			notification.Type = []string{"Car", "Car_License"}
			notification.Message = fmt.Sprintf("رخصة السيارة رقم %s علي وشك الانتهاء", carDocuments.CarNoPlate)
			notification.Transporter = carDocuments.Transporter
			notification.Name = carDocuments.CarNoPlate
			NotificationsTemp = append(NotificationsTemp, notification)
		}
		if CalibrationLicenseDaysLeft <= 10 {
			var notification Notification
			for car.Next() {
				var jsonCompartments string
				err = car.Scan(&notification.Car.CarId, &notification.Car.CarNoPlate, &notification.Car.Transporter, &notification.Car.TankCapacity, &jsonCompartments, &notification.Car.LicenseExpirationDate, &notification.Car.CalibrationExpirationDate, &notification.Car.TankLicenseExpirationDate, &notification.Car.IsApproved, &notification.Car.CarLicenseImageName, &notification.Car.CalibrationLicenseImageName, &notification.Car.CarLicenseImageNameBack, &notification.Car.CalibrationLicenseImageNameBack, &notification.Car.TankLicenseImageName, &notification.Car.TankLicenseImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
				// Covert jsonCompartments To An Array of string
				err = json.Unmarshal([]byte(jsonCompartments), &notification.Car.Compartments)
				if err != nil {
					log.Println(err.Error())
				}
			}
			notification.DaysLeft = CalibrationLicenseDaysLeft
			notification.DateOfExpiry = carDocuments.CalibrationExpirationDate
			notification.Type = []string{"Car", "Calibration_License"}
			notification.Message = fmt.Sprintf("شهادة العيار للسيارة رقم %s علي وشك الانتهاء", carDocuments.CarNoPlate)
			notification.Transporter = carDocuments.Transporter
			notification.Name = carDocuments.CarNoPlate
			NotificationsTemp = append(NotificationsTemp, notification)
		}
		if TankLicenseDaysLeft <= 10 {
			var notification Notification
			for car.Next() {
				var jsonCompartments string
				err = car.Scan(&notification.Car.CarId, &notification.Car.CarNoPlate, &notification.Car.Transporter, &notification.Car.TankCapacity, &jsonCompartments, &notification.Car.LicenseExpirationDate, &notification.Car.CalibrationExpirationDate, &notification.Car.TankLicenseExpirationDate, &notification.Car.IsApproved, &notification.Car.CarLicenseImageName, &notification.Car.CalibrationLicenseImageName, &notification.Car.CarLicenseImageNameBack, &notification.Car.CalibrationLicenseImageNameBack, &notification.Car.TankLicenseImageName, &notification.Car.TankLicenseImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
				// Covert jsonCompartments To An Array of string
				err = json.Unmarshal([]byte(jsonCompartments), &notification.Car.Compartments)
				if err != nil {
					log.Println(err.Error())
				}
			}
			notification.DaysLeft = TankLicenseDaysLeft
			notification.DateOfExpiry = carDocuments.TankLicenseExpirationDate
			notification.Type = []string{"Car", "Tank_License"}
			notification.Message = fmt.Sprintf("رخصة التانك للسيارة رقم %s علي وشك الانتهاء", carDocuments.CarNoPlate)
			notification.Transporter = carDocuments.Transporter
			notification.Name = carDocuments.CarNoPlate
			NotificationsTemp = append(NotificationsTemp, notification)
		}
	}
	driversDocuments, err := db.Query("SELECT `driver_license_expiration_date`, `safety_license_expiration_date`, `drug_test_expiration_date`, `name`, `Transporter` FROM `users` WHERE `IsApproved` = 1 AND `permission` = 0;")
	if err != nil {
		log.Println(err.Error())
	}
	defer driversDocuments.Close()
	for driversDocuments.Next() {
		var driverDocuments struct {
			DriverLicenseExpirationDate string
			SafetyLicenseExpirationDate string
			DrugTestExpirationDate      string
			DriverName                  string
			Transporter                 string
		}
		err := driversDocuments.Scan(&driverDocuments.DriverLicenseExpirationDate, &driverDocuments.SafetyLicenseExpirationDate, &driverDocuments.DrugTestExpirationDate, &driverDocuments.DriverName, &driverDocuments.Transporter)
		if err != nil {
			log.Println(err.Error())
		}
		DriverLicenseDaysLeft := Apis.DaysBetweenDates(currentDay, driverDocuments.DriverLicenseExpirationDate)
		SafetyLicenseDaysLeft := Apis.DaysBetweenDates(currentDay, driverDocuments.SafetyLicenseExpirationDate)
		DrugTestDaysLeft := Apis.DaysBetweenDates(currentDay, driverDocuments.DrugTestExpirationDate)
		query, err := db.Query("SELECT `id`, `name`, `email`, `mobile_number`, `driver_license_expiration_date`, `safety_license_expiration_date`, `drug_test_expiration_date`, `IsApproved`, `Transporter`, `DriverLicenseImageName`, `SafetyLicenseImageName`, `DrugTestImageName`, `DriverLicenseImageNameBack`, `SafetyLicenseImageNameBack`, `DrugTestImageNameBack` FROM `users` WHERE permission = 0 AND `IsApproved` = 1 AND `name` = ?", driverDocuments.DriverName)
		if err != nil {
			log.Println(err.Error())
		}
		defer query.Close()
		if DriverLicenseDaysLeft <= 10 {
			var notification Notification
			for query.Next() {
				err = query.Scan(&notification.Driver.DriverId, &notification.Driver.Name, &notification.Driver.Email, &notification.Driver.MobileNumber, &notification.Driver.LicenseExpirationDate, &notification.Driver.SafetyExpirationDate, &notification.Driver.DrugTestExpirationDate, &notification.Driver.IsApproved, &notification.Driver.Transporter, &notification.Driver.DriverLicenseImageName, &notification.Driver.SafetyLicenseImageName, &notification.Driver.DrugTestImageName, &notification.Driver.DriverLicenseImageNameBack, &notification.Driver.SafetyLicenseImageNameBack, &notification.Driver.DrugTestImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
			}
			notification.DaysLeft = DriverLicenseDaysLeft
			notification.DateOfExpiry = driverDocuments.DriverLicenseExpirationDate
			notification.Type = []string{"Driver", "Driver_License"}
			notification.Message = fmt.Sprintf("رخصة القيادة للسائق %s علي وشك الانتهاء", driverDocuments.DriverName)
			notification.Transporter = driverDocuments.Transporter
			notification.Name = driverDocuments.DriverName
			NotificationsTemp = append(NotificationsTemp, notification)
		}
		if SafetyLicenseDaysLeft <= 10 {
			var notification Notification
			for query.Next() {
				err = query.Scan(&notification.Driver.DriverId, &notification.Driver.Name, &notification.Driver.Email, &notification.Driver.MobileNumber, &notification.Driver.LicenseExpirationDate, &notification.Driver.SafetyExpirationDate, &notification.Driver.DrugTestExpirationDate, &notification.Driver.IsApproved, &notification.Driver.Transporter, &notification.Driver.DriverLicenseImageName, &notification.Driver.SafetyLicenseImageName, &notification.Driver.DrugTestImageName, &notification.Driver.DriverLicenseImageNameBack, &notification.Driver.SafetyLicenseImageNameBack, &notification.Driver.DrugTestImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
			}
			notification.DaysLeft = SafetyLicenseDaysLeft
			notification.DateOfExpiry = driverDocuments.SafetyLicenseExpirationDate
			notification.Type = []string{"Driver", "Safety_License"}
			notification.Message = fmt.Sprintf("رخصة القيادة الأمنة للسائق %s علي وشك الانتهاء", driverDocuments.DriverName)
			notification.Transporter = driverDocuments.Transporter
			notification.Name = driverDocuments.DriverName
			NotificationsTemp = append(NotificationsTemp, notification)
		}
		if DrugTestDaysLeft <= 10 {
			var notification Notification
			for query.Next() {
				err = query.Scan(&notification.Driver.DriverId, &notification.Driver.Name, &notification.Driver.Email, &notification.Driver.MobileNumber, &notification.Driver.LicenseExpirationDate, &notification.Driver.SafetyExpirationDate, &notification.Driver.DrugTestExpirationDate, &notification.Driver.IsApproved, &notification.Driver.Transporter, &notification.Driver.DriverLicenseImageName, &notification.Driver.SafetyLicenseImageName, &notification.Driver.DrugTestImageName, &notification.Driver.DriverLicenseImageNameBack, &notification.Driver.SafetyLicenseImageNameBack, &notification.Driver.DrugTestImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
			}
			notification.DaysLeft = DrugTestDaysLeft
			notification.DateOfExpiry = driverDocuments.DrugTestExpirationDate
			notification.Type = []string{"Driver", "Drug_Test"}
			notification.Message = fmt.Sprintf("شهادة المخضرات للسائق %s علي وشك الانتهاء", driverDocuments.DriverName)
			notification.Transporter = driverDocuments.Transporter
			notification.Name = driverDocuments.DriverName
			NotificationsTemp = append(NotificationsTemp, notification)
		}
	}
	Notifications = NotificationsTemp
}

func ReturnNotifications(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else if Controllers.CurrentUser.Permission == 1 {
			var UserNotifications []Notification
			for _, s := range Notifications {
				if s.Transporter == Controllers.CurrentUser.Name {
					UserNotifications = append(UserNotifications, s)
				}
			}
			return c.JSON(UserNotifications)
		} else {
			return c.JSON(Notifications)
		}
	}
	return c.JSON(fiber.Map{
		"message": "Not Logged In.",
	})
}
