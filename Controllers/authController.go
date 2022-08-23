package Controllers

import (
	"encoding/json"
	"fmt"
	"log"
	"strconv"
	"time"

	"Falcon/Database"
	"Falcon/Models"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v4"
	"golang.org/x/crypto/bcrypt"
)

const SecretKey = "secret"

func RegisterUser(c *fiber.Ctx) error {
	User(c)
	if CurrentUser.Id != 0 {
		if CurrentUser.Permission == 0 {
			return c.Status(fiber.StatusForbidden).SendString("You do not have permission to access this page")
		} else {
			var data map[string]string
			formData := c.FormValue("request")
			// format formData into data map
			err := json.Unmarshal([]byte(formData), &data)
			if err != nil {
				log.Println(err)
			}
			// fmt.Println("saving user")
			Database.Connect()
			password, _ := bcrypt.GenerateFromPassword([]byte(data["password"]), 14)
			permissionlevel, err := strconv.Atoi(data["permission"])

			if err != nil {
				log.Println(err.Error())
				return c.JSON(fiber.Map{
					"message": err.Error(),
				})
			}
			var user Models.User
			if permissionlevel == 0 {
				// user := Models.User{
				// 	Name:                        data["name"],
				// 	Email:                       data["email"],
				// 	Password:                    password,
				// 	Permission:                  permissionlevel,
				// 	DriverLicenseExpirationDate: data["DriverLicenseExpirationDate"],
				// 	SafetyLicenseExpirationDate: data["SafetyLicenseExpirationDate"],
				// 	DrugTestExpirationDate:      data["DrugTestExpirationDate"],
				// 	MobileNumber:                data["mobile_number"],
				// }
				user.Name = data["name"]
				user.Email = data["email"]
				user.Password = password
				user.Permission = permissionlevel
				user.DriverLicenseExpirationDate = data["DriverLicenseExpirationDate"]
				user.SafetyLicenseExpirationDate = data["SafetyLicenseExpirationDate"]
				user.DrugTestExpirationDate = data["DrugTestExpirationDate"]
				user.MobileNumber = data["mobile_number"]

				if data["Transporter"] == "" {
					user.Transporter = CurrentUser.Name
				} else {
					user.Transporter = data["Transporter"]
				}
				if CurrentUser.Permission >= 3 {
					user.IsApproved = 1
				} else {
					user.IsApproved = 0
				}
				driverLicense, err := c.FormFile("DriverLicense")
				if err != nil {
					log.Println(err.Error())
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				// Save file to disk
				// Allow multipart form
				err = c.SaveFile(driverLicense, fmt.Sprintf("./DriverLicenses/%s", driverLicense.Filename))
				if err != nil {
					log.Println(err.Error())
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				safetyLicense, err := c.FormFile("SafetyLicense")
				if err != nil {
					log.Println(err.Error())
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				// Save file to disk
				// Allow multipart form
				err = c.SaveFile(safetyLicense, fmt.Sprintf("./SafetyLicenses/%s", safetyLicense.Filename))
				if err != nil {
					log.Println(err.Error())
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				drugTest, err := c.FormFile("DrugTest")
				if err != nil {
					log.Println(err.Error())
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				// Save file to disk
				// Allow multipart form
				err = c.SaveFile(drugTest, fmt.Sprintf("./DrugTests/%s", drugTest.Filename))
				if err != nil {
					log.Println(err.Error())
					return c.JSON(fiber.Map{
						"message": err.Error(),
						"file":    "save",
					})
				}
				// user.Image = file.Filename

				Database.DB.Create(&user)
			} else {
				// user := Models.User{
				// 	Name:         data["name"],
				// 	Email:        data["email"],
				// 	Password:     password,
				// 	Permission:   permissionlevel,
				// 	MobileNumber: data["mobile_number"],
				// }
				user.Name = data["name"]
				user.Email = data["email"]
				user.Password = password
				user.Permission = permissionlevel
				user.MobileNumber = data["mobile_number"]
				if CurrentUser.Permission >= 3 {
					user.IsApproved = 1
				} else {
					user.IsApproved = 0
				}
			}
			// Database.DB.Create(&user)
			Database.DB.Create(&user)

			return c.JSON(user)
		}
	} else {
		return c.JSON(fiber.Map{
			"message": "Not Logged In.",
		})
	}
}

func Upload(c *fiber.Ctx) error {
	file, err := c.FormFile("file")
	if err != nil {
		return c.Status(422).JSON(fiber.Map{"errors": [1]string{"We were not able upload your attachment"}})
	}
	err = c.SaveFile(file, fmt.Sprintf("./uploads/%s", file.Filename))
	if err != nil {
		return c.Status(422).JSON(fiber.Map{"errors": [1]string{"We were not able upload your attachment"}})
	}
	return c.JSON(fiber.Map{
		"message": "File uploaded successfully",
	})
}

// func Register(c *fiber.Ctx) error {
// 	fmt.Println("Register")
// 	var data map[string]string
// 	user := new(models.User)
// 	fmt.Println("c", c.BodyParser(&data))
// 	if err := c.BodyParser(&user); err != nil {
// 		// return err
// 		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
// 			"message": err.Error(),
// 		})
// 	}

// 	errors := validation.ValidateStruct(*user)
// 	if errors != nil {
// 		return c.Status(fiber.StatusBadRequest).JSON(errors)
// 	}

// 	password, _ := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)

// 	newuser := models.User{
// 		Name:     user.Name,
// 		Email:    user.Email,
// 		Password: password,
// 	}

// 	fmt.Println("dd", user, newuser)

// 	database.DB.Create(&newuser)

// 	// return c.SendString("Hello, World 👋!")
// 	return c.JSON(newuser)
// }

func Login(c *fiber.Ctx) error {
	var data map[string]string

	if err := c.BodyParser(&data); err != nil {
		return err
	}
	Database.Connect()

	var user Models.User
	Database.DB.Where("email = ?", data["email"]).First(&user)

	if user.Id == 0 {
		c.Status(fiber.StatusNotFound)
		return c.JSON(fiber.Map{
			"error": "User not found",
		})
	}

	// pp, _ := bcrypt.GenerateFromPassword([]byte(data["password"]), 14)

	err := bcrypt.CompareHashAndPassword(user.Password, []byte(data["password"]))

	if err != nil {
		c.Status(fiber.StatusBadRequest)
		return c.JSON(fiber.Map{
			"error": "Invalid password",
		})
	}

	// Create token
	claims := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.RegisteredClaims{
		Issuer:    strconv.Itoa(int(user.Id)),
		ExpiresAt: jwt.NewNumericDate(time.Unix(time.Now().Add(time.Hour*24*31).Unix(), 0)), // 1 day
	})

	// time.Now().Add(time.Hour * 24).Unix()

	token, err := claims.SignedString([]byte(SecretKey))

	if err != nil {
		c.Status(fiber.StatusInternalServerError)
		return c.JSON(fiber.Map{
			"error": "could not login",
		})
	}

	// Create cookie
	cookie := fiber.Cookie{
		Name:     "jwt",
		Value:    token,
		Expires:  time.Now().Add(time.Hour * 24),
		HTTPOnly: true,
	}

	c.Cookie(&cookie)

	// return c.JSON(token)
	fmt.Println("Success")
	return c.JSON(fiber.Map{
		"jwt":        token,
		"success":    "success message",
		"permission": user.Permission,
	})
}

var CurrentUser *Models.User

func User(c *fiber.Ctx) error {
	var user Models.User
	user.Id = 0
	CurrentUser = &user
	Database.Connect()
	cookie := c.Cookies("jwt")

	token, err := jwt.ParseWithClaims(cookie, &jwt.RegisteredClaims{}, func(t *jwt.Token) (interface{}, error) {
		return []byte(SecretKey), nil
	})

	if err != nil {
		c.Status(fiber.StatusUnauthorized)
		fmt.Println("Error", err)
		return c.JSON(fiber.Map{
			"message": "Unauthenticated",
		})
	}

	claims := token.Claims.(*jwt.RegisteredClaims)

	Database.DB.Where("id = ?", claims.Issuer).First(&user)
	CurrentUser = &user
	return c.JSON(user)
}

func Logout(c *fiber.Ctx) error {
	// Remove cookie
	// -time.Hour = expires before one hour
	Database.Connect()
	cookie := fiber.Cookie{
		Name:     "jwt",
		Value:    "",
		Expires:  time.Now().Add(-time.Hour),
		HTTPOnly: true,
	}

	c.Cookie(&cookie)

	return c.JSON(fiber.Map{
		"message": "success",
	})
}
