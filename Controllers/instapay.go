package Controllers

import (
	"fmt"
	"log"

	"Falcon/Models"

	"github.com/gofiber/fiber/v2"
	"github.com/xuri/excelize/v2"
)

func EchoJSON(c *fiber.Ctx) error {
	data := c.Query("message")

	fmt.Println(data)
	return c.JSON(fiber.Map{"message": "Received"})
}

func RegisterTransaction(c *fiber.Ctx) error {
	data := c.Query("message")
	variables := ParseTransactionMessage(data)
	fmt.Println(variables)
	var transaction Models.Transaction
	place := ParseTransactionMessagePlace(data)
	for i, variable := range variables {
		switch i {
		case 0:
			transaction.Amount = variable
		case 1:
			transaction.CardShortNo = variable
		case 2:
			transaction.Place = place[0]
		case 3:
			transaction.Date = variable
		case 4:
			transaction.Time = variable
		case 5:
			transaction.BalanceAvailable = variable
		}
	}
	fmt.Println(transaction)
	f, err := excelize.OpenFile("Transactions.xlsx")
	if err != nil {
		fmt.Println(err)
		return c.JSON(err)
	}
	defer func() {
		// Close the spreadsheet.
		if err := f.Close(); err != nil {
			fmt.Println(err)
		}
	}()
	rows, _ := f.GetRows("Sheet1")
	index := len(rows)
	f.SetCellValue("Sheet1", fmt.Sprintf("A%v", index+1), transaction.Date)
	f.SetCellValue("Sheet1", fmt.Sprintf("B%v", index+1), transaction.Time)
	f.SetCellValue("Sheet1", fmt.Sprintf("C%v", index+1), transaction.Amount)
	f.SetCellValue("Sheet1", fmt.Sprintf("D%v", index+1), transaction.CardShortNo)
	f.SetCellValue("Sheet1", fmt.Sprintf("E%v", index+1), transaction.Place)
	f.SetCellValue("Sheet1", fmt.Sprintf("F%v", index+1), transaction.BalanceAvailable)
	if err := f.SaveAs("Transactions.xlsx"); err != nil {
		fmt.Println(err)
	}
	return c.JSON(fiber.Map{"message": "Success"})
}

func RegisterInstapay(c *fiber.Ctx) error {
	data := c.Query("message")
	var output Models.Instapay
	variables := ParseInstapayMessage(data, "Al Ahly")
	if variables == nil {
		variables = ParseInstapayMessage(data, "SAIB")
		for i, variable := range variables {
			switch i {
			case 0:
				output.Amount = variable
			case 1:
				output.Date = variable
			}
		}
	} else {
		for i, variable := range variables {
			switch i {
			case 0:
				output.CardShortNo = variable
			case 1:
				output.Date = variable
			case 2:
				output.Time = variable
			case 3:
				output.Amount = variable
			}
		}
	}

	fmt.Println(output)
	f, err := excelize.OpenFile("Instapay.xlsx")
	if err != nil {
		fmt.Println(err)
		return c.JSON(err)
	}
	defer func() {
		// Close the spreadsheet.
		if err := f.Close(); err != nil {
			fmt.Println(err)
		}
	}()
	rows, _ := f.GetRows("Instapay")
	index := len(rows)
	f.SetCellValue("Instapay", fmt.Sprintf("A%v", index+1), output.Date)
	f.SetCellValue("Instapay", fmt.Sprintf("B%v", index+1), output.CardShortNo)
	f.SetCellValue("Instapay", fmt.Sprintf("C%v", index+1), output.Amount)
	f.SetCellValue("Instapay", fmt.Sprintf("D%v", index+1), output.Time)
	f.SetCellValue("Instapay", fmt.Sprintf("E%v", index+1), output.Date)
	if err := f.SaveAs("Instapay.xlsx"); err != nil {
		fmt.Println(err)
	}
	return c.JSON(fiber.Map{"message": "Success"})
}

func RegisterInstapayNew(c *fiber.Ctx) error {
	var message Models.MessageReceived
	if err := c.BodyParser(&message); err != nil {
		log.Println(err)
		return c.JSON(err)
	}
	f, err := excelize.OpenFile("./static/Instapay.xlsx")
	if err != nil {
		log.Println(err)
		return c.JSON(err)
	}
	defer func() {
		// Close the spreadsheet.
		if err := f.Close(); err != nil {
			fmt.Println(err)
		}
	}()
	rows, _ := f.GetRows("Instapay")
	index := len(rows)
	f.SetCellValue("Instapay", fmt.Sprintf("A%v", index+1), message.DateTime)
	f.SetCellValue("Instapay", fmt.Sprintf("B%v", index+1), message.Card)
	f.SetCellValue("Instapay", fmt.Sprintf("C%v", index+1), message.Amount)
	f.SetCellValue("Instapay", fmt.Sprintf("D%v", index+1), message.Notes)
	f.SetCellValue("Instapay", fmt.Sprintf("E%v", index+1), message.Bank)
	if err := f.SaveAs("./static/Instapay.xlsx"); err != nil {
		log.Println(err)
		return c.JSON(err)
	}
	return c.JSON(fiber.Map{"message": "Success"})
}

func RegisterFinancialNote(c *fiber.Ctx) error {
	var note Models.FinancialNote
	if err := c.BodyParser(&note); err != nil {
		log.Println(err)
		return c.JSON(err)
	}
	f, err := excelize.OpenFile("./static/Instapay.xlsx")
	if err != nil {
		log.Println(err)
		return c.JSON(err)
	}
	defer func() {
		// Close the spreadsheet.
		if err := f.Close(); err != nil {
			fmt.Println(err)
		}
	}()
	rows, _ := f.GetRows("Instapay")
	index := len(rows)
	f.SetCellValue("Instapay", fmt.Sprintf("A%v", index+1), note.DateTime)
	f.SetCellValue("Instapay", fmt.Sprintf("B%v", index+1), note.Method)
	f.SetCellValue("Instapay", fmt.Sprintf("C%v", index+1), note.Amount)
	f.SetCellValue("Instapay", fmt.Sprintf("D%v", index+1), note.Notes)
	if err := f.SaveAs("./static/Instapay.xlsx"); err != nil {
		log.Println(err)
		return c.JSON(err)
	}
	return c.JSON(fiber.Map{"message": "Success"})
}
