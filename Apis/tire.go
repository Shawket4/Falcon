package Apis

import (
	"Falcon/Models"
	"log"

	"github.com/gofiber/fiber/v2"
)

func UpdateTireList(c *fiber.Ctx) error {
	var input []Models.Tire
	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}

	if err := Models.DB.Save(&input).Error; err != nil {
		log.Println(err.Error())
		return err
	}

	return c.JSON(fiber.Map{
		"message": "Tires Update",
	})
}
