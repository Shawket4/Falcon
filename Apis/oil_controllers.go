package Apis

import (
	"Falcon/Controllers"
	"Falcon/Models"
	"errors"
	"log"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

func CreateOilChange(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var input Models.OilChange
			if err := c.BodyParser(&input); err != nil {
				return err
			}
			var car Models.Car
			if err := Models.DB.Model(&Models.Car{}).Where("id = ?", input.CarID).Find(&car).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			input.CarNoPlate = car.CarNoPlate
			input.Transporter = Controllers.CurrentUser.Name

			input, err := input.Add()

			if err := Models.DB.Model(&Models.Car{}).Where("id = ?", car.ID).Update("last_oil_change_id", input.ID).Error; err != nil {
				log.Println(err)
				return err
			}
			if err != nil {
				log.Println(err)
				return err
			}

			return c.JSON(fiber.Map{
				"message": "Oil Change Registered Successfully.",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func EditOilChange(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var input Models.OilChange
			if err := c.BodyParser(&input); err != nil {
				log.Println(err.Error())
				return err
			}
			// formData := c.FormValue("request")
			// if err := json.Unmarshal([]byte(formData), &input); err != nil {
			// 	log.Println(err)
			// 	return err
			// }
			var car Models.Car
			if err := Models.DB.Where("id = ?", input.CarID).Find(&car).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			input.CarNoPlate = car.CarNoPlate

			var oilChange Models.OilChange
			if err := Models.DB.Model(&Models.OilChange{}).Where("id = ?", input.ID).Find(&oilChange).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			oilChange.CarID = input.CarID
			oilChange.CarNoPlate = input.CarNoPlate
			oilChange.DriverName = input.DriverName
			oilChange.CurrentOdometer = input.CurrentOdometer
			oilChange.Date = input.Date
			oilChange.SuperVisor = input.SuperVisor
			oilChange.Mileage = input.Mileage
			oilChange.OdometerAtChange = input.OdometerAtChange

			_, err := oilChange.Edit()
			if err != nil {
				log.Println(err)
				return err
			}

			return c.JSON(fiber.Map{
				"message": "Oil Change Updated Successfully.",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func DeleteOilChange(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var input struct {
				ID uint `json:"ID"`
			}
			if err := c.BodyParser(&input); err != nil {
				log.Println(err.Error())
				return err
			}
			var oilChange Models.OilChange
			if err := Models.DB.Model(&Models.OilChange{}).Where("id = ?", input.ID).Find(&oilChange).Error; err != nil {
				log.Println(err.Error())
				return err
			}
			_, err := oilChange.Delete()
			if err != nil {
				log.Println(err)
				return err
			}
			return c.JSON(fiber.Map{
				"message": "Oil Change Deleted Successfully",
			})
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetAllOilChanges(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var oilChanges []Models.OilChange
			if Controllers.CurrentUser.Permission == 4 {
				if err := Models.DB.Model(&Models.OilChange{}).Find(&oilChanges).Error; err != nil {
					log.Println(err.Error())
					return err
				}
			} else {
				if err := Models.DB.Model(&Models.OilChange{}).Where("transporter = ?", Controllers.CurrentUser.Name).Find(&oilChanges).Error; err != nil {
					log.Println(err.Error())
					return err
				}
			}
			return c.JSON(
				oilChanges,
			)
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func GetOilChange(c *fiber.Ctx) error {
	id := c.Params("oilChangeId")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Missing oil change ID",
		})
	}

	var oilChange Models.OilChange
	query := Models.DB.Model(&Models.OilChange{}).Where("id = ?", id)

	if err := query.First(&oilChange).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"message": "Oil change not found",
			})
		}
		log.Println(err.Error())
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error retrieving oil change",
		})
	}

	return c.JSON(oilChange)
}
