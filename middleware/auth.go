package middleware

import (
	"Falcon/Controllers"
	"github.com/gofiber/fiber/v2"
)

func Verify(c *fiber.Ctx) error {
	Controllers.User(c)
	if Controllers.CurrentUser.Id != 0 {
		if Controllers.CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			return c.Next()
		}
	}
	return c.JSON(fiber.Map{
		"message": "Not Logged In.",
	})
}
