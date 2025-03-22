package Controllers

import (
	"Falcon/Models"

	"github.com/gofiber/fiber/v2"
)

func GetAllTrucks(c *fiber.Ctx) error {
	var trucks []Models.Truck
	if err := Models.DB.Find(&trucks).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusOK).JSON(trucks)
}

// GetTruck fetches a single truck with all its tire positions
func GetTruck(c *fiber.Ctx) error {
	id := c.Params("id")
	var truck Models.Truck

	if err := Models.DB.Preload("Positions.Tire").First(&truck, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Truck not found"})
	}

	return c.Status(fiber.StatusOK).JSON(truck)
}

// CreateTruck creates a new truck with default tire positions
func CreateTruck(c *fiber.Ctx) error {
	var truck Models.Truck
	if err := c.BodyParser(&truck); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	// Create the truck
	if err := Models.DB.Create(&truck).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	// Create default positions for the truck
	if err := Models.CreateDefaultPositions(Models.DB, truck.ID); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create default positions"})
	}

	return c.Status(fiber.StatusCreated).JSON(truck)
}

// UpdateTruck updates truck information
func UpdateTruck(c *fiber.Ctx) error {
	id := c.Params("id")
	var truck Models.Truck

	// Check if the truck exists
	if err := Models.DB.First(&truck, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Truck not found"})
	}

	// Bind the JSON request to the truck
	var updateData Models.Truck
	if err := c.BodyParser(&updateData); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	// Update truck fields
	Models.DB.Model(&truck).Updates(updateData)
	return c.Status(fiber.StatusOK).JSON(truck)
}

// DeleteTruck deletes a truck and its positions
func DeleteTruck(c *fiber.Ctx) error {
	id := c.Params("id")
	var truck Models.Truck

	// Check if the truck exists
	if err := Models.DB.First(&truck, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Truck not found"})
	}

	// Delete associated positions first
	Models.DB.Where("truck_id = ?", id).Delete(&Models.TirePosition{})

	// Delete the truck
	Models.DB.Delete(&truck)

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Truck deleted successfully"})
}
