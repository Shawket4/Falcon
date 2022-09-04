package Apis

import (
	"Falcon/Controllers"
	"Falcon/Database"
	"Falcon/Models"
	"Falcon/Scrapper"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
)

type Car struct {
	CarId                           int    `json:"CarId"`
	CarNoPlate                      string `json:"CarNoPlate"`
	Transporter                     string `json:"Transporter"`
	TankCapacity                    int    `json:"TankCapacity"`
	Compartments                    []int  `json:"Compartments"`
	LicenseExpirationDate           string `json:"LicenseExpirationDate"`
	CalibrationExpirationDate       string `json:"CalibrationExpirationDate"`
	CarLicenseImageName             string `json:"CarLicenseImageName"`
	CalibrationLicenseImageName     string `json:"CalibrationLicenseImageName"`
	CarLicenseImageNameBack         string `json:"CarLicenseImageNameBack"`
	CalibrationLicenseImageNameBack string `json:"CalibrationLicenseImageNameBack"`
	IsInTrip                        string `json:"IsInTrip"`
	IsApproved                      int    `json:"IsApproved"`
}

type Driver struct {
	DriverId                   int    `json:"DriverId"`
	Name                       string `json:"Name"`
	Email                      string `json:"Email"`
	MobileNumber               string `json:"MobileNumber"`
	LicenseExpirationDate      string `json:"LicenseExpirationDate"`
	SafetyExpirationDate       string `json:"SafetyExpirationDate"`
	DrugTestExpirationDate     string `json:"DrugTestExpirationDate"`
	IsApproved                 int    `json:"IsApproved"`
	Transporter                string `json:"Transporter"`
	DriverLicenseImageName     string `json:"DriverLicenseImageName"`
	SafetyLicenseImageName     string `json:"SafetyLicenseImageName"`
	DrugTestImageName          string `json:"DrugTestImageName"`
	DriverLicenseImageNameBack string `json:"DriverLicenseImageNameBack"`
	SafetyLicenseImageNameBack string `json:"SafetyLicenseImageNameBack"`
	DrugTestImageNameBack      string `json:"DrugTestImageNameBack"`
}

type Transporter struct {
	Id           int                 `json:"TransporterId"`
	Name         string              `json:"TransporterName"`
	PhoneNumbers []map[string]string `json:"TransporterPhones"`
}

type User struct {
	Id            int    `json:"Id"`
	Name          string `json:"Name"`
	Email         string `json:"Email"`
	Permission    int    `json:"Permission"`
	Mobile_Number string `json:"Mobile_Number"`
}

func GetProgressOfCars(c *fiber.Ctx) error {
	// Fetch all cars from database
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()

			var Data struct {
				DateFrom string `json:"DateFrom"`
				DateTo   string `json:"DateTo"`
			}
			// defer cars.Close()
			err := c.BodyParser(&Data)
			if err != nil {
				return c.JSON(fiber.Map{
					"message": err.Error(),
				})
			}

			// var Cars []CarStruct

			// Make Days variable to store the number of days between the two dates
			var Days int = DaysBetweenDates(Data.DateFrom, Data.DateTo)

			var Cars []Models.CarStruct

			trips, err := db.Query("SELECT `CarProgressBarID`, `Car No Plate`, `CarProgressIndex`, `Driver Name`, `StepCompleteTime`, `NoOfDropOffPoints`, `Date`, `IsInTrip` FROM CarProgressBars WHERE Date BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ? ORDER BY `Date` DESC;", Data.DateTo, Days, Data.DateTo)
			if err != nil {
				log.Println(err)
			}
			for trips.Next() {
				var car Models.CarStruct
				err = trips.Scan(&car.CarID, &car.CarNoPlate, &car.ProgressIndex, &car.DriverName, &car.StepCompleteTime, &car.NoOfDropOffPoints, &car.Date, &car.IsInTrip)
				if err != nil {
					log.Println(err)
				}
				Cars = append(Cars, car)
			}
			if len(Cars) == 0 {
				c.Status(fiber.StatusNoContent)
				return c.JSON(fiber.Map{})
			}
			return c.JSON(Cars)
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetCars(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		db := Database.ConnectToDB()
		cars, err := db.Query("SELECT `CarNoPlate`, `Compartments` FROM `Cars` WHERE `LicenseExpirationDate` > CURRENT_DATE() AND `CalibrationExpirationDate` > CURRENT_DATE() AND `IsInTrip` = ? AND `IsApproved` = 1;", "false")
		if err != nil {
			log.Println(err.Error())
		}
		defer cars.Close()
		var CarNoPlates []string
		var Compartments [][]int
		for cars.Next() {
			var carNoPlateStruct struct {
				CarNoPlate   string `json:"CarNoPlate"`
				Compartments []int  `json:"Compartments"`
			}
			var jsonData string
			err = cars.Scan(&carNoPlateStruct.CarNoPlate, &jsonData)
			json.Unmarshal([]byte(jsonData), &carNoPlateStruct.Compartments)
			if err != nil {
				log.Println(err.Error())
			}

			CarNoPlates = append(CarNoPlates, carNoPlateStruct.CarNoPlate)
			Compartments = append(Compartments, carNoPlateStruct.Compartments)
		}
		return c.JSON(fiber.Map{
			"CarNoPlates":  CarNoPlates,
			"Compartments": Compartments,
		})
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetDrivers(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		db := Database.ConnectToDB()
		drivers, err := db.Query("SELECT `name` FROM `users` WHERE `permission` = 0 AND `driver_license_expiration_date` > CURRENT_DATE() AND `safety_license_expiration_date` > CURRENT_DATE() AND `drug_test_expiration_date` > CURRENT_DATE() AND `IsInTrip` = ? AND `IsApproved` = 1;", "false")
		if err != nil {
			log.Println(err.Error())
		}
		defer drivers.Close()
		var Drivers []string
		for drivers.Next() {
			var driver string
			err = drivers.Scan(&driver)
			if err != nil {
				log.Println(err.Error())
			}
			Drivers = append(Drivers, driver)
		}
		return c.JSON(Drivers)
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetTransporters(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			transporters, err := db.Query("SELECT `TransporterName` FROM `Transporters` WHERE 1;")
			if err != nil {
				log.Println(err.Error())
			}
			defer transporters.Close()
			var Transporters []string
			for transporters.Next() {
				var transporter string
				err := transporters.Scan(&transporter)
				if err != nil {
					log.Println(err.Error())
				}
				Transporters = append(Transporters, transporter)
			}
			return c.JSON(Transporters)
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func DaysBetweenDates(Date1, Date2 string) int {
	// Convert string to time
	t1, _ := time.Parse("2006-01-02", Date1)
	t2, _ := time.Parse("2006-01-02", Date2)
	// Calculate days between dates
	days := t2.Sub(t1).Hours() / 24
	return int(days)
}

func RegisterCar(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			// Get the body of the request
			// Convert the body to a map
			var car Car
			formData := c.FormValue("request")
			// format formData into data map
			err := json.Unmarshal([]byte(formData), &car)
			if err != nil {
				log.Println(err)
			}
			// err := c.BodyParser(&car)
			// if err != nil {
			// 	log.Println(err.Error())
			// 	return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			// }

			jsonCompartments, err := json.Marshal(car.Compartments)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			if Controllers.CurrentUser.Permission >= 3 {
				car.IsApproved = 1
			} else {
				car.IsApproved = 0
			}
			if car.Transporter == "" {
				car.Transporter = Controllers.CurrentUser.Name
			}
			carLicense, err := c.FormFile("CarLicense")
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(carLicense, fmt.Sprintf("./CarLicenses/%s", carLicense.Filename))
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			carLicenseBack, err := c.FormFile("CarLicenseBack")
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(carLicenseBack, fmt.Sprintf("./CarLicenses/%s", carLicenseBack.Filename))
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			calibrationLicense, err := c.FormFile("CalibrationLicense")
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(calibrationLicense, fmt.Sprintf("./CalibrationLicenses/%s", calibrationLicense.Filename))
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			calibrationLicenseBack, err := c.FormFile("CalibrationLicenseBack")
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(calibrationLicenseBack, fmt.Sprintf("./CalibrationLicenses/%s", calibrationLicenseBack.Filename))
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Insert the car into the database
			_, err = db.Exec("INSERT INTO `Cars` (`CarId`, `CarNoPlate`, `Transporter`, `TankCapacity`, `Compartments`, `LicenseExpirationDate`, `CalibrationExpirationDate`, `IsApproved`, `CarLicenseImageName`, `CalibrationLicenseImageName`, `CarLicenseImageNameBack`, `CalibrationLicenseImageNameBack`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", car.CarNoPlate, car.Transporter, car.TankCapacity, jsonCompartments, car.LicenseExpirationDate, car.CalibrationExpirationDate, car.IsApproved, carLicense.Filename, calibrationLicense.Filename, carLicenseBack.Filename, calibrationLicenseBack.Filename)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			return c.JSON(
				fiber.Map{
					"Message":    "Car added successfully",
					"CarNoPlate": car.CarNoPlate,
				},
			)
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func RegisterTransporter(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			// Get the body of the request
			var data Transporter
			err := c.BodyParser(&data)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			// Insert the transporter into the database
			// Encode the transporter mobile numbers to json
			jsonPhoneNumbers, err := json.Marshal(data.PhoneNumbers)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}

			_, err = db.Exec("INSERT INTO `Transporters` (`TransporterId`, `TransporterName`, `TransporterMobilePhone`) VALUES (NULL, ?, ?);", data.Name, jsonPhoneNumbers)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}

			return c.JSON(
				fiber.Map{
					"Message": "Transporter added successfully",
					"Name":    data.Name,
				},
			)
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetCarProfileData(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else if Controllers.CurrentUser.Permission == 1 {
			db := Database.ConnectToDB()
			var Cars []Car
			cars, err := db.Query("SELECT `CarId`, `CarNoPlate`, `Transporter`, `TankCapacity`, `Compartments`, `LicenseExpirationDate`, `CalibrationExpirationDate`, `IsApproved`, `CarLicenseImageName`, `CalibrationLicenseImageName`, `CarLicenseImageNameBack`, `CalibrationLicenseImageNameBack` FROM `Cars` WHERE `Transporter` = ? AND `IsApproved` = 1;", Controllers.CurrentUser.Name)
			if err != nil {
				log.Println(err.Error())
			}

			defer cars.Close()
			for cars.Next() {
				var car Car
				var jsonCompartments string
				err = cars.Scan(&car.CarId, &car.CarNoPlate, &car.Transporter, &car.TankCapacity, &jsonCompartments, &car.LicenseExpirationDate, &car.CalibrationExpirationDate, &car.IsApproved, &car.CarLicenseImageName, &car.CalibrationLicenseImageName, &car.CarLicenseImageNameBack, &car.CalibrationLicenseImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
				// Covert jsonCompartments To An Array of string
				err = json.Unmarshal([]byte(jsonCompartments), &car.Compartments)
				if err != nil {
					log.Println(err.Error())
				}
				Cars = append(Cars, car)
			}
			return c.JSON(Cars)
		} else {
			db := Database.ConnectToDB()
			// Get List Of Transporters

			var Cars []Car
			cars, err := db.Query("SELECT `CarId`, `CarNoPlate`, `Transporter`, `TankCapacity`, `Compartments`, `LicenseExpirationDate`, `CalibrationExpirationDate`, `IsApproved`, `CarLicenseImageName`, `CalibrationLicenseImageName`, `CarLicenseImageNameBack`, `CalibrationLicenseImageNameBack` FROM `Cars` WHERE `IsApproved` = 1;")
			if err != nil {
				log.Println(err.Error())
			}
			defer cars.Close()
			for cars.Next() {
				var car Car
				var jsonCompartments string
				err = cars.Scan(&car.CarId, &car.CarNoPlate, &car.Transporter, &car.TankCapacity, &jsonCompartments, &car.LicenseExpirationDate, &car.CalibrationExpirationDate, &car.IsApproved, &car.CarLicenseImageName, &car.CalibrationLicenseImageName, &car.CarLicenseImageNameBack, &car.CalibrationLicenseImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
				// Covert jsonCompartments To An Array of string
				err = json.Unmarshal([]byte(jsonCompartments), &car.Compartments)
				if err != nil {
					log.Println(err.Error())
				}
				Cars = append(Cars, car)
			}
			return c.JSON(Cars)
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetDriverProfileData(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else if Controllers.CurrentUser.Permission == 1 {
			db := Database.ConnectToDB()
			var Drivers []Driver
			query, err := db.Query("SELECT `id`, `name`, `email`, `mobile_number`, `driver_license_expiration_date`, `safety_license_expiration_date`, `drug_test_expiration_date`, `IsApproved`, `Transporter`, `DriverLicenseImageName`, `SafetyLicenseImageName`, `DrugTestImageName`, `DriverLicenseImageNameBack`, `SafetyLicenseImageNameBack`, `DrugTestImageNameBack` FROM `users` WHERE permission = 0 AND `IsApproved` = 1 AND `Transporter` = ?", Controllers.CurrentUser.Name)
			if err != nil {
				log.Println(err.Error())
			}
			defer query.Close()

			for query.Next() {
				var driver Driver
				err = query.Scan(&driver.DriverId, &driver.Name, &driver.Email, &driver.MobileNumber, &driver.LicenseExpirationDate, &driver.SafetyExpirationDate, &driver.DrugTestExpirationDate, &driver.IsApproved, &driver.Transporter, &driver.DriverLicenseImageName, &driver.SafetyLicenseImageName, &driver.DrugTestImageName, &driver.DriverLicenseImageNameBack, &driver.SafetyLicenseImageNameBack, &driver.DrugTestImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
				Drivers = append(Drivers, driver)
			}
			return c.JSON(Drivers)
		} else {
			db := Database.ConnectToDB()
			var Drivers []Driver
			query, err := db.Query("SELECT `id`, `name`, `email`, `mobile_number`, `driver_license_expiration_date`, `safety_license_expiration_date`, `drug_test_expiration_date`, `IsApproved`, `Transporter`, `DriverLicenseImageName`, `SafetyLicenseImageName`, `DrugTestImageName`, `DriverLicenseImageNameBack`, `SafetyLicenseImageNameBack`, `DrugTestImageNameBack` FROM `users` WHERE permission = 0 AND `IsApproved` = 1;")
			if err != nil {
				log.Println(err.Error())
			}
			defer query.Close()

			for query.Next() {
				var driver Driver
				err = query.Scan(&driver.DriverId, &driver.Name, &driver.Email, &driver.MobileNumber, &driver.LicenseExpirationDate, &driver.SafetyExpirationDate, &driver.DrugTestExpirationDate, &driver.IsApproved, &driver.Transporter, &driver.DriverLicenseImageName, &driver.SafetyLicenseImageName, &driver.DrugTestImageName, &driver.DriverLicenseImageNameBack, &driver.SafetyLicenseImageNameBack, &driver.DrugTestImageNameBack)
				if err != nil {
					log.Println(err.Error())
				}
				Drivers = append(Drivers, driver)
			}
			return c.JSON(Drivers)
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetTransporterProfileData(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			query, err := db.Query("SELECT * FROM `Transporters` WHERE 1;")
			if err != nil {
				log.Println(err.Error())
			}
			defer query.Close()
			var Transporters []Transporter
			for query.Next() {
				var Transporter Transporter
				var jsonData string
				err = query.Scan(&Transporter.Id, &Transporter.Name, &jsonData)
				if err != nil {
					log.Println(err.Error())
				}
				err = json.Unmarshal([]byte(jsonData), &Transporter.PhoneNumbers)
				if err != nil {
					log.Println(err.Error())
				}
				Transporters = append(Transporters, Transporter)
			}
			return c.JSON(Transporters)
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func DeleteDriver(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			var Driver struct {
				Name string `json:"Name"`
			}
			err := c.BodyParser(&Driver)

			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}

			_, err = db.Exec("DELETE FROM `users` WHERE `name` = ? AND `permission` = 0;", Driver.Name)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			return c.JSON(fiber.Map{
				"Message": "Driver deleted successfully",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func DeleteCar(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			var Car struct {
				CarNoPlate string `json:"CarNoPlate"`
			}
			err := c.BodyParser(&Car)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			_, err = db.Exec("DELETE FROM `Cars` WHERE `CarNoPlate` = ?", Car.CarNoPlate)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			return c.JSON(fiber.Map{
				"Message": "Car deleted successfully",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func EditCar(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()

			var Car struct {
				CurrentCarNoPlate         string `json:"CurrentCarNoPlate"`
				CarNoPlate                string `json:"CarNoPlate"`
				TankCapacity              int    `json:"TankCapacity"`
				Compartments              []int  `json:"Compartments"`
				LicenseExpirationDate     string `json:"LicenseExpirationDate"`
				CalibrationExpirationDate string `json:"CalibrationExpirationDate"`
			}

			err := c.BodyParser(&Car)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			jsonCompartments, err := json.Marshal(Car.Compartments)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			_, err = db.Exec("UPDATE `Cars` SET `CarNoPlate` = ?, `TankCapacity` = ?, `Compartments` = ?, `LicenseExpirationDate` = ?, `CalibrationExpirationDate` = ? WHERE `CarNoPlate` = ?;", Car.CarNoPlate, Car.TankCapacity, jsonCompartments, Car.LicenseExpirationDate, Car.CalibrationExpirationDate, Car.CurrentCarNoPlate)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			return c.JSON(fiber.Map{
				"Message": "Car updated successfully",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func EditDriver(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()

			var Driver struct {
				CurrentEmail string `json:"currentEmail"`
				Name         string `json:"name"`
				Email        string `json:"email"`
				// Password                       string `json:"password"`
				Mobile_Number                  string `json:"mobile_number"`
				Driver_License_Expiration_Date string `json:"driver_license_expiration_date"`
				Safety_License_Expiration_Date string `json:"safety_license_expiration_date"`
				Drug_Test_Expiration_Date      string `json:"drug_test_expiration_date"`
			}
			err := c.BodyParser(&Driver)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			// if Driver.Password != "" {
			// 	_, err = db.Exec("UPDATE `users` SET `name` = ?, `email` = ?, `password` = ?, `mobile_number` = ?, `driver_license_expiration_date` = ?, `safety_license_expiration_date` = ?, `drug_test_expiration_date` = ? WHERE `email` = ?;", Driver.Name, Driver.Email, Driver.Password, Driver.Mobile_Number, Driver.Driver_License_Expiration_Date, Driver.Safety_License_Expiration_Date, Driver.Drug_Test_Expiration_Date, Driver.Email)
			// 	if err != nil {
			// 		log.Println(err.Error())
			// 		return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			// 	}
			// } else {
			_, err = db.Exec("UPDATE `users` SET `name` = ?, `email` = ?, `mobile_number` = ?, `driver_license_expiration_date` = ?, `safety_license_expiration_date` = ?, `drug_test_expiration_date` = ? WHERE `email` = ?;", Driver.Name, Driver.Email, Driver.Mobile_Number, Driver.Driver_License_Expiration_Date, Driver.Safety_License_Expiration_Date, Driver.Drug_Test_Expiration_Date, Driver.CurrentEmail)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
				// }
			}
			return c.JSON(fiber.Map{
				"Message": "Driver updated successfully",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func EditTransporter(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			// Get Request Data
			var transporter Transporter
			err := c.BodyParser(&transporter)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			jsonPhoneNumbers, err := json.Marshal(transporter.PhoneNumbers)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			_, err = db.Exec("UPDATE `Transporters` SET `TransporterName` = ?, `TransporterMobilePhone` = ? WHERE `TransporterId` = ?;", transporter.Name, jsonPhoneNumbers, transporter.Id)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			return c.JSON(fiber.Map{
				"Message": "Transporter updated successfully",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func DeleteCarTrip(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()

			var CarTrip struct {
				TripId     int    `json:"TripId"`
				CarNoPlate string `json:"CarNoPlate"`
				DriverName string `json:"DriverName"`
			}
			err := c.BodyParser(&CarTrip)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			_, err = db.Exec("DELETE FROM `CarProgressBars` WHERE `CarProgressBarID` = ?;", CarTrip.TripId)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			fmt.Println(CarTrip)
			_, err = db.Exec("UPDATE `Cars` SET `IsInTrip` = ? WHERE `CarNoPlate` = ?;", "false", CarTrip.CarNoPlate)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			_, err = db.Exec("UPDATE `users` SET `IsInTrip` = ? WHERE `name` = ?;", "false", CarTrip.DriverName)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			return c.JSON(fiber.Map{
				"Message": "Car Trip deleted successfully",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetPendingRequests(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission < 3 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			Cars, err := db.Query("SELECT `CarId`, `CarNoPlate`, `Transporter`, `TankCapacity`, `Compartments`, `LicenseExpirationDate`, `CalibrationExpirationDate`, `IsApproved`, `CarLicenseImageName`, `CalibrationLicenseImageName`, `CarLicenseImageNameBack`, `CalibrationLicenseImageNameBack` FROM `Cars` WHERE `IsApproved` = 0;")
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			defer Cars.Close()
			var CarsArray []Car
			for Cars.Next() {
				var car Car
				var jsonData string
				err := Cars.Scan(&car.CarId, &car.CarNoPlate, &car.Transporter, &car.TankCapacity, &jsonData, &car.LicenseExpirationDate, &car.CalibrationExpirationDate, &car.IsApproved, &car.CarLicenseImageName, &car.CalibrationLicenseImageName, &car.CarLicenseImageNameBack, &car.CalibrationLicenseImageNameBack)
				json.Unmarshal([]byte(jsonData), &car.Compartments)
				if err != nil {
					log.Println(err.Error())
				}
				if err != nil {
					log.Println(err.Error())
					return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
				}
				CarsArray = append(CarsArray, car)
			}
			// Get Pending Driver Requests
			Drivers, err := db.Query("SELECT `id`, `name`, `email`, `mobile_number`, `driver_license_expiration_date`, `safety_license_expiration_date`, `drug_test_expiration_date`, `IsApproved`, `Transporter`, `DriverLicenseImageName`, `SafetyLicenseImageName`, `DrugTestImageName`, `DriverLicenseImageNameBack`, `SafetyLicenseImageNameBack`, `DrugTestImageNameBack` FROM `users` WHERE `IsApproved` = 0 AND permission = 0;")
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			defer Drivers.Close()
			var DriversArray []Driver
			for Drivers.Next() {
				var driver Driver
				err := Drivers.Scan(&driver.DriverId, &driver.Name, &driver.Email, &driver.MobileNumber, &driver.LicenseExpirationDate, &driver.SafetyExpirationDate, &driver.DrugTestExpirationDate, &driver.IsApproved, &driver.Transporter, &driver.DriverLicenseImageName, &driver.SafetyLicenseImageName, &driver.DrugTestImageName, &driver.DriverLicenseImageNameBack, &driver.SafetyLicenseImageNameBack, &driver.DrugTestImageNameBack)
				if err != nil {
					log.Println(err.Error())
					return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
				}
				DriversArray = append(DriversArray, driver)
			}
			return c.JSON(fiber.Map{
				"Cars":    CarsArray,
				"Drivers": DriversArray,
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func ApproveRequest(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission < 3 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			var RequestData struct {
				TableName    string `json:"TableName"`
				ColumnIdName string `json:"ColumnIdName"`
				Id           int    `json:"Id"`
			}
			err := c.BodyParser(&RequestData)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			query := fmt.Sprintf("UPDATE `%s` SET `IsApproved` = 1 WHERE `%s` = %v;", RequestData.TableName, RequestData.ColumnIdName, RequestData.Id)
			_, err = db.Exec(query)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			return c.JSON(fiber.Map{
				"Message": "Request Approved",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func RejectRequest(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission < 3 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			var RequestData struct {
				TableName    string `json:"TableName"`
				ColumnIdName string `json:"ColumnIdName"`
				Id           int    `json:"Id"`
			}
			err := c.BodyParser(&RequestData)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			query := fmt.Sprintf("DELETE FROM `%s` WHERE `%s`.`%s` = %v;", RequestData.TableName, RequestData.TableName, RequestData.ColumnIdName, RequestData.Id)
			_, err = db.Exec(query)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			return c.JSON(fiber.Map{
				"Message": "Request Rejected",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetNonDriverUsers(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission < 4 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			Users, err := db.Query("SELECT `id`, `name`, `email`, `permission`, `mobile_number` FROM `users` WHERE `IsApproved` = 1 AND permission > 0 AND permission < 4;")
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			defer Users.Close()
			var UsersArray []User
			for Users.Next() {
				var user User
				err := Users.Scan(&user.Id, &user.Name, &user.Email, &user.Permission, &user.Mobile_Number)
				if err != nil {
					log.Println(err.Error())
					return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
				}
				UsersArray = append(UsersArray, user)
			}
			return c.JSON(fiber.Map{
				"Users": UsersArray,
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func UpdateTempPermission(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission < 4 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()
			var RequestData struct {
				Id int `json:"Id"`
			}
			err := c.BodyParser(&RequestData)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			query := fmt.Sprintf("UPDATE `users` SET permission=(@temp:=permission), permission = permission2, permission2 = @temp WHERE `id` = %v;", RequestData.Id)
			_, err = db.Exec(query)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			return c.JSON(fiber.Map{
				"Message": "Permission Updated",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetVehicleStatus(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var data struct {
				CarNoPlate string `json:"CarNoPlate"`
			}

			err := c.BodyParser(&data)

			if err != nil {
				log.Println(err.Error())
			}
			for _, s := range Scrapper.VechileStatusList {
				if s.PlateNo == data.CarNoPlate {
					return c.JSON(s)
				}
			}
			return c.JSON(fiber.Map{
				"message": "Car Not Found",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetVechileMapPoints(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else if Controllers.CurrentUser.Permission >= 2 {
			return c.JSON(Scrapper.VechileStatusList)
		} else if Controllers.CurrentUser.Permission == 1 {
			db := Database.ConnectToDB()
			defer db.Close()
			Cars, err := db.Query("SELECT `CarNoPlate` FROM `Cars` WHERE `Transporter` = ?", Controllers.CurrentUser.Name)

			if err != nil {
				log.Println(err.Error())
			}
			var CarPlates []string
			var CarsList []Scrapper.VechileStatusStruct
			for Cars.Next() {
				var carPlate string
				Cars.Scan(&carPlate)
				CarPlates = append(CarPlates, carPlate)
			}

			for _, scrapperPlate := range Scrapper.VechileStatusList {
				for _, transporterPlate := range CarPlates {
					if scrapperPlate.PlateNo == transporterPlate {
						CarsList = append(CarsList, scrapperPlate)
					}
				}
			}
			return c.JSON(CarsList)
		} else {
			return c.JSON(fiber.Map{
				"message": "An Error Occurred",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}
