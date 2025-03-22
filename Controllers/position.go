package Controllers

import (
	"Falcon/Models"

	"github.com/gofiber/fiber/v2"
)

func GetTruckPositions(c *fiber.Ctx) error {
	truckID := c.Params("id")
	var positions []Models.TirePosition

	if err := Models.DB.Where("truck_id = ?", truckID).Preload("Tire").Find(&positions).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(positions)
}

// AssignTireToPosition assigns a tire to a specific position
func AssignTireToPosition(c *fiber.Ctx) error {
	var request struct {
		TireID     uint `json:"tire_id"`
		PositionID uint `json:"position_id"`
	}

	if err := c.BodyParser(&request); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	// First, check if the tire exists
	var tire Models.Tire
	if err := Models.DB.First(&tire, request.TireID).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Tire not found"})
	}

	// Check if the position exists
	var position Models.TirePosition
	if err := Models.DB.First(&position, request.PositionID).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Position not found"})
	}

	// Begin a transaction
	tx := Models.DB.Begin()

	// Clear the tire from any previous position
	if err := tx.Model(&Models.TirePosition{}).Where("tire_id = ?", request.TireID).Update("tire_id", nil).Error; err != nil {
		tx.Rollback()
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to reset previous tire position"})
	}

	// Assign the tire to the new position
	if err := tx.Model(&position).Update("tire_id", request.TireID).Error; err != nil {
		tx.Rollback()
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to assign tire to position"})
	}

	// Commit the transaction
	tx.Commit()

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Tire assigned successfully"})
}

// RemoveTireFromPosition removes a tire from its position
func RemoveTireFromPosition(c *fiber.Ctx) error {
	positionID := c.Params("id")

	// Check if the position exists
	var position Models.TirePosition
	if err := Models.DB.First(&position, positionID).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Position not found"})
	}

	// Remove the tire from the position
	if err := Models.DB.Model(&position).Update("tire_id", nil).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to remove tire from position"})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Tire removed successfully"})
}
