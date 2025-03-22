package Apis

import (
	"Falcon/Models"
	"log"

	"github.com/gofiber/fiber/v2"
)

func FetchLandMarks(c *fiber.Ctx) error {
	var landMarks []Models.LandMark
	if err := Models.DB.Model(&Models.LandMark{}).Find(&landMarks).Error; err != nil {
		log.Println(err)
		return err
	}
	return c.JSON(landMarks)
}

func CreateLandMark(c *fiber.Ctx) error {
	var input Models.LandMark
	if err := c.BodyParser(&input); err != nil {
		log.Println(err)
		return err
	}
	if err := Models.DB.Create(&input).Error; err != nil {
		log.Println(err)
		return err
	}
	return c.JSON(fiber.Map{"message": "LandMark Created Successfully"})
}

func UpdateLandMark(c *fiber.Ctx) error {
	var input Models.LandMark
	if err := c.BodyParser(&input); err != nil {
		log.Println(err)
		return err
	}
	if err := Models.DB.Save(&input).Error; err != nil {
		log.Println(err)
		return err
	}
	return c.JSON(fiber.Map{"message": "LandMark Updated Successfully"})
}

func DeleteLandMark(c *fiber.Ctx) error {
	var input struct {
		ID uint `json:"id"`
	}
	if err := c.BodyParser(&input); err != nil {
		log.Println(err)
		return err
	}
	if err := Models.DB.Model(&Models.LandMark{}).Delete("id = ?", input.ID).Error; err != nil {
		log.Println(err)
		return err
	}
	return c.JSON(fiber.Map{
		"message": "LandMark Deleted Successfully",
	})
}
