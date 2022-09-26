package Controllers

import (
	"Falcon/Database"
	"Falcon/Models"
	"encoding/json"
	"fmt"
	"log"

	"github.com/gofiber/fiber/v2"
)

type DriverStruct struct {
	DriverName   string           `json:"DriverName"`
	IsInTrip     bool             `json:"IsInTrip"`
	Compartments []int            `json:"Compartments"`
	TripStruct   Models.CarStruct `json:"Trip"`
}

func GetDriverTrip(c *fiber.Ctx) error {
	User(c)
	if CurrentUser.Id != 0 {
		db := Database.ConnectToDB()
		var data DriverStruct

		data.DriverName = CurrentUser.Name
		var TripID int
		// Get the trip of the driver
		Trip, err := db.Query("SELECT `CarProgressBarID`, `Car No Plate`, `CarProgressIndex`, `StepCompleteTime`, `NoOfDropOffPoints`, `Driver Name`, `Compartments` FROM CarProgressBars WHERE `Driver Name` = ? AND `IsInTrip` = ?", data.DriverName, "true")

		if err != nil {
			return err
		}

		defer Trip.Close()
		var jsonCompartments string

		for Trip.Next() {
			err = Trip.Scan(&TripID, &data.TripStruct.CarNoPlate, &data.TripStruct.ProgressIndex, &data.TripStruct.StepCompleteTime, &data.TripStruct.NoOfDropOffPoints, &data.TripStruct.DriverName, &jsonCompartments)
			if err != nil {
				return c.JSON(err)
			}

			err = json.Unmarshal([]byte(jsonCompartments), &data.Compartments)

			if err != nil {
				log.Println(err.Error())
				return err
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
			"IsInTrip":     data.IsInTrip,
			"TripID":       TripID,
			"Compartments": data.Compartments,
			"Trip":         data.TripStruct,
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
