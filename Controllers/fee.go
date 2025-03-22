package Controllers

import (
	"Falcon/Models"
	"fmt"
	"net/http"
	"net/url"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

// FeeMappingHandler contains handler methods for fee mapping routes
type FeeMappingHandler struct {
	DB *gorm.DB
}

// NewFeeMappingHandler creates a new fee mapping handler
func NewFeeMappingHandler(db *gorm.DB) *FeeMappingHandler {
	return &FeeMappingHandler{
		DB: db,
	}
}

// GetAllFeeMappings returns all fee mappings
func (h *FeeMappingHandler) GetAllFeeMappings(c *fiber.Ctx) error {
	var mappings []Models.FeeMapping

	result := h.DB.Find(&mappings)
	if result.Error != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to fetch fee mappings",
			"error":   result.Error.Error(),
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Fee mappings retrieved successfully",
		"data":    mappings,
	})
}

// GetFeeMapping returns a specific fee mapping by ID
func (h *FeeMappingHandler) GetFeeMapping(c *fiber.Ctx) error {
	id, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid ID",
			"error":   err.Error(),
		})
	}

	var mapping Models.FeeMapping
	result := h.DB.First(&mapping, id)
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			return c.Status(http.StatusNotFound).JSON(fiber.Map{
				"message": "Fee mapping not found",
			})
		}

		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to fetch fee mapping",
			"error":   result.Error.Error(),
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Fee mapping retrieved successfully",
		"data":    mapping,
	})
}

// CreateFeeMapping creates a new fee mapping
func (h *FeeMappingHandler) CreateFeeMapping(c *fiber.Ctx) error {
	mapping := new(Models.FeeMapping)

	if err := c.BodyParser(mapping); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid request body",
			"error":   err.Error(),
		})
	}

	// Validate required fields
	if mapping.Company == "" || mapping.Terminal == "" || mapping.DropOffPoint == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Company, Terminal, and DropOffPoint are required fields",
		})
	}

	// Check if this mapping already exists
	var existingMapping Models.FeeMapping
	result := h.DB.Where("company = ? AND terminal = ? AND drop_off_point = ?",
		mapping.Company, mapping.Terminal, mapping.DropOffPoint).First(&existingMapping)

	if result.Error == nil {
		return c.Status(http.StatusConflict).JSON(fiber.Map{
			"message": "A mapping with this company, terminal, and drop-off point already exists",
		})
	}

	// Create the new mapping
	result = h.DB.Create(&mapping)
	if result.Error != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to create fee mapping",
			"error":   result.Error.Error(),
		})
	}

	return c.Status(http.StatusCreated).JSON(fiber.Map{
		"message": "Fee mapping created successfully",
		"data":    mapping,
	})
}

// UpdateFeeMapping updates an existing fee mapping
func (h *FeeMappingHandler) UpdateFeeMapping(c *fiber.Ctx) error {
	id, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid ID",
			"error":   err.Error(),
		})
	}

	// Find existing mapping
	var existingMapping Models.FeeMapping
	result := h.DB.First(&existingMapping, id)
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			return c.Status(http.StatusNotFound).JSON(fiber.Map{
				"message": "Fee mapping not found",
			})
		}

		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to fetch fee mapping",
			"error":   result.Error.Error(),
		})
	}

	// Parse the update data
	updatedMapping := new(Models.FeeMapping)
	if err := c.BodyParser(updatedMapping); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid request body",
			"error":   err.Error(),
		})
	}

	// Check for uniqueness if company, terminal, or drop-off point changed
	if (updatedMapping.Company != "" && updatedMapping.Company != existingMapping.Company) ||
		(updatedMapping.Terminal != "" && updatedMapping.Terminal != existingMapping.Terminal) ||
		(updatedMapping.DropOffPoint != "" && updatedMapping.DropOffPoint != existingMapping.DropOffPoint) {

		var conflictMapping Models.FeeMapping
		company := updatedMapping.Company
		if company == "" {
			company = existingMapping.Company
		}

		terminal := updatedMapping.Terminal
		if terminal == "" {
			terminal = existingMapping.Terminal
		}

		dropOffPoint := updatedMapping.DropOffPoint
		if dropOffPoint == "" {
			dropOffPoint = existingMapping.DropOffPoint
		}

		result = h.DB.Where("company = ? AND terminal = ? AND drop_off_point = ? AND id != ?",
			company, terminal, dropOffPoint, id).First(&conflictMapping)

		if result.Error == nil {
			return c.Status(http.StatusConflict).JSON(fiber.Map{
				"message": "A mapping with this company, terminal, and drop-off point already exists",
			})
		}
	}

	// Update the mapping
	if updatedMapping.Company != "" {
		existingMapping.Company = updatedMapping.Company
	}
	if updatedMapping.Terminal != "" {
		existingMapping.Terminal = updatedMapping.Terminal
	}
	if updatedMapping.DropOffPoint != "" {
		existingMapping.DropOffPoint = updatedMapping.DropOffPoint
	}
	existingMapping.Distance = updatedMapping.Distance
	existingMapping.Fee = updatedMapping.Fee

	result = h.DB.Save(&existingMapping)
	if result.Error != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to update fee mapping",
			"error":   result.Error.Error(),
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Fee mapping updated successfully",
		"data":    existingMapping,
	})
}

// DeleteFeeMapping deletes a fee mapping
func (h *FeeMappingHandler) DeleteFeeMapping(c *fiber.Ctx) error {
	id, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid ID",
			"error":   err.Error(),
		})
	}

	var mapping Models.FeeMapping
	result := h.DB.First(&mapping, id)
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			return c.Status(http.StatusNotFound).JSON(fiber.Map{
				"message": "Fee mapping not found",
			})
		}

		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to fetch fee mapping",
			"error":   result.Error.Error(),
		})
	}

	result = h.DB.Delete(&mapping)
	if result.Error != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to delete fee mapping",
			"error":   result.Error.Error(),
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Fee mapping deleted successfully",
	})
}

// GetCompaniesList returns a list of all unique companies in the fee mappings
func (h *FeeMappingHandler) GetCompaniesList(c *fiber.Ctx) error {
	var companies []string

	result := h.DB.Model(&Models.FeeMapping{}).Distinct().Pluck("company", &companies)
	if result.Error != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to fetch companies list",
			"error":   result.Error.Error(),
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Companies list retrieved successfully",
		"data":    companies,
	})
}

// GetTerminalsByCompany returns all terminals for a specific company
// GetTerminalsByCompany returns all terminals for a specific company
func (h *FeeMappingHandler) GetTerminalsByCompany(c *fiber.Ctx) error {
	company := c.Params("company")
	if company == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Company parameter is required",
		})
	}

	// URL decode the company name to handle spaces properly
	decodedCompany, err := url.QueryUnescape(company)
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid company name format",
			"error":   err.Error(),
		})
	}

	// Debug: Log the company name to verify what we're searching for
	fmt.Printf("Searching for terminals with company name: '%s'\n", decodedCompany)

	// Debug: Count existing mappings for this company to verify data exists
	var count int64
	h.DB.Model(&Models.FeeMapping{}).Where("company = ?", decodedCompany).Count(&count)
	fmt.Printf("Found %d mappings for company: '%s'\n", count, decodedCompany)

	var terminals []string

	// Use LOWER() function to make the comparison case-insensitive
	result := h.DB.Model(&Models.FeeMapping{}).
		Where("LOWER(company) = LOWER(?)", decodedCompany).
		Distinct().
		Pluck("terminal", &terminals)

	if result.Error != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to fetch terminals list",
			"error":   result.Error.Error(),
		})
	}

	// Debug: Log the results
	fmt.Printf("Found %d terminals for company: '%s'\n", len(terminals), decodedCompany)
	for i, terminal := range terminals {
		fmt.Printf("  Terminal %d: '%s'\n", i+1, terminal)
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Terminals list retrieved successfully",
		"data":    terminals,
	})
}

// GetDropOffPointsByTerminal returns all drop-off points for a specific company and terminal
func (h *FeeMappingHandler) GetDropOffPointsByTerminal(c *fiber.Ctx) error {
	company := c.Params("company")
	terminal := c.Params("terminal")

	if company == "" || terminal == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Company and terminal parameters are required",
		})
	}

	company, err := url.QueryUnescape(company)
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid company name format",
			"error":   err.Error(),
		})
	}

	var dropOffPoints []string

	result := h.DB.Model(&Models.FeeMapping{}).
		Where("company = ? AND terminal = ?", company, terminal).
		Distinct().
		Pluck("drop_off_point", &dropOffPoints)

	if result.Error != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to fetch drop-off points list",
			"error":   result.Error.Error(),
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Drop-off points list retrieved successfully",
		"data":    dropOffPoints,
	})
}

// GetFeeByMapping retrieves the fee and distance for a specific mapping
func (h *FeeMappingHandler) GetFeeByMapping(c *fiber.Ctx) error {
	company := c.Query("company")
	terminal := c.Query("terminal")
	dropOffPoint := c.Query("drop_off_point")

	if company == "" || terminal == "" || dropOffPoint == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"message": "Company, terminal, and drop_off_point query parameters are required",
		})
	}

	var mapping Models.FeeMapping
	result := h.DB.Where("company = ? AND terminal = ? AND drop_off_point = ?",
		company, terminal, dropOffPoint).First(&mapping)

	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			return c.Status(http.StatusNotFound).JSON(fiber.Map{
				"message": "Fee mapping not found for the provided parameters",
			})
		}

		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"message": "Failed to fetch fee mapping",
			"error":   result.Error.Error(),
		})
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message":  "Fee mapping retrieved successfully",
		"fee":      mapping.Fee,
		"distance": mapping.Distance,
	})
}
