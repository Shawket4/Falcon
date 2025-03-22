package Controllers

import (
	"Falcon/Models"

	"github.com/gofiber/fiber/v2"
)

// GetAllTires fetches all tires in the system
func GetAllTires(c *fiber.Ctx) error {
	var tires []Models.Tire
	if err := Models.DB.Find(&tires).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(tires)
}

// GetTire fetches a single tire by ID
func GetTire(c *fiber.Ctx) error {
	id := c.Params("id")
	var tire Models.Tire

	if err := Models.DB.First(&tire, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Tire not found"})
	}

	return c.Status(fiber.StatusOK).JSON(tire)
}

// CreateTire creates a new tire
func CreateTire(c *fiber.Ctx) error {
	var tire Models.Tire
	if err := c.BodyParser(&tire); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if err := Models.DB.Create(&tire).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(tire)
}

// UpdateTire updates tire information
func UpdateTire(c *fiber.Ctx) error {
	id := c.Params("id")
	var tire Models.Tire

	// Check if the tire exists
	if err := Models.DB.First(&tire, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Tire not found"})
	}

	// Bind the JSON request to the tire
	var updateData Models.Tire
	if err := c.BodyParser(&updateData); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	// Update tire fields
	Models.DB.Model(&tire).Updates(updateData)
	return c.Status(fiber.StatusOK).JSON(tire)
}

// DeleteTire deletes a tire
func DeleteTire(c *fiber.Ctx) error {
	id := c.Params("id")
	var tire Models.Tire

	// Check if the tire exists
	if err := Models.DB.First(&tire, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Tire not found"})
	}

	// Unassign the tire from any position
	Models.DB.Model(&Models.TirePosition{}).Where("tire_id = ?", id).Update("tire_id", nil)

	// Delete the tire
	Models.DB.Delete(&tire)

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Tire deleted successfully"})
}

// SearchTires finds tires by serial, brand or model
func SearchTires(c *fiber.Ctx) error {
	query := c.Query("q")
	if query == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Search query is required"})
	}

	var tires []Models.Tire
	result := Models.DB.Where("serial LIKE ? OR brand LIKE ? OR model LIKE ?",
		"%"+query+"%", "%"+query+"%", "%"+query+"%").Find(&tires)

	if result.Error != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": result.Error.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(tires)
}
