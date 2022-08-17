package Controllers

import (
	"Falcon/Database"
	"Falcon/Models"
	"encoding/json"
	"fmt"
	"log"

	"github.com/gofiber/fiber/v2"
)

type NewTrip struct {
	DriverName        string   `json:"DriverName"`
	Date              string   `json:"Date"`
	CarNoPlate        string   `json:"CarNoPlate"`
	PickUpPoint       string   `json:"PickUpPoint"`
	NoOfDropOffPoints int      `json:"NoOfDropOffPoints"`
	DropOffPoints     []string `json:"DropOffPoints"`
}

func CreateCarTrip(c *fiber.Ctx) error {
	if CurrentUser.Id != 0 {
		var data NewTrip
		if err := c.BodyParser(&data); err != nil {
			return err
		}

		// fmt.Println(data)
		//
		db := Database.ConnectToDB()
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
		fmt.Println(StepCompleteTime)
		// Convert DropOffPoints To Array
		// var DropOffPoints []string
		// for i := 0; i < len(data["DropOffPoints"]); i++ {
		// 	if data["DropOffPoints"][i] == ',' {
		// 		DropOffPoints = append(DropOffPoints, data["DropOffPoints"][i+1:])
		// 	}
		// }

		// Check If Car Progress Bar Exists

		// CarProgressBarExistsQuery, err := db.Query("SELECT COUNT(*) FROM CarProgressBars WHERE `Car No Plate` = ? AND Date = ?", data.CarNoPlate, data.Date)
		// if err != nil {
		// 	log.Println(err.Error())
		// }
		// defer CarProgressBarExistsQuery.Close()
		// for CarProgressBarExistsQuery.Next() {
		// 	var count int
		// 	err = CarProgressBarExistsQuery.Scan(&count)
		// 	if err != nil {
		// 		log.Println(err.Error())
		// 	}
		// 	if count != 0 {
		// 		// Remove Car Progress Bar
		// 		_, err := db.Exec("DELETE FROM CarProgressBars WHERE `Car No Plate` = ? AND Date = ?", data.CarNoPlate, data.Date)
		// 		if err != nil {
		// 			log.Println(err.Error())
		// 		}
		// 	}
		// }

		insert, err := db.Query("INSERT INTO CarProgressBars (`CarProgressBarID`, `Date`, `Car No Plate`, `CarProgressIndex`, `Driver Name`, `StepCompleteTime`, `NoOfDropOffPoints`, `IsInTrip`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?)", data.Date, data.CarNoPlate, 0, data.DriverName, StepCompleteTime, data.NoOfDropOffPoints, "true")
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
			"TripID":  TripID,
			"message": "Car Trip Created",
		})
	}
	return c.JSON(fiber.Map{
		"message": "Not Logged In.",
	})
}

type DriverStruct struct {
	DriverName string           `json:"DriverName"`
	IsInTrip   bool             `json:"IsInTrip"`
	TripStruct Models.CarStruct `json:"Trip"`
}

func GetDriverTrip(c *fiber.Ctx) error {
	User(c)
	if CurrentUser.Id != 0 {
		db := Database.ConnectToDB()
		var data DriverStruct
		// Get Date From body parser
		var bodyDate struct {
			Date string `json:"Date"`
		}
		// Get Date From body parser
		err := c.BodyParser(&bodyDate)
		if err != nil {
			return err
		}

		data.DriverName = CurrentUser.Name
		var TripID int
		// Get the trip of the driver
		Trip, err := db.Query("SELECT `CarProgressBarID`, `Car No Plate`, `CarProgressIndex`, `StepCompleteTime`, `NoOfDropOffPoints`, `Driver Name` FROM CarProgressBars WHERE `Driver Name` = ? AND `Date` = ? AND `IsInTrip` = ?", data.DriverName, bodyDate.Date, "true")

		if err != nil {
			return err
		}

		defer Trip.Close()
		for Trip.Next() {
			err = Trip.Scan(&TripID, &data.TripStruct.CarNoPlate, &data.TripStruct.ProgressIndex, &data.TripStruct.StepCompleteTime, &data.TripStruct.NoOfDropOffPoints, &data.TripStruct.DriverName)
			if err != nil {
				return c.JSON(err)
			}
			data.IsInTrip = true
		}
		// Get Car Details
		CarDetails, err := db.Query("SELECT `CarId`, `TankCapacity` FROM Cars WHERE `CarNoPlate` = ?", data.TripStruct.CarNoPlate)
		if err != nil {
			return c.JSON(err)
		}
		defer CarDetails.Close()
		for CarDetails.Next() {
			err = CarDetails.Scan(&data.TripStruct.CarID, &data.TripStruct.TankCapacity)
			if err != nil {
				return c.JSON(err)
			}
		}
		data.TripStruct.DriverName = CurrentUser.Name
		// Get the trip id

		// Return the trip of the driver
		return c.JSON(fiber.Map{
			"IsInTrip": data.IsInTrip,
			"TripID":   TripID,
			"Trip":     data.TripStruct,
		})
	} else {
		return c.JSON(fiber.Map{
			"IsInTrip": false,
		})
	}
}

func NextStep(c *fiber.Ctx) error {
	User(c)
	if CurrentUser.Id != 0 {
		db := Database.ConnectToDB()
		var data DriverStruct
		var bodyData struct {
			Date   string `json:"Date"`
			Time   string `json:"Time"`
			TripId int    `json:"TripId"`
		}
		// Get Date From body parser
		err := c.BodyParser(&bodyData)
		if err != nil {
			return err
		}
		// if data.DriverName == "" {
		// 	data.DriverName = CurrentUser.Name
		// }
		// Get the trip of the driver
		Trip, err := db.Query("SELECT `StepCompleteTime` FROM CarProgressBars WHERE `CarProgressBarID` = ?", bodyData.TripId)

		if err != nil {
			return err
		}

		defer Trip.Close()
		for Trip.Next() {
			err = Trip.Scan(&data.TripStruct.StepCompleteTime)
			if err != nil {
				return c.JSON(err)
			}
			data.IsInTrip = true
		}
		data.TripStruct.DriverName = CurrentUser.Name
		// Get the trip id
		// Marshall Trip Step Complete Time to JSON
		jsonData, err := json.Marshal(data.TripStruct.StepCompleteTime)
		if err != nil {
			fmt.Println(err.Error())
			return c.JSON(err)
		}
		_ = jsonData
		// Convert json to map
		var mapData struct {
			TruckLoad     []interface{}   `json:"TruckLoad"`
			DropOffPoints [][]interface{} `json:"DropOffPoints"`
		}

		err = json.Unmarshal([]byte(data.TripStruct.StepCompleteTime), &mapData)

		if err != nil {
			fmt.Println(err.Error())
			return c.JSON(err)
		}
		// Check the last true bool
		if mapData.TruckLoad[2] == false {
			mapData.TruckLoad[2] = true
			mapData.TruckLoad[0] = bodyData.Time
		} else {

			var lastTrue int

			for _, v := range mapData.DropOffPoints {
				if v[2] == true {
					lastTrue++
				}
			}
			if lastTrue < len(mapData.DropOffPoints) {
				mapData.DropOffPoints[lastTrue][2] = true
				mapData.DropOffPoints[lastTrue][0] = bodyData.Time
			}
			// Return the trip of the driver
		}
		// Marshall map to json
		jsonData, err = json.Marshal(mapData)
		if err != nil {
			fmt.Println(err.Error())
			return c.JSON(err)
		}
		// Update the trip of the driver
		_, err = db.Exec("UPDATE CarProgressBars SET `StepCompleteTime` = ? WHERE `CarProgressBarID` = ?", string(jsonData), bodyData.TripId)
		if err != nil {
			return c.JSON(err)
		}
		return c.JSON(fiber.Map{
			"message": "Next Step",
		})
	} else {
		return c.JSON(fiber.Map{
			"IsInTrip": false,
		})
	}
}

func PreviousStep(c *fiber.Ctx) error {
	User(c)
	if CurrentUser.Id != 0 {
		db := Database.ConnectToDB()
		var data DriverStruct
		// Get Date From body parser
		var bodyData struct {
			Date   string `json:"Date"`
			TripId int    `json:"TripId"`
		}
		// Get Date From body parser
		err := c.BodyParser(&bodyData)
		if err != nil {
			return err
		}
		data.DriverName = CurrentUser.Name
		// Get the trip of the driver
		Trip, err := db.Query("SELECT `StepCompleteTime` FROM CarProgressBars WHERE `CarProgressBarID` = ?", bodyData.TripId)

		if err != nil {
			return err
		}

		defer Trip.Close()
		for Trip.Next() {
			err = Trip.Scan(&data.TripStruct.StepCompleteTime)
			if err != nil {
				return c.JSON(err)
			}
			data.IsInTrip = true
		}
		data.TripStruct.DriverName = CurrentUser.Name
		// Get the trip id
		// Marshall Trip Step Complete Time to JSON
		jsonData, err := json.Marshal(data.TripStruct.StepCompleteTime)
		if err != nil {
			fmt.Println(err.Error())
			return c.JSON(err)
		}
		_ = jsonData
		// Convert json to map
		var mapData struct {
			TruckLoad     []interface{}   `json:"TruckLoad"`
			DropOffPoints [][]interface{} `json:"DropOffPoints"`
		}

		err = json.Unmarshal([]byte(data.TripStruct.StepCompleteTime), &mapData)

		if err != nil {
			fmt.Println(err.Error())
			return c.JSON(err)
		}
		// Check the last true bool
		if mapData.TruckLoad[2] == true {

			var lastTrue int = -1

			for _, v := range mapData.DropOffPoints {
				if v[2] == true {
					lastTrue++
				}
			}

			if lastTrue == -1 {
				lastTrue = 4
			}
			if lastTrue == 4 {
				mapData.TruckLoad[2] = false
			} else if lastTrue < len(mapData.DropOffPoints) {
				mapData.DropOffPoints[lastTrue][2] = false
			}
			// Return the trip of the driver
		}
		// Marshall map to json
		jsonData, err = json.Marshal(mapData)
		if err != nil {
			fmt.Println(err.Error())
			return c.JSON(err)
		}
		// Update the trip of the driver
		_, err = db.Exec("UPDATE CarProgressBars SET `StepCompleteTime` = ? WHERE `CarProgressBarID` = ?", string(jsonData), bodyData.TripId)
		if err != nil {
			return c.JSON(err)
		}
		return c.JSON(fiber.Map{
			"message": "Previous Step",
		})
	} else {
		return c.JSON(fiber.Map{
			"IsInTrip": false,
		})
	}
}

func CompleteTrip(c *fiber.Ctx) error {
	User(c)
	if CurrentUser.Id != 0 {
		//Get Trip
		db := Database.ConnectToDB()

		// Get Date From body parser
		var bodyData struct {
			Date       string `json:"Date"`
			CarNoPlate string `json:"CarNoPlate"`
			TripId     int    `json:"TripId"`
			DriverName string `json:"DriverName"`
		}
		c.BodyParser(&bodyData)

		// Update the trip of the driver
		_, err := db.Exec("UPDATE `CarProgressBars` SET `IsInTrip` = ? WHERE `CarProgressBarID` = ?", "false", bodyData.TripId)
		if err != nil {
			return c.JSON(err)
		}
		_, err = db.Exec("UPDATE `Cars` SET `IsInTrip` = ? WHERE `CarNoPlate` = ?", "false", bodyData.CarNoPlate)
		if err != nil {
			return c.JSON(err)
		}
		_, err = db.Exec("UPDATE `users` SET `IsInTrip` = ? WHERE `name` = ?", "false", bodyData.DriverName)
		if err != nil {
			return c.JSON(err)
		}
		return c.JSON(fiber.Map{
			"message": "Trip Completed",
		})
	} else {
		return c.JSON(fiber.Map{
			"message": "Driver Isn't In A Trip.",
		})
	}
}
