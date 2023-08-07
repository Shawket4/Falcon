package Apis

import (
	"Falcon/AbstractFunctions"
	"Falcon/Models"
	"fmt"
	"log"

	"github.com/360EntSecGroup-Skylar/excelize"
	"github.com/gofiber/fiber/v2"
)

func RegisterTripLoans(c *fiber.Ctx) error {
	var input struct {
		TripID uint          `json:"trip_id"`
		Loans  []Models.Loan `json:"loans"`
	}
	if err := c.BodyParser(&input); err != nil {
		log.Println(err)
		return err
	}
	for index := range input.Loans {
		input.Loans[index].TripStructID = input.TripID
	}
	if err := Models.DB.Save(&input.Loans).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(fiber.Map{
		"message": "Loans Registered Successfully",
	})
}

func RegisterTripExpenses(c *fiber.Ctx) error {
	var input struct {
		TripID   uint             `json:"trip_id"`
		Expenses []Models.Expense `json:"expenses"`
	}
	if err := c.BodyParser(&input); err != nil {
		log.Println(err)
		return err
	}
	for index := range input.Expenses {
		input.Expenses[index].TripStructID = input.TripID
	}
	if err := Models.DB.Save(&input.Expenses).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(fiber.Map{
		"message": "Expenses Registered Successfully",
	})
}

func CalculateDriverSalary(c *fiber.Ctx) error {
	var input struct {
		ID       uint   `json:"id"`
		DateFrom string `json:"date_from"`
		DateTo   string `json:"date_to"`
	}

	if err := c.BodyParser(&input); err != nil {
		log.Println(err)
		return err
	}

	DateFrom, err := AbstractFunctions.ParseDate(input.DateFrom)

	if err != nil {
		log.Println(err.Error())
		return err
	}

	DateTo, err := AbstractFunctions.ParseDate(input.DateTo)
	if err != nil {
		log.Println(err.Error())
		return err
	}

	var Driver Models.Driver

	if err := Models.DB.Model(&Models.Driver{}).Where("id = ?", input.ID).Find(&Driver).Error; err != nil {
		log.Println(err.Error())
		return err
	}

	var DriverTrips []Models.TripStruct

	if err := Models.DB.Model(&Models.TripStruct{}).Where("date BETWEEN ? AND ?", DateFrom, DateTo).Where("driver_name = ?", Driver.Name).Preload("Route").Preload("Expenses").Preload("Loans").Find(&DriverTrips).Error; err != nil {
		log.Println(err)
		return err
	}
	var DriverExpenses []Models.Expense
	for _, trip := range DriverTrips {
		var TripExpenses []Models.Expense
		if err := Models.DB.Model(&Models.Expense{}).Where("trip_struct_id = ?", trip.ID).Find(&TripExpenses).Error; err != nil {
			log.Println(err.Error())
			return err
		}
		DriverExpenses = append(DriverExpenses, TripExpenses...)
	}
	var DriverLoans []Models.Loan

	for _, trip := range DriverTrips {
		var TripLoans []Models.Loan
		if err := Models.DB.Model(&Models.Loan{}).Where("trip_struct_id = ?", trip.ID).Find(&TripLoans).Error; err != nil {
			log.Println(err.Error())
			return err
		}
		DriverLoans = append(DriverLoans, TripLoans...)
	}

	var (
		TotalDriverFees     float64
		TotalDriverExpenses float64
		TotalDriverLoans    float64
	)

	for _, trip := range DriverTrips {
		TotalDriverFees += trip.Route.DriverFees
	}

	for _, expense := range DriverExpenses {
		TotalDriverExpenses += expense.Cost
	}

	for _, loan := range DriverLoans {
		TotalDriverLoans += loan.Amount
	}

	file := excelize.NewFile()
	file.NewSheet("Salary")
	file.DeleteSheet("Sheet1")

	headers := map[string]string{
		"A1": "Date", "B1": "Driver Name", "C1": "Car No Plate", "D1": "Distance", "E1": "Driver Fees", "F1": "Trip Expenses", "G1": "Total Expenses", "H1": "Description", "I1": "Trip Loans", "J1": "Total Loans", "K1": "Notes", "L1": "Trip Salary", "M1": "Start Time", "N1": "End Time",
	}

	for k, v := range headers {
		file.SetCellValue("Salary", k, v)
	}

	for index, trip := range DriverTrips {
		file.SetCellValue("Salary", fmt.Sprintf("A%v", index+2), trip.Date)
		file.SetCellValue("Salary", fmt.Sprintf("B%v", index+2), trip.DriverName)
		file.SetCellValue("Salary", fmt.Sprintf("C%v", index+2), trip.CarNoPlate)
		file.SetCellValue("Salary", fmt.Sprintf("D%v", index+2), trip.Mileage)
		file.SetCellValue("Salary", fmt.Sprintf("E%v", index+2), trip.DriverFees)
		var totalSalary float64
		var totalExpenses float64
		var tripExpenses string
		var expensesDescriptions string
		for i, expense := range trip.Expenses {
			totalExpenses += expense.Cost
			if i == 0 {
				tripExpenses = fmt.Sprintf("%v", expense.Cost)
				expensesDescriptions = expense.Description
				continue
			}
			tripExpenses = fmt.Sprintf("%s+%v", tripExpenses, expense.Cost)
			expensesDescriptions = fmt.Sprintf("%s+%s", expensesDescriptions, expense.Description)
		}
		file.SetCellValue("Salary", fmt.Sprintf("F%v", index+2), tripExpenses)
		file.SetCellValue("Salary", fmt.Sprintf("G%v", index+2), totalExpenses)
		file.SetCellValue("Salary", fmt.Sprintf("H%v", index+2), expensesDescriptions)

		var totalLoans float64
		var tripLoans string
		var loansMethods string
		for i, loan := range trip.Loans {
			totalLoans += loan.Amount
			if i == 0 {
				tripLoans = fmt.Sprintf("%v", loan.Amount)
				loansMethods = loan.Method
				continue
			}
			tripLoans = fmt.Sprintf("%s+%v", tripLoans, loan.Amount)
			loansMethods = fmt.Sprintf("%s+%s", loansMethods, loan.Method)
		}
		file.SetCellValue("Salary", fmt.Sprintf("I%v", index+2), tripLoans)
		file.SetCellValue("Salary", fmt.Sprintf("J%v", index+2), totalLoans)
		file.SetCellValue("Salary", fmt.Sprintf("K%v", index+2), loansMethods)
		totalSalary = totalExpenses + trip.DriverFees - totalLoans
		file.SetCellValue("Salary", fmt.Sprintf("L%v", index+2), totalSalary)
		file.SetCellValue("Salary", fmt.Sprintf("M%v", index+2), trip.StartTime)
		file.SetCellValue("Salary", fmt.Sprintf("N%v", index+2), trip.EndTime)
	}

	var filename string = fmt.Sprintf("./Salaries/Salary For %s From %s To %s.xlsx", Driver.Name, input.DateFrom, input.DateTo)
	err = file.SaveAs(filename)
	if err != nil {
		fmt.Println(err)
	}
	return c.SendFile(filename, true)
}

func GetDriverExpenses(c *fiber.Ctx) error {
	var input struct {
		ID uint `json:"id"`
	}

	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}
	var DriverTrips []Models.TripStruct
	if err := Models.DB.Model(&Models.TripStruct{}).Where("driver_id = ?", input.ID).Find(&DriverTrips).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	var DriverExpenses []Models.Expense
	for _, trip := range DriverTrips {
		var TripExpenses []Models.Expense
		if err := Models.DB.Model(&Models.Expense{}).Where("trip_struct_id = ?", trip.ID).Find(&TripExpenses).Error; err != nil {
			log.Println(err.Error())
			return err
		}
		DriverExpenses = append(DriverExpenses, TripExpenses...)
	}
	return c.JSON(
		DriverExpenses,
	)
}

func GetDriverLoans(c *fiber.Ctx) error {
	var input struct {
		ID uint `json:"id"`
	}

	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}

	var DriverTrips []Models.TripStruct
	if err := Models.DB.Model(&Models.TripStruct{}).Where("driver_id = ?", input.ID).Find(&DriverTrips).Error; err != nil {
		log.Println(err.Error())
		return err
	}

	var DriverLoans []Models.Loan

	for _, trip := range DriverTrips {
		var TripLoans []Models.Loan
		if err := Models.DB.Model(&Models.Loan{}).Where("trip_struct_id = ?", trip.ID).Find(&TripLoans).Error; err != nil {
			log.Println(err.Error())
			return err
		}
		DriverLoans = append(DriverLoans, TripLoans...)
	}
	return c.JSON(DriverLoans)
}

func GetTripExpenses(c *fiber.Ctx) error {
	var input struct {
		ID uint `json:"id"`
	}

	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}

	var TripExpenses []Models.Expense
	if err := Models.DB.Model(&Models.Expense{}).Where("trip_struct_id = ?", input.ID).Find(&TripExpenses).Error; err != nil {
		log.Println(err.Error())
		return err
	}

	return c.JSON(TripExpenses)
}

func GetTripLoans(c *fiber.Ctx) error {
	var input struct {
		ID uint `json:"id"`
	}

	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}

	var TripLoans []Models.Loan
	if err := Models.DB.Model(&Models.Loan{}).Where("trip_struct_id = ?", input.ID).Find(&TripLoans).Error; err != nil {
		log.Println(err.Error())
		return err
	}

	return c.JSON(TripLoans)
}

func DeleteExpense(c *fiber.Ctx) error {
	var input struct {
		ID uint `json:"id"`
	}

	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}
	if err := Models.DB.Model(&Models.Expense{}).Delete("id = ?", input.ID).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(fiber.Map{
		"message": "Expense Deleted Successfully",
	})
}

func DeleteLoan(c *fiber.Ctx) error {
	var input struct {
		ID uint `json:"id"`
	}

	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}
	if err := Models.DB.Model(&Models.Loan{}).Delete("id = ?", input.ID).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(fiber.Map{
		"message": "Loan Deleted Successfully",
	})
}
