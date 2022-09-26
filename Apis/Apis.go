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

	"github.com/360EntSecGroup-Skylar/excelize"
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
	TankLicenseExpirationDate       string `json:"TankLicenseExpirationDate"`
	CarLicenseImageName             string `json:"CarLicenseImageName"`
	CalibrationLicenseImageName     string `json:"CalibrationLicenseImageName"`
	CarLicenseImageNameBack         string `json:"CarLicenseImageNameBack"`
	CalibrationLicenseImageNameBack string `json:"CalibrationLicenseImageNameBack"`
	TankLicenseImageName            string `json:"TankLicenseImageName"`
	TankLicenseImageNameBack        string `json:"TankLicenseImageNameBack"`
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

			trips, err := db.Query("SELECT `CarProgressBarID`, `Car No Plate`, `CarProgressIndex`, `Driver Name`, `StepCompleteTime`, `NoOfDropOffPoints`, `Date`, `Compartments`, `FeeRate`, `IsInTrip` FROM CarProgressBars WHERE Date BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ? ORDER BY `Date` DESC;", Data.DateTo, Days, Data.DateTo)
			if err != nil {
				log.Println(err)
				return err
			}
			for trips.Next() {
				var car Models.CarStruct
				var jsonCompartments string
				err = trips.Scan(&car.CarID, &car.CarNoPlate, &car.ProgressIndex, &car.DriverName, &car.StepCompleteTime, &car.NoOfDropOffPoints, &car.Date, &jsonCompartments, &car.FeeRate, &car.IsInTrip)
				if err != nil {
					log.Println(err)
					return err
				}

				err = json.Unmarshal([]byte(jsonCompartments), &car.Compartments)

				if err != nil {
					log.Println(err.Error())
					return err
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
		type dataStruct struct {
			Include string `json:"Include"`
		}
		var data dataStruct
		err := c.BodyParser(&data)
		if err != nil {
			return c.JSON(fiber.Map{
				"message": err.Error(),
			})
		}

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
		if data.Include != "" {
			includedCar, err := db.Query("SELECT `CarNoPlate`, `Compartments` FROM `Cars` WHERE `CarNoPlate` = ?", data.Include)
			if err != nil {
				log.Println(err.Error())
			}
			defer includedCar.Close()
			for includedCar.Next() {
				var carNoPlateStruct struct {
					CarNoPlate   string `json:"CarNoPlate"`
					Compartments []int  `json:"Compartments"`
				}
				var jsonData string
				err = includedCar.Scan(&carNoPlateStruct.CarNoPlate, &jsonData)
				json.Unmarshal([]byte(jsonData), &carNoPlateStruct.Compartments)
				if err != nil {
					log.Println(err.Error())
				}

				CarNoPlates = append(CarNoPlates, carNoPlateStruct.CarNoPlate)
				Compartments = append(Compartments, carNoPlateStruct.Compartments)
			}
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

			tankLicense, err := c.FormFile("TankLicense")
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(tankLicense, fmt.Sprintf("./TankLicenses/%s", tankLicense.Filename))
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}

			tankLicenseBack, err := c.FormFile("TankLicenseBack")
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(tankLicenseBack, fmt.Sprintf("./TankLicensesBack/%s", tankLicenseBack.Filename))
			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}

			// Insert the car into the database
			_, err = db.Exec("INSERT INTO `Cars` (`CarId`, `CarNoPlate`, `Transporter`, `TankCapacity`, `Compartments`, `LicenseExpirationDate`, `CalibrationExpirationDate`, `TankLicenseExpirationDate`, `IsApproved`, `CarLicenseImageName`, `CalibrationLicenseImageName`, `CarLicenseImageNameBack`, `CalibrationLicenseImageNameBack`, `TankLicenseImageName`, `TankLicenseImageNameBack`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", car.CarNoPlate, car.Transporter, car.TankCapacity, jsonCompartments, car.LicenseExpirationDate, car.CalibrationExpirationDate, car.TankLicenseExpirationDate, car.IsApproved, carLicense.Filename, calibrationLicense.Filename, carLicenseBack.Filename, calibrationLicenseBack.Filename, tankLicense.Filename, tankLicenseBack.Filename)
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
			for _, s := range Scrapper.VehicleStatusList {
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

type Trip struct {
	TripId            int             `json:"TripId"`
	DriverName        string          `json:"DriverName"`
	Date              string          `json:"Date"`
	CarNoPlate        string          `json:"CarNoPlate"`
	PickUpPoint       string          `json:"PickUpPoint"`
	NoOfDropOffPoints int             `json:"NoOfDropOffPoints"`
	DropOffPoints     []string        `json:"DropOffPoints"`
	Compartments      [][]interface{} `json:"Compartments"`
}

func CreateCarTrip(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var data Trip
			if err := c.BodyParser(&data); err != nil {
				return err
			}
			// fmt.Println(data)
			//
			db := Database.ConnectToDB()
			_ = db
			// Step Complete Time
			var StepCompleteTime string
			// Format {"TruckLoad": ["", PickUpPoint], DropOffPoints: [[time, DropOffPoint]]}
			var TruckLoad []string
			TruckLoad = append(TruckLoad, "0")
			TruckLoad = append(TruckLoad, data.PickUpPoint)
			var DropOffPoints [][]string

			for _, DropOffPoint := range data.DropOffPoints {
				DropOffPoints = append(DropOffPoints, []string{"0", DropOffPoint})
			}
			// Step Complete Time
			StepCompleteTime = fmt.Sprintf("{\"TruckLoad\": [\"%v\",\"%v\", false], \"DropOffPoints\": [", TruckLoad[0], TruckLoad[1])
			for _, DropOffPoint := range DropOffPoints {
				StepCompleteTime = fmt.Sprintf("%v[\"%v\", \"%v\", false],", StepCompleteTime, DropOffPoint[0], DropOffPoint[1])
			}
			// Remove Last Comma
			StepCompleteTime = StepCompleteTime[:len(StepCompleteTime)-1]
			StepCompleteTime = fmt.Sprintf("%v]}", StepCompleteTime)
			// fmt.Println(StepCompleteTime)
			fmt.Println(data)
			jsonCompartments, err := json.Marshal(&data.Compartments)

			if err != nil {
				log.Println(err.Error())
			}

			getTransporter, err := db.Query("SELECT `Transporter` FROM `Cars` WHERE `CarNoPlate` = ?", data.CarNoPlate)

			if err != nil {
				log.Println(err.Error())
			}
			defer getTransporter.Close()
			var Transporter string
			for getTransporter.Next() {
				err = getTransporter.Scan(&Transporter)
				if err != nil {
					log.Println(err.Error())
					return err
				}
			}
			_, feeRate := GetTransportFee(data.DropOffPoints, data.PickUpPoint)

			insert, err := db.Query("INSERT INTO CarProgressBars (`CarProgressBarID`, `Date`, `Car No Plate`, `CarProgressIndex`, `Driver Name`, `StepCompleteTime`, `NoOfDropOffPoints`, `Compartments`, `PickUpLocation`, `Transporter`, `FeeRate`, `IsInTrip`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", data.Date, data.CarNoPlate, 0, data.DriverName, StepCompleteTime, data.NoOfDropOffPoints, jsonCompartments, data.PickUpPoint, Transporter, feeRate, "true")
			if err != nil {
				log.Println(err.Error())
			}
			defer insert.Close()
			// fmt.Println(data)
			updateCar, err := db.Query("UPDATE `Cars` SET `IsInTrip` = ? WHERE `CarNoPlate` = ?", "true", data.CarNoPlate)
			if err != nil {
				log.Println(err.Error())
			}
			defer updateCar.Close()
			updateDriver, err := db.Query("UPDATE `users` SET `IsInTrip` = ? WHERE `name` = ?", "true", data.DriverName)
			if err != nil {
				log.Println(err.Error())
			}
			defer updateDriver.Close()
			// Get Trip id
			var TripID int
			TripIDQuery, err := db.Query("SELECT CarProgressBarID FROM CarProgressBars WHERE `Car No Plate` = ? AND Date = ?", data.CarNoPlate, data.Date)
			if err != nil {
				log.Println(err.Error())
			}
			defer TripIDQuery.Close()
			for TripIDQuery.Next() {
				err = TripIDQuery.Scan(&TripID)
				if err != nil {
					log.Println(err.Error())
				}
			}
			return c.JSON(fiber.Map{
				"TripID":  "TripID",
				"message": "Car Trip Created",
			})
		}
	}
	return c.JSON(fiber.Map{
		"message": "Not Logged In.",
	})
}

type ExcelTrip struct {
	Date           string  `json:"Date"`
	Customer       string  `json:"Customer"`
	PickUpLocation string  `json:"PickUpLocation"`
	Transporter    string  `json:"Transporter"`
	TruckNo        string  `json:"TruckNo"`
	Diesel         float64 `json:"Diesel"`
	Gas80          float64 `json:"Gas80"`
	Gas92          float64 `json:"Gas92"`
	Gas95          float64 `json:"Gas95"`
	Mazoot         float64 `json:"Mazoot"`
	Total          float64 `json:"Total"`
	FeeRate        float64 `json:"FeeRate"`
	TotalFees      float64 `json:"TotalFees"`
}

func GenerateCSVTable(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var data struct {
				DateFrom string `json:"DateFrom"`
				DateTo   string `json:"DateTo"`
			}

			err := c.BodyParser(&data)

			if err != nil {
				log.Println(err.Error())
				return err
			}

			headers := map[string]string{
				"A1": "Date",
				"B1": "Customer",
				"C1": "المستودع",
				"D1": "Transporter",
				"E1": "Truck Number",
				"F1": "Diesel",
				"G1": "Gas 80",
				"H1": "Gas 92",
				"I1": "Gas 95",
				"J1": "مازوت",
				"K1": "المجموع",
				"L1": "الفئة",
				"M1": "التكلفة",
			}
			file := excelize.NewFile()
			for k, v := range headers {
				file.SetCellValue("Sheet1", k, v)
			}
			var trips []ExcelTrip
			db := Database.ConnectToDB()

			var Days int = DaysBetweenDates(data.DateFrom, data.DateTo)

			getTripsQuery, err := db.Query("SELECT `Date`, `Compartments`, `PickUpLocation`, `Transporter`, `Car No Plate`, `FeeRate` FROM `CarProgressBars` WHERE `Date` BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ? ORDER BY `Date`;", data.DateTo, Days, data.DateTo)
			if err != nil {
				log.Println(err.Error())
				return err
			}
			for getTripsQuery.Next() {
				var trip ExcelTrip
				var jsonCompartments string
				err = getTripsQuery.Scan(&trip.Date, &jsonCompartments, &trip.PickUpLocation, &trip.Transporter, &trip.TruckNo, &trip.FeeRate)
				if err != nil {
					log.Println(err.Error())
					return err
				}
				var TruckCompartments [][]interface{}
				err = json.Unmarshal([]byte(jsonCompartments), &TruckCompartments)
				if err != nil {
					log.Println(err.Error())
					return err
				}
				for _, s := range TruckCompartments {
					var tripFormatted ExcelTrip
					tripFormatted = trip
					tripFormatted.Customer = s[1].(string)
					switch s[2] {
					case "Diesel":
						tripFormatted.Diesel = s[0].(float64)
					case "Gas 80":
						tripFormatted.Gas80 = s[0].(float64)
					case "Gas 92":
						tripFormatted.Gas92 = s[0].(float64)
					case "Gas 95":
						tripFormatted.Gas95 = s[0].(float64)
					case "Mazoot":
						tripFormatted.Mazoot = s[0].(float64)
					}

					// if s[2] == "Gas 92" {
					// 	tripFormatted.Gas92 = int(s[0].(float64))
					// }
					tripFormatted.Total = tripFormatted.Diesel + tripFormatted.Gas80 + tripFormatted.Gas92 + tripFormatted.Gas95 + tripFormatted.Mazoot
					tripFormatted.TotalFees = tripFormatted.Total / 1000 * tripFormatted.FeeRate
					trips = append(trips, tripFormatted)
				}
				fmt.Println(TruckCompartments)
			}
			for i := 0; i < len(trips); i++ {
				appendRow(file, i, trips)
			}
			var filename string = fmt.Sprintf("./tasks.xlsx")
			err = file.SaveAs(filename)
			if err != nil {
				fmt.Println(err)
			}
			// c.Context().SetContentType("multipart/form-data")
			// return c.Response().SendFile("./tasks.xlsx")
			return c.SendFile("./tasks.xlsx", true)
		}
	}
	return c.JSON(fiber.Map{
		"message": "Not Logged In.",
	})
	// appendRow()
	// fmt.Println(tasks[1])
}

func appendRow(file *excelize.File, index int, row []ExcelTrip) (fileWriter *excelize.File) {
	rowCount := index + 2
	file.SetCellValue("Sheet1", fmt.Sprintf("A%v", rowCount), row[index].Date)
	file.SetCellValue("Sheet1", fmt.Sprintf("B%v", rowCount), row[index].Customer)
	file.SetCellValue("Sheet1", fmt.Sprintf("C%v", rowCount), row[index].PickUpLocation)
	file.SetCellValue("Sheet1", fmt.Sprintf("D%v", rowCount), row[index].Transporter)
	file.SetCellValue("Sheet1", fmt.Sprintf("E%v", rowCount), row[index].TruckNo)
	file.SetCellValue("Sheet1", fmt.Sprintf("F%v", rowCount), row[index].Diesel)
	file.SetCellValue("Sheet1", fmt.Sprintf("G%v", rowCount), row[index].Gas80)
	file.SetCellValue("Sheet1", fmt.Sprintf("H%v", rowCount), row[index].Gas92)
	file.SetCellValue("Sheet1", fmt.Sprintf("I%v", rowCount), row[index].Gas95)
	file.SetCellValue("Sheet1", fmt.Sprintf("J%v", rowCount), row[index].Mazoot)
	file.SetCellValue("Sheet1", fmt.Sprintf("K%v", rowCount), row[index].Total)
	file.SetCellValue("Sheet1", fmt.Sprintf("L%v", rowCount), row[index].FeeRate)
	file.SetCellValue("Sheet1", fmt.Sprintf("M%v", rowCount), row[index].TotalFees)
	return file

}

func EditCarTrip(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var data Trip
			if err := c.BodyParser(&data); err != nil {
				return err
			}
			// fmt.Println(data)
			//
			db := Database.ConnectToDB()
			_ = db
			// Step Complete Time
			var StepCompleteTime string
			// Format {"TruckLoad": ["", PickUpPoint], DropOffPoints: [[time, DropOffPoint]]}
			var TruckLoad []string
			TruckLoad = append(TruckLoad, "0")
			TruckLoad = append(TruckLoad, data.PickUpPoint)
			var DropOffPoints [][]string

			for _, DropOffPoint := range data.DropOffPoints {
				DropOffPoints = append(DropOffPoints, []string{"0", DropOffPoint})
			}
			// Step Complete Time
			StepCompleteTime = fmt.Sprintf("{\"TruckLoad\": [\"%v\",\"%v\", false], \"DropOffPoints\": [", TruckLoad[0], TruckLoad[1])
			for _, DropOffPoint := range DropOffPoints {
				StepCompleteTime = fmt.Sprintf("%v[\"%v\", \"%v\", false],", StepCompleteTime, DropOffPoint[0], DropOffPoint[1])
			}
			// Remove Last Comma
			StepCompleteTime = StepCompleteTime[:len(StepCompleteTime)-1]
			StepCompleteTime = fmt.Sprintf("%v]}", StepCompleteTime)
			// fmt.Println(StepCompleteTime)
			fmt.Println(data)
			jsonCompartments, err := json.Marshal(&data.Compartments)

			if err != nil {
				log.Println(err.Error())
			}

			getTransporter, err := db.Query("SELECT `Transporter` FROM `Cars` WHERE `CarNoPlate` = ?", data.CarNoPlate)

			if err != nil {
				log.Println(err.Error())
			}
			defer getTransporter.Close()
			var Transporter string
			for getTransporter.Next() {
				err = getTransporter.Scan(&Transporter)
				if err != nil {
					log.Println(err.Error())
					return err
				}
			}
			_, feeRate := GetTransportFee(data.DropOffPoints, data.PickUpPoint)

			var CurrentCarNoPlate string
			var CurrentDriverName string
			ValidationQuery, err := db.Query("SELECT `Car No Plate`, `Driver Name` FROM CarProgressBars WHERE `CarProgressBarID` = ?", data.TripId)
			if err != nil {
				log.Println(err.Error())
			}
			defer ValidationQuery.Close()
			for ValidationQuery.Next() {
				err = ValidationQuery.Scan(&CurrentCarNoPlate, &CurrentDriverName)
				if err != nil {
					log.Println(err.Error())
				}
				fmt.Println(CurrentCarNoPlate, CurrentDriverName)
			}

			if data.CarNoPlate != CurrentCarNoPlate {
				_, err := db.Exec("UPDATE `Cars` SET `IsInTrip` = ? WHERE `CarNoPlate` = ?", "false", CurrentCarNoPlate)
				if err != nil {
					return err
				}
			}

			if data.DriverName != CurrentDriverName {
				_, err := db.Exec("UPDATE `users` SET `IsInTrip` = ? WHERE `name` = ?", "false", CurrentDriverName)
				if err != nil {
					return err
				}
			}
			fmt.Println(Transporter)
			updateTrip, err := db.Query("UPDATE `CarProgressBars` SET `Date` = ?, `Car No Plate` = ?, `CarProgressIndex` = ?, `Driver Name` = ?, `StepCompleteTime` = ?, `NoOfDropOffPoints` = ?, `Compartments` = ?, `FeeRate` = ?, `IsInTrip` = ?, `Transporter` = ? WHERE `CarProgressBarID` = ?", data.Date, data.CarNoPlate, 0, data.DriverName, StepCompleteTime, data.NoOfDropOffPoints, jsonCompartments, feeRate, "true", Transporter, data.TripId)
			if err != nil {
				log.Println(err.Error())
			}
			defer updateTrip.Close()
			// fmt.Println(data)
			updateCar, err := db.Query("UPDATE `Cars` SET `IsInTrip` = ? WHERE `CarNoPlate` = ?", "true", data.CarNoPlate)
			if err != nil {
				log.Println(err.Error())
			}
			defer updateCar.Close()
			updateDriver, err := db.Query("UPDATE `users` SET `IsInTrip` = ? WHERE `name` = ?", "true", data.DriverName)
			if err != nil {
				log.Println(err.Error())
			}
			defer updateDriver.Close()
			// Get Trip id

			return c.JSON(fiber.Map{
				"TripID":  "TripID",
				"message": "Car Trip Created",
			})
		}
	}
	return c.JSON(fiber.Map{
		"message": "Not Logged In.",
	})
}

func GetVehicleMapPoints(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else if Controllers.CurrentUser.Permission >= 2 {
			return c.JSON(Scrapper.VehicleStatusList)
		} else if Controllers.CurrentUser.Permission == 1 {
			db := Database.ConnectToDB()
			defer db.Close()
			Cars, err := db.Query("SELECT `CarNoPlate` FROM `Cars` WHERE `Transporter` = ?", Controllers.CurrentUser.Name)

			if err != nil {
				log.Println(err.Error())
			}
			var CarPlates []string
			var CarsList []Scrapper.VehicleStatusStruct
			for Cars.Next() {
				var carPlate string
				Cars.Scan(&carPlate)
				CarPlates = append(CarPlates, carPlate)
			}

			for _, scrapperPlate := range Scrapper.VehicleStatusList {
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

func GetLocations(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			db := Database.ConnectToDB()

			defer db.Close()
			CustomerQuery, err := db.Query("SELECT DISTINCT `CustomerName` FROM `PriceList` WHERE 1;")

			if err != nil {
				log.Println(err.Error())
			}

			var Customers []string

			defer CustomerQuery.Close()
			for CustomerQuery.Next() {
				var customer string
				err = CustomerQuery.Scan(&customer)
				if err != nil {
					log.Println(err.Error())
				}
				Customers = append(Customers, customer)
			}
			TerminalQuery, err := db.Query("SELECT DISTINCT `Terminal` FROM `PriceList` WHERE 1;")

			if err != nil {
				log.Println(err.Error())
			}

			var Terminals []string

			defer TerminalQuery.Close()
			for TerminalQuery.Next() {
				var terminal string
				err = TerminalQuery.Scan(&terminal)
				if err != nil {
					log.Println(err.Error())
				}
				Terminals = append(Terminals, terminal)
			}
			return c.JSON(fiber.Map{
				"Customers": Customers,
				"Terminals": Terminals,
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetTransportFee(CustomerNames []string, Terminal string) (int, int) {
	db := Database.ConnectToDB()
	defer db.Close()
	var Distance int
	var TransportFee int

	for _, Customer := range CustomerNames {
		fmt.Println(Customer)
		query, err := db.Query("SELECT `Distance`, `TransportFee` FROM `PriceList` WHERE `CustomerName` = ? AND `Terminal` = ?;", Customer, Terminal)
		if err != nil {
			log.Println(err.Error())
		}
		defer query.Close()
		var response struct {
			Distance     int `json:"Distance"`
			TransportFee int `json:"TransportFee"`
		}
		for query.Next() {
			err = query.Scan(&response.Distance, &response.TransportFee)
			if err != nil {
				log.Println(err.Error())
			}
		}
		Distance += response.Distance
		if response.TransportFee > TransportFee {
			TransportFee = response.TransportFee
		}
	}

	return Distance, TransportFee
}
