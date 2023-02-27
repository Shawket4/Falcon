package Apis

import (
	"Falcon/AbstractFunctions"
	"Falcon/Controllers"
	"Falcon/Database"
	"Falcon/Models"
	"Falcon/Scrapper"
	"archive/tar"
	"compress/gzip"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"time"

	"github.com/gofiber/fiber/v2"
	"gorm.io/datatypes"
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
	Id           int    `json:"Id"`
	Name         string `json:"Name"`
	Email        string `json:"Email"`
	Permission   int    `json:"Permission"`
	MobileNumber string `json:"Mobile_Number"`
}

func GetProgressOfCars(c *fiber.Ctx) error {
	// Fetch all cars from database
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var Data struct {
				DateFrom string `json:"DateFrom"`
				DateTo   string `json:"DateTo"`
			}
			// defer cars.Close()
			if err := c.BodyParser(&Data); err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
				})
			}

			// var Cars []TripStruct

			// Make Days variable to store the number of days between the two dates
			var Days int = DaysBetweenDates(Data.DateFrom, Data.DateTo)

			var Cars []Models.TripStruct
			//var trips *sql.Rows
			if Controllers.CurrentUser.Permission >= 1 && Controllers.CurrentUser.Permission != 4 {
				if err := Models.DB.Model(&Models.TripStruct{}).Where("date BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?", Data.DateTo, Days, Data.DateTo).Where("transporter = ?", Controllers.CurrentUser.Name).Find(&Cars).Error; err != nil {
					log.Println(err.Error())
					return err
				}
				//trips, err = db.Query("SELECT `CarProgressBarID`, `Car No Plate`, `CarProgressIndex`, `Driver Name`, `StepCompleteTime`, `NoOfDropOffPoints`, `Date`, `Compartments`, `FeeRate`, `Milage`, `start_time`, `end_time`, `IsInTrip` FROM CarProgressBars WHERE Date BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ? AND `Transporter` = ? ORDER BY `Date` DESC;", Data.DateTo, Days, Data.DateTo, Controllers.CurrentUser.Name)
			} else if Controllers.CurrentUser.Permission == 4 {
				if err := Models.DB.Model(&Models.TripStruct{}).Where("date BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?", Data.DateTo, Days, Data.DateTo).Find(&Cars).Error; err != nil {
					log.Println(err.Error())
					return err
				}
				//trips, err = db.Query("SELECT `CarProgressBarID`, `Car No Plate`, `CarProgressIndex`, `Driver Name`, `StepCompleteTime`, `NoOfDropOffPoints`, `Date`, `Compartments`, `FeeRate`, `Milage`, `start_time`, `end_time`, `IsInTrip` FROM CarProgressBars WHERE Date BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ? ORDER BY `Date` DESC;", Data.DateTo, Days, Data.DateTo)
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
			All     bool   `json:"All"`
		}
		var data dataStruct
		if err := c.BodyParser(&data); err != nil {
			log.Println(err.Error())
			return c.JSON(fiber.Map{
				"message": err.Error(),
			})
		}

		var cars []Models.Car
		fmt.Println(Controllers.CurrentUser.Permission)
		if Controllers.CurrentUser.Permission >= 1 && Controllers.CurrentUser.Permission != 4 {
			if data.All {
				if err := Models.DB.Model(&Models.Car{}).Where("transporter = ?", Controllers.CurrentUser.Name).Find(&cars).Error; err != nil {
					log.Println(err.Error())
					return err
				}
				//cars, err = db.Query("SELECT `CarNoPlate`, `Compartments`, `IsInTrip` FROM `Cars` WHERE `IsApproved` = 1 AND `Transporter` = ?;", Controllers.CurrentUser.Name)
			} else {
				if err := Models.DB.Model(&Models.Car{}).Where("transporter = ?", Controllers.CurrentUser.Name).Find(&cars).Error; err != nil {
					log.Println(err.Error())
					return err
				}
				//cars, err = db.Query("SELECT `CarNoPlate`, `Compartments`, `IsInTrip` FROM `Cars` WHERE `LicenseExpirationDate` > CURRENT_DATE() AND `CalibrationExpirationDate` > CURRENT_DATE() AND `IsApproved` = 1 AND `Transporter` =?;", Controllers.CurrentUser.Name)
			}
		} else if Controllers.CurrentUser.Permission == 4 {
			if data.All {
				if err := Models.DB.Model(&Models.Car{}).Find(&cars).Error; err != nil {
					log.Println(err.Error())
					return err
				}
				//cars, err = db.Query("SELECT `CarNoPlate`, `Compartments`, `IsInTrip` FROM `Cars` WHERE `IsApproved` = 1;")
			} else {
				if err := Models.DB.Model(&Models.Car{}).Find(&cars).Error; err != nil {
					log.Println(err.Error())
					return err
				}
				//cars, err = db.Query("SELECT `CarNoPlate`, `Compartments`, `IsInTrip` FROM `Cars` WHERE `LicenseExpirationDate` > CURRENT_DATE() AND `CalibrationExpirationDate` > CURRENT_DATE() AND `IsApproved` = 1;")
			}
		}
		//if err != nil {
		//	log.Println(err.Error())
		//}
		//defer cars.Close()
		//var CarNoPlates []string
		//var Compartments [][]int
		//var IsInTripList []bool
		//for cars.Next() {
		//	var carNoPlateStruct struct {
		//		CarNoPlate   string `json:"CarNoPlate"`
		//		Compartments []int  `json:"Compartments"`
		//		IsInTrip     bool   `json:"IsInTrip"`
		//	}
		//	var jsonData string
		//	var IsInTrip string
		//	err = cars.Scan(&carNoPlateStruct.CarNoPlate, &jsonData, &IsInTrip)
		//	json.Unmarshal([]byte(jsonData), &carNoPlateStruct.Compartments)
		//	if err != nil {
		//		log.Println(err.Error())
		//	}
		//
		//	if IsInTrip == "true" {
		//		carNoPlateStruct.IsInTrip = true
		//	} else {
		//		carNoPlateStruct.IsInTrip = false
		//	}
		//
		//	CarNoPlates = append(CarNoPlates, carNoPlateStruct.CarNoPlate)
		//	Compartments = append(Compartments, carNoPlateStruct.Compartments)
		//	IsInTripList = append(IsInTripList, carNoPlateStruct.IsInTrip)
		//}
		//if data.Include != "" {
		//	includedCar, err := db.Query("SELECT `CarNoPlate`, `Compartments`, `IsInTrip` FROM `Cars` WHERE `CarNoPlate` = ?", data.Include)
		//	if err != nil {
		//		log.Println(err.Error())
		//	}
		//	defer includedCar.Close()
		//	for includedCar.Next() {
		//		var carNoPlateStruct struct {
		//			CarNoPlate   string `json:"CarNoPlate"`
		//			Compartments []int  `json:"Compartments"`
		//			IsInTrip     bool   `json:"IsInTrip"`
		//		}
		//		var jsonData string
		//		var IsInTrip string
		//		err = includedCar.Scan(&carNoPlateStruct.CarNoPlate, &jsonData, &IsInTrip)
		//		json.Unmarshal([]byte(jsonData), &carNoPlateStruct.Compartments)
		//		if err != nil {
		//			log.Println(err.Error())
		//		}
		//		if IsInTrip == "true" {
		//			carNoPlateStruct.IsInTrip = true
		//		} else {
		//			carNoPlateStruct.IsInTrip = false
		//		}
		//		CarNoPlates = append(CarNoPlates, carNoPlateStruct.CarNoPlate)
		//		Compartments = append(Compartments, carNoPlateStruct.Compartments)
		//		IsInTripList = append(IsInTripList, carNoPlateStruct.IsInTrip)
		//	}
		//}
		return c.JSON(cars)
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetDrivers(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {

		var drivers []Models.Driver

		if Controllers.CurrentUser.Permission >= 1 && Controllers.CurrentUser.Permission != 4 {
			if err := Models.DB.Model(&Models.Driver{}).Where("transporter = ?", Controllers.CurrentUser.Name).Find(&drivers).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			//drivers, err = db.Query("SELECT `name` FROM `drivers` WHERE AND `driver_license_expiration_date` > CURRENT_DATE() AND `safety_license_expiration_date` > CURRENT_DATE() AND `drug_test_expiration_date` > CURRENT_DATE() AND `is_in_trip` = 0 AND `is_approved` = 1 AND `transporter` = ?;", Controllers.CurrentUser.Name)
		} else if Controllers.CurrentUser.Permission == 4 {
			if err := Models.DB.Model(&Models.Driver{}).Find(&drivers).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			//drivers, err = db.Query("SELECT `name` FROM `drivers` WHERE AND `driver_license_expiration_date` > CURRENT_DATE() AND `safety_license_expiration_date` > CURRENT_DATE() AND `drug_test_expiration_date` > CURRENT_DATE() AND `is_in_trip` = 0 AND `is_approved` = 1;")
		}

		return c.JSON(drivers)
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
			var Transporters []string
			if err := Models.DB.Model(&Models.User{}).Where("permission >= 2").Select("name").Find(&Transporters).Error; err != nil {
				log.Println(err.Error())
				return err
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

// func RegisterCar(c *fiber.Ctx) error {
// 	Controllers.User(c)
// 	if Controllers.CurrentUser.Id != 0 {
// 		if Controllers.CurrentUser.Permission == 0 {
// 			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
// 		} else {
// 			db := Database.ConnectToDB()
// 			// Get the body of the request
// 			// Convert the body to a map
// 			var car Car
// 			formData := c.FormValue("request")
// 			// format formData into data map
// 			err := json.Unmarshal([]byte(formData), &car)
// 			if err != nil {
// 				log.Println(err)
// 			}
// 			// err := c.BodyParser(&car)
// 			// if err != nil {
// 			// 	log.Println(err.Error())
// 			// 	return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
// 			// }

// 			jsonCompartments, err := json.Marshal(car.Compartments)
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
// 			}
// 			if Controllers.CurrentUser.Permission >= 3 {
// 				car.IsApproved = 1
// 			} else {
// 				car.IsApproved = 0
// 			}
// 			if car.Transporter == "" {
// 				car.Transporter = Controllers.CurrentUser.Name
// 			}
// 			carLicense, err := c.FormFile("CarLicense")
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}
// 			// Save file to disk
// 			// Allow multipart form
// 			err = c.SaveFile(carLicense, fmt.Sprintf("./CarLicenses/%s", carLicense.Filename))
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}
// 			carLicenseBack, err := c.FormFile("CarLicenseBack")
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}
// 			// Save file to disk
// 			// Allow multipart form
// 			err = c.SaveFile(carLicenseBack, fmt.Sprintf("./CarLicenses/%s", carLicenseBack.Filename))
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}

// 			calibrationLicense, err := c.FormFile("CalibrationLicense")
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}
// 			// Save file to disk
// 			// Allow multipart form
// 			err = c.SaveFile(calibrationLicense, fmt.Sprintf("./CalibrationLicenses/%s", calibrationLicense.Filename))
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}
// 			calibrationLicenseBack, err := c.FormFile("CalibrationLicenseBack")
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}
// 			// Save file to disk
// 			// Allow multipart form
// 			err = c.SaveFile(calibrationLicenseBack, fmt.Sprintf("./CalibrationLicenses/%s", calibrationLicenseBack.Filename))
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}

// 			tankLicense, err := c.FormFile("TankLicense")
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}
// 			// Save file to disk
// 			// Allow multipart form
// 			err = c.SaveFile(tankLicense, fmt.Sprintf("./TankLicenses/%s", tankLicense.Filename))
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}

// 			tankLicenseBack, err := c.FormFile("TankLicenseBack")
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}
// 			// Save file to disk
// 			// Allow multipart form
// 			err = c.SaveFile(tankLicenseBack, fmt.Sprintf("./TankLicensesBack/%s", tankLicenseBack.Filename))
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.JSON(fiber.Map{
// 					"message": err.Error(),
// 					"file":    "save",
// 				})
// 			}

// 			// Insert the car into the database
// 			_, err = db.Exec("INSERT INTO `Cars` (`CarId`, `CarNoPlate`, `Transporter`, `TankCapacity`, `Compartments`, `LicenseExpirationDate`, `CalibrationExpirationDate`, `TankLicenseExpirationDate`, `IsApproved`, `CarLicenseImageName`, `CalibrationLicenseImageName`, `CarLicenseImageNameBack`, `CalibrationLicenseImageNameBack`, `TankLicenseImageName`, `TankLicenseImageNameBack`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", car.CarNoPlate, car.Transporter, car.TankCapacity, jsonCompartments, car.LicenseExpirationDate, car.CalibrationExpirationDate, car.TankLicenseExpirationDate, car.IsApproved, carLicense.Filename, calibrationLicense.Filename, carLicenseBack.Filename, calibrationLicenseBack.Filename, tankLicense.Filename, tankLicenseBack.Filename)
// 			if err != nil {
// 				log.Println(err.Error())
// 				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
// 			}
// 			return c.JSON(
// 				fiber.Map{
// 					"Message":    "Car added successfully",
// 					"CarNoPlate": car.CarNoPlate,
// 				},
// 			)
// 		}
// 	} else {
// 		return c.JSON(fiber.Map{
// 			"message": "Not Logged In.",
// 		})
// 	}
// }

func RegisterCar(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			// Get the body of the request
			// Convert the body to a map
			var car Models.Car
			formData := c.FormValue("request")
			// format formData into data map
			if err := json.Unmarshal([]byte(formData), &car); err != nil {
				log.Println(err)
				return err
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
				car.IsApproved = true
			} else {
				car.IsApproved = false
			}
			if Controllers.CurrentUser.Permission >= 1 && Controllers.CurrentUser.Permission != 4 {
				car.Transporter = Controllers.CurrentUser.Name
			}

			// Insert the car into the database
			car.JSONCompartments = datatypes.JSON(jsonCompartments)
			carLicense, err := c.FormFile("CarLicense")
			if err != nil {
				log.Println(err.Error())
				log.Println("CarLicense")
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
				log.Println("CarLicense")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			carLicenseBack, err := c.FormFile("CarLicenseBack")
			if err != nil {
				log.Println(err.Error())
				log.Println("CarLicenseBack")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(carLicenseBack, fmt.Sprintf("./CarLicensesBack/%s", carLicenseBack.Filename))
			if err != nil {
				log.Println(err.Error())
				log.Println("CarLicenseBack")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}

			if car.CarType == "تريلا" {
				tankLicense, err := c.FormFile("TankLicense")
				if err != nil {
					log.Println(err.Error())
					log.Println("TankLicense")
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
					log.Println("TankLicense")
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				tankLicenseBack, err := c.FormFile("TankLicenseBack")
				if err != nil {
					log.Println(err.Error())
					log.Println("TankLicenseBack")
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
					log.Println("TankLicenseBack")
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				car.TankLicenseImageName = tankLicense.Filename
				car.TankLicenseImageNameBack = tankLicenseBack.Filename
			}

			calibrationLicense, err := c.FormFile("CalibrationLicense")
			if err != nil {
				log.Println(err.Error())
				log.Println("CalibrationLicense")
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
				log.Println("CalibrationLicense")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			calibrationLicenseBack, err := c.FormFile("CalibrationLicenseBack")
			if err != nil {
				log.Println(err.Error())
				log.Println("CalibrationLicenseBack")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(calibrationLicenseBack, fmt.Sprintf("./CalibrationLicensesBack/%s", calibrationLicenseBack.Filename))
			if err != nil {
				log.Println(err.Error())
				log.Println("CalibrationLicenseBack")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			car.CarLicenseImageName = carLicense.Filename
			car.CarLicenseImageNameBack = carLicenseBack.Filename
			car.CalibrationLicenseImageName = calibrationLicense.Filename
			car.CalibrationLicenseImageNameBack = calibrationLicenseBack.Filename

			if err := Models.DB.Save(&car).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			//_, err = db.Exec("INSERT INTO `Cars` (`CarId`, `CarNoPlate`, `Transporter`, `TankCapacity`, `Compartments`, `LicenseExpirationDate`, `CalibrationExpirationDate`, `TankLicenseExpirationDate`, `IsApproved`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?)", car.CarNoPlate, car.Transporter, car.TankCapacity, jsonCompartments, car.LicenseExpirationDate, car.CalibrationExpirationDate, car.TankLicenseExpirationDate, 1)
			//if err != nil {
			//	log.Println(err.Error())
			//	return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			//}
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
		} else if Controllers.CurrentUser.Permission >= 1 && Controllers.CurrentUser.Permission != 4 {
			var Cars []Models.Car
			if err := Models.DB.Model(&Models.Car{}).Where("transporter = ?", Controllers.CurrentUser.Name).Find(&Cars).Error; err != nil {
				log.Println(err.Error())
				return err
			}

			for _, car := range Cars {
				var compartments []int
				err := json.Unmarshal(car.JSONCompartments, &compartments)
				if err != nil {
					log.Println(err.Error())
				}
				car.Compartments = compartments
			}

			return c.JSON(Cars)
		} else {
			var Cars []Models.Car
			if err := Models.DB.Model(&Models.Car{}).Find(&Cars).Error; err != nil {
				log.Println(err.Error())
				return err
			}

			for _, car := range Cars {
				var compartments []int
				err := json.Unmarshal(car.JSONCompartments, &compartments)
				if err != nil {
					log.Println(err.Error())
				}
				car.Compartments = compartments
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
		} else if Controllers.CurrentUser.Permission >= 1 && Controllers.CurrentUser.Permission != 4 {
			var Drivers []Models.Driver
			if err := Models.DB.Model(&Models.Driver{}).Where("transporter = ?", Controllers.CurrentUser.Name).Find(&Drivers).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			//query, err := db.Query("SELECT `id`, `name`, `email`, `mobile_number`, `driver_license_expiration_date`, `safety_license_expiration_date`, `drug_test_expiration_date`, `IsApproved`, `Transporter`, `DriverLicenseImageName`, `SafetyLicenseImageName`, `DrugTestImageName`, `DriverLicenseImageNameBack`, `SafetyLicenseImageNameBack`, `DrugTestImageNameBack` FROM `users` WHERE permission = 0 AND `IsApproved` = 1 AND `Transporter` = ?", Controllers.CurrentUser.Name)
			//if err != nil {
			//	log.Println(err.Error())
			//}
			//defer query.Close()
			//
			//for query.Next() {
			//	var driver Driver
			//	err = query.Scan(&driver.DriverId, &driver.Name, &driver.Email, &driver.MobileNumber, &driver.LicenseExpirationDate, &driver.SafetyExpirationDate, &driver.DrugTestExpirationDate, &driver.IsApproved, &driver.Transporter, &driver.DriverLicenseImageName, &driver.SafetyLicenseImageName, &driver.DrugTestImageName, &driver.DriverLicenseImageNameBack, &driver.SafetyLicenseImageNameBack, &driver.DrugTestImageNameBack)
			//	if err != nil {
			//		log.Println(err.Error())
			//	}
			//	Drivers = append(Drivers, driver)
			return c.JSON(Drivers)
		} else {
			//db := Database.ConnectToDB()
			var Drivers []Models.Driver
			if err := Models.DB.Model(&Models.Driver{}).Find(&Drivers).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			//query, err := db.Query("SELECT `id`, `name`, `email`, `mobile_number`, `driver_license_expiration_date`, `safety_license_expiration_date`, `drug_test_expiration_date`, `IsApproved`, `Transporter`, `DriverLicenseImageName`, `SafetyLicenseImageName`, `DrugTestImageName`, `DriverLicenseImageNameBack`, `SafetyLicenseImageNameBack`, `DrugTestImageNameBack` FROM `users` WHERE permission = 0 AND `IsApproved` = 1;")
			//if err != nil {
			//	log.Println(err.Error())
			//}
			//defer query.Close()
			//
			//for query.Next() {
			//	var driver Driver
			//	err = query.Scan(&driver.DriverId, &driver.Name, &driver.Email, &driver.MobileNumber, &driver.LicenseExpirationDate, &driver.SafetyExpirationDate, &driver.DrugTestExpirationDate, &driver.IsApproved, &driver.Transporter, &driver.DriverLicenseImageName, &driver.SafetyLicenseImageName, &driver.DrugTestImageName, &driver.DriverLicenseImageNameBack, &driver.SafetyLicenseImageNameBack, &driver.DrugTestImageNameBack)
			//	if err != nil {
			//		log.Println(err.Error())
			//	}
			//	Drivers = append(Drivers, driver)
			//}
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
			var Driver struct {
				ID uint `json:"ID"`
			}
			if err := c.BodyParser(&Driver); err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			if err := Models.DB.Delete(&Models.Driver{}, Driver.ID).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			//_, err = db.Exec("DELETE FROM `drivers` WHERE `name` = ?;", Driver.Name)
			//if err != nil {
			//	log.Println(err.Error())
			//	return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			//}
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
			var Car struct {
				ID uint `json:"ID"`
			}
			if err := c.BodyParser(&Car); err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			if err := Models.DB.Delete(&Models.Car{}, Car.ID).Error; err != nil {
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

func UpdateCar(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var input Models.Car
			formData := c.FormValue("request")
			// format formData into data map
			if err := json.Unmarshal([]byte(formData), &input); err != nil {
				log.Println(err)
				return err
			}

			// err := c.BodyParser(&car)
			// if err != nil {
			// 	log.Println(err.Error())
			// 	return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			// }

			jsonCompartments, err := json.Marshal(input.Compartments)
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}

			if input.Transporter == "" {
				input.Transporter = Controllers.CurrentUser.Name
			}

			var car Models.Car
			if err := Models.DB.Model(&Models.Car{}).Where("id = ?", input.ID).Find(&car).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			car.CarNoPlate = input.CarNoPlate
			car.CarType = input.CarType
			car.Transporter = input.Transporter
			car.TankCapacity = input.TankCapacity
			car.JSONCompartments = jsonCompartments
			car.LicenseExpirationDate = input.LicenseExpirationDate
			car.CalibrationExpirationDate = input.CalibrationExpirationDate
			car.TankLicenseExpirationDate = input.TankLicenseExpirationDate

			carLicense, err := c.FormFile("CarLicense")
			if err != nil {
				log.Println(err.Error())
				log.Println("CarLicense")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			err = c.SaveFile(carLicense, fmt.Sprintf("./CarLicenses/%s", carLicense.Filename))
			if err != nil {
				log.Println(err.Error())
				log.Println("CarLicense")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			carLicenseBack, err := c.FormFile("CarLicenseBack")
			if err != nil {
				log.Println(err.Error())
				log.Println("CarLicenseBack")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(carLicenseBack, fmt.Sprintf("./CarLicensesBack/%s", carLicenseBack.Filename))
			if err != nil {
				log.Println(err.Error())
				log.Println("CarLicenseBack")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}

			if car.CarType == "تريلا" {
				tankLicense, err := c.FormFile("TankLicense")
				if err != nil {
					log.Println(err.Error())
					log.Println("TankLicense")
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
					log.Println("TankLicense")
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				tankLicenseBack, err := c.FormFile("TankLicenseBack")
				if err != nil {
					log.Println(err.Error())
					log.Println("TankLicenseBack")
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
					log.Println("TankLicenseBack")
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				car.TankLicenseImageName = tankLicense.Filename
				car.TankLicenseImageNameBack = tankLicenseBack.Filename
			}

			calibrationLicense, err := c.FormFile("CalibrationLicense")
			if err != nil {
				log.Println(err.Error())
				log.Println("CalibrationLicense")
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
				log.Println("CalibrationLicense")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			calibrationLicenseBack, err := c.FormFile("CalibrationLicenseBack")
			if err != nil {
				log.Println(err.Error())
				log.Println("CalibrationLicenseBack")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			// Save file to disk
			// Allow multipart form
			err = c.SaveFile(calibrationLicenseBack, fmt.Sprintf("./CalibrationLicensesBack/%s", calibrationLicenseBack.Filename))
			if err != nil {
				log.Println(err.Error())
				log.Println("CalibrationLicenseBack")
				return c.JSON(fiber.Map{
					"message": err.Error(),
					"file":    "save",
				})
			}
			car.CarLicenseImageName = carLicense.Filename
			car.CarLicenseImageNameBack = carLicenseBack.Filename
			car.CalibrationLicenseImageName = calibrationLicense.Filename
			car.CalibrationLicenseImageNameBack = calibrationLicenseBack.Filename
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			if err := Models.DB.Save(&car).Error; err != nil {
				log.Println(err.Error())
				return err
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
			var data struct {
				TripId int `json:"TripId"`
			}
			if err := c.BodyParser(&data); err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			var trip Models.TripStruct
			if err := Models.DB.Model(&Models.TripStruct{}).Where("id = ?", data.TripId).Find(&trip).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			var car Models.Car
			if err := Models.DB.Model(&Models.Car{}).Where("id = ?", trip.CarID).Find(&car).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			var driver Models.Driver
			if err := Models.DB.Model(&Models.Driver{}).Where("id = ?", trip.DriverID).Find(&driver).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			car.IsInTrip = false
			driver.IsInTrip = false
			if err := Models.DB.Save(&car).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			if err := Models.DB.Save(&driver).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			if err := Models.DB.Delete(&Models.TripStruct{}, trip.ID).Error; err != nil {
				log.Println(err.Error())
				return err
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
			Cars, err := db.Query("SELECT `CarId`, `CarNoPlate`, `Transporter`, `TankCapacity`, `Compartments`, `LicenseExpirationDate`, `CalibrationExpirationDate`, `TankLicenseExpirationDate`, `IsApproved`, `CarLicenseImageName`, `CalibrationLicenseImageName`, `TankLicenseImageName`, `CarLicenseImageNameBack`, `CalibrationLicenseImageNameBack`, `TankLicenseImageName` FROM `Cars` WHERE `IsApproved` = 0;")
			if err != nil {
				log.Println(err.Error())
				return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
			}
			defer Cars.Close()
			var CarsArray []Car
			for Cars.Next() {
				var car Car
				var jsonData string
				err := Cars.Scan(&car.CarId, &car.CarNoPlate, &car.Transporter, &car.TankCapacity, &jsonData, &car.LicenseExpirationDate, &car.CalibrationExpirationDate, &car.TankLicenseExpirationDate, &car.IsApproved, &car.CarLicenseImageName, &car.CalibrationLicenseImageName, &car.TankLicenseImageName, &car.CarLicenseImageNameBack, &car.CalibrationLicenseImageNameBack, &car.TankLicenseImageNameBack)
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
				err := Users.Scan(&user.Id, &user.Name, &user.Email, &user.Permission, &user.MobileNumber)
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
	HasDriver         bool            `json:"HasDriver"`
	DriverName        string          `json:"DriverName"`
	Date              string          `json:"Date"`
	CarNoPlate        string          `json:"CarNoPlate"`
	PickUpPoint       string          `json:"PickUpPoint"`
	NoOfDropOffPoints int             `json:"NoOfDropOffPoints"`
	DropOffPoints     []string        `json:"DropOffPoints"`
	Compartments      [][]interface{} `json:"Compartments"`
}

func UpdateCarStatusByID(CarID uint) (*Models.Car, error) {
	var car Models.Car
	if err := Models.DB.Model(&Models.Car{}).Where("id = ?", CarID).Find(&car).Error; err != nil {
		log.Println(err.Error())
		return nil, err
	}
	car.IsInTrip = true
	if err := Models.DB.Save(&car).Error; err != nil {
		log.Println(err.Error())
		return nil, err
	}
	return &car, nil
}

func UpdateDriverStatusByID(DriverID uint) (*Models.Driver, error) {
	var driver Models.Driver
	if err := Models.DB.Model(&Models.Driver{}).Where("id = ?", DriverID).Find(&driver).Error; err != nil {
		log.Println(err.Error())
		return nil, err
	}
	driver.IsInTrip = true
	if err := Models.DB.Save(&driver).Error; err != nil {
		log.Println(err.Error())
		return nil, err
	}
	return &driver, nil
}

func CreateCarTrip(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var data Models.TripStruct
			if err := c.BodyParser(&data); err != nil {
				return err
			}
			// Step Complete Time

			// Format {"TruckLoad": ["", PickUpPoint], DropOffPoints: [[time, DropOffPoint]]}
			//{"TruckLoad": ["", "Exxon Mobile Mostrod", true], "DropOffPoints": [["", "هاي ميكس بدر", true], ["", "هاي ميكس بدر", true]]}

			startDate, err := AbstractFunctions.GetFormattedDate(data.Date)
			if err != nil {
				log.Println(err)
				return c.JSON(err.Error())
			}
			data.StartTime = startDate + "%2000:00:00"
			//insert, err := db.Query("INSERT INTO CarProgressBars (`CarProgressBarID`, `Date`, `start_time`, `end_time`, `Car No Plate`, `CarProgressIndex`, `Driver Name`, `StepCompleteTime`, `NoOfDropOffPoints`, `Compartments`, `PickUpLocation`, `Transporter`, `FeeRate`, `IsInTrip`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", data.Date, startTime, "", data.CarNoPlate, 0, data.DriverName, StepCompleteTime, data.NoOfDropOffPoints, jsonCompartments, data.PickUpPoint, Transporter, feeRate, "true")
			//if err != nil {
			//	log.Println(err.Error())
			//}
			// fmt.Println(data)
			car, err := UpdateCarStatusByID(data.CarID)
			if err != nil {
				log.Println(err.Error())
				return err
			}
			data.CarNoPlate = car.CarNoPlate
			data.TankCapacity = car.TankCapacity
			data.Transporter = car.Transporter
			driver, err := UpdateDriverStatusByID(data.DriverID)
			if err != nil {
				log.Println(err.Error())
				return err
			}
			data.DriverName = driver.Name
			if data.StepCompleteTimeDB, err = json.Marshal(data.StepCompleteTime); err != nil {
				log.Println(err.Error())
				return err
			}
			data.IsClosed = false
			if err := Models.DB.Create(&data).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			return c.JSON(fiber.Map{
				"TripID":  data.ID,
				"message": "Car Trip Created",
			})
		}
	}
	return c.JSON(fiber.Map{
		"message": "Not Logged In.",
	})
}

func EditCarTrip(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var data Models.TripStruct
			if err := c.BodyParser(&data); err != nil {
				return err
			}
			// Step Complete Time

			// Format {"TruckLoad": ["", PickUpPoint], DropOffPoints: [[time, DropOffPoint]]}
			//{"TruckLoad": ["", "Exxon Mobile Mostrod", true], "DropOffPoints": [["", "هاي ميكس بدر", true], ["", "هاي ميكس بدر", true]]}

			startDate, err := AbstractFunctions.GetFormattedDate(data.Date)
			if err != nil {
				log.Println(err)
				return c.JSON(err.Error())
			}
			data.StartTime = startDate + "%2000:00:00"
			//insert, err := db.Query("INSERT INTO CarProgressBars (`CarProgressBarID`, `Date`, `start_time`, `end_time`, `Car No Plate`, `CarProgressIndex`, `Driver Name`, `StepCompleteTime`, `NoOfDropOffPoints`, `Compartments`, `PickUpLocation`, `Transporter`, `FeeRate`, `IsInTrip`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", data.Date, startTime, "", data.CarNoPlate, 0, data.DriverName, StepCompleteTime, data.NoOfDropOffPoints, jsonCompartments, data.PickUpPoint, Transporter, feeRate, "true")
			//if err != nil {
			//	log.Println(err.Error())
			//}
			// fmt.Println(data)
			car, err := UpdateCarStatusByID(data.CarID)
			if err != nil {
				log.Println(err.Error())
				return err
			}
			data.CarNoPlate = car.CarNoPlate
			data.TankCapacity = car.TankCapacity
			data.Transporter = car.Transporter
			driver, err := UpdateDriverStatusByID(data.DriverID)
			if err != nil {
				log.Println(err.Error())
				return err
			}
			data.DriverName = driver.Name
			if data.StepCompleteTimeDB, err = json.Marshal(data.StepCompleteTime); err != nil {
				log.Println(err.Error())
				return err
			}
			data.IsClosed = false
			var trip Models.TripStruct
			if err := Models.DB.Model(&Models.TripStruct{}).Where("id = ?", data.ID).Find(&trip).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			trip.CarID = data.CarID
			trip.DriverID = data.DriverID
			trip.CarNoPlate = data.CarNoPlate
			trip.DriverName = data.DriverName
			trip.Transporter = data.Transporter
			trip.TankCapacity = data.TankCapacity
			trip.PickUpPoint = data.PickUpPoint
			trip.ProgressIndex = data.ProgressIndex
			trip.StepCompleteTime = data.StepCompleteTime
			trip.StepCompleteTimeDB = data.StepCompleteTimeDB
			trip.NoOfDropOffPoints = data.NoOfDropOffPoints
			trip.Date = data.Date
			trip.Mileage = 0
			trip.FeeRate = 0
			trip.StartTime = data.StartTime
			trip.EndTime = data.EndTime
			trip.IsClosed = false
			if err := Models.DB.Save(&trip).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			return c.JSON(fiber.Map{
				"message": "Car Trip Updated",
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
		} else if Controllers.CurrentUser.Permission == 4 {
			return c.JSON(Scrapper.VehicleStatusList)
		} else if Controllers.CurrentUser.Permission >= 1 {
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
			CustomerQuery, err := db.Query("SELECT `CustomerName` FROM `Customers` WHERE 1;")

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
			TerminalQuery, err := db.Query("SELECT `TerminalName` FROM `Terminals` WHERE 1;")

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

func CreateServiceEvent(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var input Models.Service
			formData := c.FormValue("request")
			if err := json.Unmarshal([]byte(formData), &input); err != nil {
				log.Println(err)
				return err
			}
			var car Models.Car
			if err := Models.DB.Model(&Models.Car{}).Where("id = ?", input.CarID).Find(&car).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			input.CarNoPlate = car.CarNoPlate
			input.Transporter = Controllers.CurrentUser.Name
			// proofFile, err := c.FormFile("ProofFile")
			// if err != nil {
			// 	log.Println(err.Error())
			// 	return c.JSON(fiber.Map{
			// 		"message": err.Error(),
			// 		"file":    "save",
			// 	})
			// }

			// err = c.SaveFile(proofFile, fmt.Sprintf("./ServiceProofs/%s", proofFile.Filename))
			// if err != nil {
			// 	log.Println(err.Error())
			// 	return c.JSON(fiber.Map{
			// 		"message": err.Error(),
			// 		"file":    "save",
			// 	})
			// }

			// input.ProofImageName = proofFile.Filename
			_, err := input.Add()
			if err != nil {
				log.Println(err)
				return err
			}

			return c.JSON(fiber.Map{
				"message": "Service Event Registered Successfully.",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func EditServiceEvent(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var input Models.Service
			if err := c.BodyParser(&input); err != nil {
				log.Println(err.Error())
				return err
			}
			// formData := c.FormValue("request")
			// if err := json.Unmarshal([]byte(formData), &input); err != nil {
			// 	log.Println(err)
			// 	return err
			// }
			var car Models.Car
			if err := Models.DB.Where("id = ?", input.CarID).Find(&car).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			input.CarNoPlate = car.CarNoPlate

			var serviceEvent Models.Service
			if err := Models.DB.Model(&Models.Service{}).Where("id = ?", input.ID).Find(&serviceEvent).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			serviceEvent.CarID = input.CarID
			serviceEvent.CarNoPlate = input.CarNoPlate
			serviceEvent.DateOfService = input.DateOfService
			serviceEvent.OdometerReading = input.OdometerReading
			serviceEvent.ProofImageName = input.ProofImageName
			_, err := serviceEvent.Edit()
			if err != nil {
				log.Println(err)
				return err
			}

			return c.JSON(fiber.Map{
				"message": "Service Event Updated Successfully.",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func DeleteServiceEvent(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var input struct {
				ID uint `json:"ID"`
			}
			if err := c.BodyParser(&input); err != nil {
				log.Println(err.Error())
				return err
			}
			var serviceEvent Models.Service
			if err := Models.DB.Model(&Models.Service{}).Where("id = ?", input.ID).Find(&serviceEvent).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			if err := Models.DB.Delete(&Models.Service{}, serviceEvent).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			return c.JSON(fiber.Map{
				"message": "Service Event Deleted Successfully",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetAllServiceEvents(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var serviceEvents []Models.Service
			if Controllers.CurrentUser.Permission == 4 {
				if err := Models.DB.Model(&Models.Service{}).Find(&serviceEvents).Error; err != nil {
					log.Println(err.Error())
					return err
				}
			} else {
				if err := Models.DB.Model(&Models.Service{}).Where("transporter = ?", Controllers.CurrentUser.Name).Find(&serviceEvents).Error; err != nil {
					log.Println(err.Error())
					return err
				}
			}
			return c.JSON(fiber.Map{
				"ServiceEvents": serviceEvents,
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func createTarAndGz(fileNames map[string]string, buffer io.Writer) error {
	gzipWriter := gzip.NewWriter(buffer)
	defer gzipWriter.Close()
	tarWriter := tar.NewWriter(gzipWriter)
	defer tarWriter.Close()
	for filepath, filename := range fileNames {
		err := addToTar(tarWriter, filename, filepath)
		if err != nil {
			return err
		}
	}
	return nil
}

func addToTar(tarWriter *tar.Writer, filename string, filepath string) error {
	file, err := os.Open(filepath)
	if err != nil {
		return err
	}
	defer file.Close()
	info, err := file.Stat()
	if err != nil {
		return err
	}
	header, err := tar.FileInfoHeader(info, info.Name())
	if err != nil {
		return err
	}
	header.Name = filename
	err = tarWriter.WriteHeader(header)
	if err != nil {
		return err
	}
	_, err = io.Copy(tarWriter, file)
	if err != nil {
		return err
	}

	return nil
}

func GetPhotoAlbum(c *fiber.Ctx) error {
	var data struct {
		ID   uint   `json:"id"`
		Type string `json:"type"`
	}
	if err := c.BodyParser(&data); err != nil {
		log.Println(err.Error())
		return err
	}
	if data.Type == "Car" {
		Files := make(map[string]string)
		var car Models.Car
		if err := Models.DB.Model(&Models.Car{}).Where("id = ?", data.ID).Find(&car).Error; err != nil {
			log.Println(err.Error())
			return err
		}

		archiveFilename := fmt.Sprintf("./CarArchives/%s_Photos.tar.gz", car.CarNoPlate)
		outFile, err := os.Create(archiveFilename)
		if err != nil {
			log.Fatalf("Failed to open zip for writing: %s", err)
		}

		Files[fmt.Sprintf("./CarLicenses/%s", car.CarLicenseImageName)] = car.CarLicenseImageName
		Files[fmt.Sprintf("./CarLicensesBack/%s", car.CarLicenseImageNameBack)] = car.CarLicenseImageNameBack
		Files[fmt.Sprintf("./CalibrationLicenses/%s", car.CalibrationLicenseImageName)] = car.CalibrationLicenseImageName
		Files[fmt.Sprintf("./CalibrationLicensesBack/%s", car.CalibrationLicenseImageNameBack)] = car.CalibrationLicenseImageNameBack
		if car.CarType == "تريلا" {
			Files[fmt.Sprintf("./TankLicenses/%s", car.TankLicenseImageName)] = car.TankLicenseImageName
			Files[fmt.Sprintf("./TankLicensesBack/%s", car.TankLicenseImageNameBack)] = car.TankLicenseImageNameBack
		}

		if err := createTarAndGz(Files, outFile); err != nil {
			log.Println(err.Error())
			return err
		}
		fmt.Println(archiveFilename)
		return c.SendFile(archiveFilename)
	}
	if data.Type == "Driver" {
		Files := make(map[string]string)
		var driver Models.Driver
		if err := Models.DB.Model(&Models.Driver{}).Where("id = ?", data.ID).Find(&driver).Error; err != nil {
			log.Println(err.Error())
			return err
		}

		archiveFilename := fmt.Sprintf("./DriverArchives/%s_Photos.tar.gz", driver.Name)
		outFile, err := os.Create(archiveFilename)
		if err != nil {
			log.Fatalf("Failed to open zip for writing: %s", err)
		}
		Files[fmt.Sprintf("./CriminalRecords/%s", driver.CriminalRecordImageName)] = driver.CriminalRecordImageName
		Files[fmt.Sprintf("./IDLicenses/%s", driver.IDLicenseImageName)] = driver.IDLicenseImageName
		Files[fmt.Sprintf("./IDLicensesBack/%s", driver.IDLicenseImageNameBack)] = driver.IDLicenseImageNameBack
		Files[fmt.Sprintf("./DriverLicenses/%s", driver.DriverLicenseImageName)] = driver.DriverLicenseImageName
		Files[fmt.Sprintf("./SafetyLicenses/%s", driver.SafetyLicenseImageName)] = driver.SafetyLicenseImageName
		Files[fmt.Sprintf("./DrugTests/%s", driver.DrugTestImageName)] = driver.DrugTestImageName

		if err := createTarAndGz(Files, outFile); err != nil {
			log.Println(err.Error())
			return err
		}
		fmt.Println(archiveFilename)
		return c.SendFile(archiveFilename)
	}
	return c.JSON("Failed")
}
