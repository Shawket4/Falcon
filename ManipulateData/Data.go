package ManipulateData

import (
	"Falcon/Database"
	"fmt"
	"log"
	"strings"

	"github.com/gofiber/fiber/v2"
)

// Create Fiber Function api to parse post request json data

// Delete Data From DB According To Json Request

func DeleteData(c *fiber.Ctx) error {
	var data struct {
		Table      string `json:"Table"`
		ColumnName string `json:"ColumnName"`
		Value      int    `json:"Value"`
	}

	if err := c.BodyParser(&data); err != nil {
		return c.JSON(fiber.Map{"status": "error", "message": err.Error()})
	}
	db := Database.ConnectToDB()
	query := fmt.Sprintf("DELETE FROM `%s` WHERE `%s` = '%v';", data.Table, data.ColumnName, data.Value)
	delete, err := db.Query(query)
	if err != nil {
		log.Println(err)
	}
	defer delete.Close()
	return c.JSON(fiber.Map{
		"Message": "Success",
	})
}

// Edit Data From DB According To Json Request

func EditData(c *fiber.Ctx) error {
	var data struct {
		Table string `json:"Table"`
		// Json Object with Column Name and Value
		Columns  map[string]string `json:"NewData"`
		IdColumn string            `json:"IdColumn"`
		Id       string            `json:"Id"`
	}
	// Unmarshel Json Data
	if err := c.BodyParser(&data); err != nil {
		return c.JSON(fiber.Map{"status": "error", "message": err.Error()})
	}
	fmt.Println(data)
	db := Database.ConnectToDB()
	// Create Query
	query := fmt.Sprintf("UPDATE `%s` SET ", data.Table)
	// Delete IdColumn From Map
	data.Id = data.Columns[data.IdColumn]
	delete(data.Columns, data.IdColumn)
	fmt.Println(data.Id)
	// Loop Through Json Object
	for key, value := range data.Columns {
		query += fmt.Sprintf("`%s` = '%s', ", key, value)
	}
	_ = db

	query = strings.TrimSuffix(query, ", ")
	query += fmt.Sprintf(" WHERE `%s` = '%s';", data.IdColumn, data.Id)
	// Execute Query
	fmt.Println(query)
	update, err := db.Query(query)
	if err != nil {
		log.Println(err)
		return c.JSON(fiber.Map{"status": "error", "message": err.Error()})
	}
	defer update.Close()

	return c.JSON(fiber.Map{
		"Message": "Success",
	})
}
