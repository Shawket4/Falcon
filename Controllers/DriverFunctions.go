package Controllers

import (
	"Falcon/Models"
	"Falcon/Scrapper"
	"encoding/json"
	"fmt"
	"log"

	"github.com/gofiber/fiber/v2"
)

//type DriverStruct struct {
//	DriverName   string            `json:"DriverName"`
//	IsInTrip     bool              `json:"IsInTrip"`
//	Compartments []int             `json:"Compartments"`
//	TripStruct   Models.TripStruct `json:"Trip"`
//}

//	func GetDriverTrip(c *fiber.Ctx) error {
//		User(c)
//		if CurrentUser.Id != 0 {
//			db := Database.ConnectToDB()
//			var data DriverStruct
//
//			data.DriverName = CurrentUser.Name
//			var TripID int
//			// Get the trip of the driver
//			Trip, err := db.Query("SELECT `CarProgressBarID`, `Car No Plate`, `CarProgressIndex`, `StepCompleteTime`, `NoOfDropOffPoints`, `Driver Name`, `Compartments` FROM CarProgressBars WHERE `Driver Name` = ? AND `IsInTrip` = ?", data.DriverName, "true")
//
//			if err != nil {
//				return err
//			}
//
//			defer Trip.Close()
//			var jsonCompartments string
//
//			for Trip.Next() {
//				err = Trip.Scan(&TripID, &data.TripStruct.CarNoPlate, &data.TripStruct.ProgressIndex, &data.TripStruct.StepCompleteTime, &data.TripStruct.NoOfDropOffPoints, &data.TripStruct.DriverName, &jsonCompartments)
//				if err != nil {
//					return c.JSON(err)
//				}
//
//				err = json.Unmarshal([]byte(jsonCompartments), &data.Compartments)
//
//				if err != nil {
//					log.Println(err.Error())
//					return err
//				}
//				data.IsInTrip = true
//			}
//			// Get Car Details
//			CarDetails, err := db.Query("SELECT `CarId`, `TankCapacity` FROM Cars WHERE `CarNoPlate` = ?", data.TripStruct.CarNoPlate)
//			if err != nil {
//				return c.JSON(err)
//			}
//			defer CarDetails.Close()
//			for CarDetails.Next() {
//				err = CarDetails.Scan(&data.TripStruct.CarID, &data.TripStruct.TankCapacity)
//				if err != nil {
//					return c.JSON(err)
//				}
//			}
//			data.TripStruct.DriverName = CurrentUser.Name
//			// Get the trip id
//
//			// Return the trip of the driver
//			return c.JSON(fiber.Map{
//				"IsInTrip":     data.IsInTrip,
//				"TripID":       TripID,
//				"Compartments": data.Compartments,
//				"Trip":         data.TripStruct,
//			})
//		} else {
//			return c.JSON(fiber.Map{
//				"IsInTrip": false,
//			})
//		}
//	}
func NextStep(c *fiber.Ctx) error {
	User(c)
	if CurrentUser.Id != 0 {
		var bodyData struct {
			Date          string `json:"Date"`
			Time          string `json:"Time"`
			TimeFormatted string `json:"TimeFormatted"`
			DateFormatted string `json:"DateFormatted"`
			TripId        int    `json:"TripId"`
		}
		// Get Date From body parser
		err := c.BodyParser(&bodyData)
		if err != nil {
			return err
		}

		var Trip Models.TripStruct

		if err := Models.DB.Model(&Models.TripStruct{}).Where("id = ?", bodyData.TripId).Find(&Trip).Error; err != nil {
			log.Println(err.Error())
			return err
		}

		if err := json.Unmarshal(Trip.StepCompleteTimeDB, &Trip.StepCompleteTime); err != nil {
			log.Println(err.Error())
			return err
		}

		if !Trip.StepCompleteTime.Terminal.Status {
			Trip.StepCompleteTime.Terminal.Status = true
			Trip.StepCompleteTime.Terminal.TimeStamp = bodyData.Time
			Trip.StartTime = bodyData.DateFormatted + "%20" + bodyData.TimeFormatted
			Trip.StepCompleteTimeDB, _ = json.Marshal(Trip.StepCompleteTime)
			if err := Models.DB.Save(&Trip).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			return c.JSON(fiber.Map{
				"message": "Next Step",
			})
		}

		for i, dropOffPoint := range Trip.StepCompleteTime.DropOffPoints {
			if !dropOffPoint.Status {
				Trip.StepCompleteTime.DropOffPoints[i].Status = true
				Trip.StepCompleteTime.DropOffPoints[i].TimeStamp = bodyData.Time
				break
			}
		}
		Trip.StepCompleteTimeDB, _ = json.Marshal(Trip.StepCompleteTime)
		if err := Models.DB.Save(&Trip).Error; err != nil {
			log.Println(err.Error())
			return err
		}

		return c.JSON(fiber.Map{
			"message": "Next Step",
		})
	} else {
		return c.JSON(fiber.Map{
			"message": "User Not Logged In.",
		})
	}
}

func PreviousStep(c *fiber.Ctx) error {
	User(c)
	if CurrentUser.Id != 0 {
		var bodyData struct {
			TripId int `json:"TripId"`
		}
		// Get Date From body parser
		err := c.BodyParser(&bodyData)
		if err != nil {
			return err
		}

		var Trip Models.TripStruct

		if err := Models.DB.Model(&Models.TripStruct{}).Where("id = ?", bodyData.TripId).Find(&Trip).Error; err != nil {
			log.Println(err.Error())
			return err
		}

		if err := json.Unmarshal(Trip.StepCompleteTimeDB, &Trip.StepCompleteTime); err != nil {
			log.Println(err.Error())
			return err
		}

		for i := len(Trip.StepCompleteTime.DropOffPoints) - 1; i >= 0; i-- {
			if Trip.StepCompleteTime.DropOffPoints[i].Status {
				Trip.StepCompleteTime.DropOffPoints[i].Status = false
				Trip.StepCompleteTimeDB, err = json.Marshal(Trip.StepCompleteTime)
				if err := Models.DB.Save(&Trip).Error; err != nil {
					log.Println(err.Error())
					return err
				}

				return c.JSON(fiber.Map{
					"message": "Previous Step",
				})
			}
		}

		if Trip.StepCompleteTime.Terminal.Status {
			Trip.StepCompleteTime.Terminal.Status = false
			Trip.StepCompleteTimeDB, err = json.Marshal(Trip.StepCompleteTime)
			if err := Models.DB.Save(&Trip).Error; err != nil {
				log.Println(err.Error())
				return err
			}
		}
		return c.JSON(fiber.Map{
			"message": "Previous Step",
		})
	} else {
		return c.JSON(fiber.Map{
			"message": "User Not Logged In.",
		})
	}
}

//	func PreviousStep(c *fiber.Ctx) error {
//		User(c)
//		if CurrentUser.Id != 0 {
//			db := Database.ConnectToDB()
//			var data DriverStruct
//			// Get Date From body parser
//			var bodyData struct {
//				Date   string `json:"Date"`
//				TripId int    `json:"TripId"`
//			}
//			// Get Date From body parser
//			err := c.BodyParser(&bodyData)
//			if err != nil {
//				return err
//			}
//			data.DriverName = CurrentUser.Name
//			// Get the trip of the driver
//			Trip, err := db.Query("SELECT `StepCompleteTime` FROM CarProgressBars WHERE `CarProgressBarID` = ?", bodyData.TripId)
//
//			if err != nil {
//				return err
//			}
//
//			defer Trip.Close()
//			for Trip.Next() {
//				err = Trip.Scan(&data.TripStruct.StepCompleteTime)
//				if err != nil {
//					return c.JSON(err)
//				}
//				data.IsInTrip = true
//			}
//			data.TripStruct.DriverName = CurrentUser.Name
//			// Get the trip id
//			// Marshall Trip Step Complete Time to JSON
//			jsonData, err := json.Marshal(data.TripStruct.StepCompleteTime)
//			if err != nil {
//				fmt.Println(err.Error())
//				return c.JSON(err)
//			}
//			_ = jsonData
//			// Convert json to map
//			var mapData struct {
//				TruckLoad     []interface{}   `json:"TruckLoad"`
//				DropOffPoints [][]interface{} `json:"DropOffPoints"`
//			}
//
//			err = json.Unmarshal([]byte(data.TripStruct.StepCompleteTime), &mapData)
//
//			if err != nil {
//				fmt.Println(err.Error())
//				return c.JSON(err)
//			}
//			// Check the last true bool
//			if mapData.TruckLoad[2] == true {
//
//				var lastTrue int = -1
//
//				for _, v := range mapData.DropOffPoints {
//					if v[2] == true {
//						lastTrue++
//					}
//				}
//
//				if lastTrue == -1 {
//					lastTrue = 4
//				}
//				if lastTrue == 4 {
//					mapData.TruckLoad[2] = false
//				} else if lastTrue < len(mapData.DropOffPoints) {
//					mapData.DropOffPoints[lastTrue][2] = false
//				}
//				// Return the trip of the driver
//			}
//			// Marshall map to json
//			jsonData, err = json.Marshal(mapData)
//			if err != nil {
//				fmt.Println(err.Error())
//				return c.JSON(err)
//			}
//			// Update the trip of the driver
//			_, err = db.Exec("UPDATE CarProgressBars SET `StepCompleteTime` = ? WHERE `CarProgressBarID` = ?", string(jsonData), bodyData.TripId)
//			if err != nil {
//				return c.JSON(err)
//			}
//			return c.JSON(fiber.Map{
//				"message": "Previous Step",
//			})
//		} else {
//			return c.JSON(fiber.Map{
//				"IsInTrip": false,
//			})
//		}
//	}
func CompleteTrip(c *fiber.Ctx) error {
	User(c)
	if CurrentUser.Id != 0 {
		var bodyData struct {
			StartDateFormatted string `json:"StartDateFormatted"`
			StartTimeFormatted string `json:"StartTimeFormatted"`
			StartTime          string `json:"StartTime"`
			CurrentTime        string `json:"CurrentTime"`
			EndDateFormatted   string `json:"EndDateFormatted"`
			EndTimeFormatted   string `json:"EndTimeFormatted"`
			EndTime            string `json:"EndTime"`
			TripId             int    `json:"TripId"`
		}
		if err := c.BodyParser(&bodyData); err != nil {
			log.Println(err.Error())
			return err
		}
		fmt.Println(bodyData)
		var trip Models.TripStruct
		if err := Models.DB.Model(&Models.TripStruct{}).Where("id = ?", bodyData.TripId).Find(&trip).Error; err != nil {
			log.Println(err.Error())
			return err
		}

		var car Models.Car
		if err := Models.DB.Model(&Models.Car{}).Where("id = ?", trip.CarID).Find(&car).Error; err != nil {
			log.Println(err.Error())
			return err
		}
		car.IsInTrip = false
		if err := Models.DB.Save(&car).Error; err != nil {
			log.Println(err.Error())
			return err
		}
		var driver Models.Driver
		if err := Models.DB.Model(&Models.Driver{}).Where("id = ?", trip.DriverID).Find(&driver).Error; err != nil {
			log.Println(err.Error())
			return err
		}
		driver.IsInTrip = false
		if err := Models.DB.Save(&driver).Error; err != nil {
			log.Println(err.Error())
			return err
		}
		trip.EndTime = bodyData.EndDateFormatted + "%20" + bodyData.EndTimeFormatted
		trip.StartTime = bodyData.StartDateFormatted + "%20" + bodyData.StartTimeFormatted
		var truckID string
		fmt.Println(Scrapper.VehicleStatusList)
		for _, vehicle := range Scrapper.VehicleStatusList {
			if vehicle.PlateNo == car.CarNoPlate {
				truckID = vehicle.ID
			}
		}
		feeRate, mileage, err := Scrapper.GetFeeRate(Scrapper.MileageStruct{VehiclePlateNo: car.CarNoPlate, StartTime: trip.StartTime, EndTime: trip.EndTime, VehicleID: truckID})
		if err != nil {
			log.Println(err.Error())
		}
		if err := json.Unmarshal(trip.StepCompleteTimeDB, &trip.StepCompleteTime); err != nil {
			log.Println(err.Error())
			return err
		}
		if !trip.StepCompleteTime.Terminal.Status {
			trip.StepCompleteTime.Terminal.Status = true
			trip.StepCompleteTime.Terminal.TimeStamp = bodyData.StartTime
		}
		for i := range trip.StepCompleteTime.DropOffPoints {
			if !trip.StepCompleteTime.DropOffPoints[i].Status {
				trip.StepCompleteTime.DropOffPoints[i].Status = true
				trip.StepCompleteTime.DropOffPoints[i].TimeStamp = bodyData.EndTime
			}
		}
		trip.StepCompleteTimeDB, _ = json.Marshal(trip.StepCompleteTime)
		trip.FeeRate = feeRate
		trip.Mileage = mileage
		trip.IsClosed = true
		if err := Models.DB.Save(&trip).Error; err != nil {
			log.Println(err.Error())
			return err
		}
		return c.JSON(fiber.Map{
			"message": "Trip Closed Successfully",
		})
	} else {
		return c.JSON(fiber.Map{
			"message": "User Not Logged In",
		})
	}
}

//func CompleteTrip(c *fiber.Ctx) error {
//	User(c)
//	if CurrentUser.Id != 0 {
//		//Get Trip
//		db := Database.ConnectToDB()
//
//		// Get Date From body parser
//		var bodyData struct {
//			Date               string `json:"Date"`
//			DateFormatted      string `json:"DateFormatted"`
//			TimeFormatted      string `json:"TimeFormatted"`
//			StartDateFormatted string `json:"StartDateFormatted"`
//			StartTimeFormatted string `json:"StartTimeFormatted"`
//			New                bool   `json:"New"`
//			CarNoPlate         string `json:"CarNoPlate"`
//			TripId             int    `json:"TripId"`
//			DriverName         string `json:"DriverName"`
//			HasDriver          bool   `json:"HasDriver"`
//		}
//		c.BodyParser(&bodyData)
//		var start_time string
//		var end_time string
//		var truckId string
//		if bodyData.New {
//			start_time = fmt.Sprintf("%s%s", bodyData.StartDateFormatted+"%20", bodyData.StartTimeFormatted)
//			end_time = fmt.Sprintf("%s%s", bodyData.DateFormatted+"%20", bodyData.TimeFormatted)
//		} else {
//			end_time_query, err := db.Query("SELECT `end_time` FROM `CarProgressBars` WHERE `CarProgressBarID` = ?", bodyData.TripId)
//			for end_time_query.Next() {
//				err := end_time_query.Scan(&end_time)
//				if err != nil {
//					log.Println(err)
//					return err
//				}
//			}
//			if err != nil {
//				log.Println(err)
//				return err
//			}
//			defer end_time_query.Close()
//			if end_time == "" {
//				end_time = fmt.Sprintf("%s%s", bodyData.DateFormatted+"%20", bodyData.TimeFormatted)
//			}
//			start_query, err := db.Query("SELECT `start_time` FROM `CarProgressBars` WHERE `CarProgressBarID` = ?", bodyData.TripId)
//			if err != nil {
//				log.Println(err)
//				return err
//			}
//			defer start_query.Close()
//			for start_query.Next() {
//				err := start_query.Scan(&start_time)
//				if err != nil {
//					log.Println(err)
//					return err
//				}
//			}
//		}
//		for _, s := range Scrapper.VehicleStatusList {
//			if s.PlateNo == bodyData.CarNoPlate {
//				truckId = s.ID
//			}
//		}
//		NextStep(c)
//		NextStep(c)
//		NextStep(c)
//		NextStep(c)
//		NextStep(c)
//
//		fmt.Println(start_time)
//		fmt.Println(end_time)
//		feeRate, milage := Scrapper.GetFeeRate(Scrapper.MileageStruct{VehiclePlateNo: bodyData.CarNoPlate, StartTime: start_time, EndTime: end_time, VehicleID: truckId})
//		fmt.Printf("FeeRate: %f\n", feeRate)
//		fmt.Printf("Milage: %f", milage)
//		// Update the trip of the driver
//		_, err := db.Exec("UPDATE `CarProgressBars` SET `IsInTrip` = ?, `start_time` = ?, `end_time` = ?, `Milage` = ?, `FeeRate` = ? WHERE `CarProgressBarID` = ?", "false", start_time, end_time, milage, feeRate, bodyData.TripId)
//		if err != nil {
//			return c.JSON(err)
//		}
//		_, err = db.Exec("UPDATE `Cars` SET `IsInTrip` = ? WHERE `CarNoPlate` = ?", "false", bodyData.CarNoPlate)
//		if err != nil {
//			return c.JSON(err)
//		}
//		_, err = db.Exec("UPDATE `users` SET `IsInTrip` = ? WHERE `name` = ?", "false", bodyData.DriverName)
//		if err != nil {
//			return c.JSON(err)
//		}
//		return c.JSON(fiber.Map{
//			"message": "Trip Completed",
//		})
//	} else {
//		return c.JSON(fiber.Map{
//			"message": "Driver Isn't In A Trip.",
//		})
//	}
//}
