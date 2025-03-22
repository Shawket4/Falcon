package Apis

import (
	"Falcon/Models"
	"fmt"
	"log"
	"sort"
	"time"

	"github.com/gofiber/fiber/v2"
)

func sortFuelByDate(events []Models.FuelEvent) []Models.FuelEvent {
	layouts := []string{
		"2006-01-02 15:04:05",
		"2006-01-02",
	}

	// Parse date using multiple layouts
	parseDate := func(dateStr string) (time.Time, error) {
		var t time.Time
		var err error
		for _, layout := range layouts {
			t, err = time.Parse(layout, dateStr)
			if err == nil {
				return t, nil
			}
		}
		return t, err
	}

	sort.Slice(events, func(i, j int) bool {
		dateI, errI := parseDate(events[i].Date)
		dateJ, errJ := parseDate(events[j].Date)
		if errI != nil || errJ != nil {
			// Handle error (for simplicity, we can consider them equal if parsing fails)
			return false
		}
		return dateI.Before(dateJ)
	})
	return events
}

func GetFuelEventById(c *fiber.Ctx) error {
	id := c.Params("id") // Get the ID from the URL parameter

	var fuelEvent Models.FuelEvent

	// Find the fuel event by ID
	if err := Models.DB.First(&fuelEvent, id).Error; err != nil {
		log.Println(err.Error())
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Fuel event not found",
		})
	}

	// If you need permission checks like in your commented code:
	/*
		if Controllers.CurrentUser.Permission != 4 && fuelEvent.Transporter != Controllers.CurrentUser.Name {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
				"error": "You don't have permission to view this fuel event",
			})
		}
	*/

	return c.JSON(fuelEvent)
}

func GetFuelEvents(c *fiber.Ctx) error {
	var FuelEvents []Models.FuelEvent

	// if Controllers.CurrentUser.Permission == 4 {
	if err := Models.DB.Find(&FuelEvents).Error; err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	// } else {
	// 	if err := Models.DB.Model(&Models.FuelEvent{}).Where("transporter = ?", Controllers.CurrentUser.Name).Order("date").Find(&FuelEvents).Error; err != nil {
	// 		log.Println(err.Error())
	// 		return c.JSON(fiber.Map{
	// 			"error": err.Error(),
	// 		})
	// 	}
	// }
	FuelEvents = sortFuelByDate(FuelEvents)

	return c.JSON(FuelEvents)
}

func AddFuelEvent(c *fiber.Ctx) error {
	var inputJson Models.FuelEvent
	if err := c.BodyParser(&inputJson); err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	var car Models.Car
	if err := Models.DB.Model(&Models.Car{}).Where("id = ?", inputJson.CarID).Find(&car).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	fmt.Println(car)
	inputJson.CarNoPlate = car.CarNoPlate
	inputJson.Transporter = "Apex"
	inputJson.Price = inputJson.PricePerLiter * inputJson.Liters
	fmt.Println(inputJson)
	inputJson.FuelRate = float64(inputJson.OdometerAfter-inputJson.OdometerBefore) / inputJson.Liters
	if err := Models.DB.Create(&inputJson).Error; err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	if err := Models.DB.Model(&Models.Car{}).Where("id = ?", car.ID).UpdateColumn("last_fuel_odometer", inputJson.OdometerAfter).Error; err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	return c.JSON(inputJson)
}

func EditFuelEvent(c *fiber.Ctx) error {
	var inputJson Models.FuelEvent
	if err := c.BodyParser(&inputJson); err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	var car Models.Car
	if err := Models.DB.Model(&Models.Car{}).Where("id = ?", inputJson.CarID).Find(&car).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	inputJson.CarNoPlate = car.CarNoPlate

	inputJson.Price = inputJson.PricePerLiter * inputJson.Liters
	inputJson.FuelRate = float64(inputJson.OdometerAfter-inputJson.OdometerBefore) / inputJson.Liters
	var fuelEvent Models.FuelEvent
	if err := Models.DB.Model(&Models.FuelEvent{}).Where("id = ?", inputJson.ID).Find(&fuelEvent).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	inputJson.CreatedAt = fuelEvent.CreatedAt

	if err := Models.DB.Save(&inputJson).Error; err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(inputJson)
}

func DeleteFuelEvent(c *fiber.Ctx) error {
	var inputJson struct {
		ID uint `json:"ID"`
	}
	if err := c.BodyParser(&inputJson); err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	var fuelEvent Models.FuelEvent
	if err := Models.DB.Model(&Models.FuelEvent{}).Where("id = ?", inputJson.ID).Find(&fuelEvent).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	// _, err := fuelEvent.Delete()
	if err := Models.DB.Delete(&Models.FuelEvent{}, fuelEvent).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(fiber.Map{
		"message": "Fuel Event Deleted Successfully",
	})
}
