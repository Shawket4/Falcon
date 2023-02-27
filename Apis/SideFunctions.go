package Apis

import (
	"Falcon/Controllers"
	"Falcon/Models"
	"log"

	"github.com/gofiber/fiber/v2"
)

func GetFuelEvents(c *fiber.Ctx) error {
	var FuelEvents []Models.FuelEvent
	if Controllers.CurrentUser.Permission == 4 {
		if err := Models.DB.Find(&FuelEvents).Error; err != nil {
			log.Println(err.Error())
			return c.JSON(fiber.Map{
				"error": err.Error(),
			})
		}
	} else {
		if err := Models.DB.Where("transporter = ?", Controllers.CurrentUser.Name).Find(&FuelEvents).Error; err != nil {
			log.Println(err.Error())
			return c.JSON(fiber.Map{
				"error": err.Error(),
			})
		}
	}
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
	inputJson.CarNoPlate = car.CarNoPlate
	inputJson.Transporter = Controllers.CurrentUser.Name
	inputJson.Price = inputJson.PricePerLiter * inputJson.Liters
	inputJson.FuelRate = float64(inputJson.OdometerAfter-inputJson.OdometerBefore) / inputJson.Liters
	output, err := inputJson.Add()
	if err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	return c.JSON(output)
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

	output, err := inputJson.Edit()
	if err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	return c.JSON(output)
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
	if err := Models.DB.Delete(&Models.FuelEvent{}, fuelEvent).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(fiber.Map{
		"message": "Fuel Event Deleted Successfully",
	})
}
