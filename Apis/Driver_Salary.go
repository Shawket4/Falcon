package Apis

import (
	"Falcon/Models"
	"log"

	"github.com/gofiber/fiber/v2"
)

func RegisterDriverLoan(c *fiber.Ctx) error {
	var input struct {
		DriverID uint        `json:"driver_id"`
		Loan     Models.Loan `json:"loan"`
	}
	if err := c.BodyParser(&input); err != nil {
		log.Println(err)
		return err
	}

	input.Loan.DriverID = input.DriverID

	if err := Models.DB.Create(&input.Loan).Error; err != nil {
		log.Println(err.Error())
		return err
	}

	return c.JSON(fiber.Map{
		"message": "Loan Registered Successfully",
	})
}

func RegisterDriverExpense(c *fiber.Ctx) error {
	var input struct {
		DriverID uint           `json:"driver_id"`
		Expense  Models.Expense `json:"expenses"`
	}
	if err := c.BodyParser(&input); err != nil {
		log.Println(err)
		return err
	}

	input.Expense.DriverID = input.DriverID

	if err := Models.DB.Create(&input.Expense).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(fiber.Map{
		"message": "Expense Registered Successfully",
	})
}

// func CalculateDriverSalary(c *fiber.Ctx) error {
// 	var input struct {
// 		ID       uint   `json:"id"`
// 		DateFrom string `json:"date_from"`
// 		DateTo   string `json:"date_to"`
// 	}

// 	if err := c.BodyParser(&input); err != nil {
// 		log.Println(err)
// 		return err
// 	}

// 	DateFrom, err := AbstractFunctions.ParseDate(input.DateFrom)

// 	if err != nil {
// 		log.Println(err.Error())
// 		return err
// 	}

// 	DateTo, err := AbstractFunctions.ParseDate(input.DateTo)
// 	if err != nil {
// 		log.Println(err.Error())
// 		return err
// 	}

// 	var Driver Models.Driver

// 	if err := Models.DB.Model(&Models.Driver{}).Where("id = ?", input.ID).Find(&Driver).Error; err != nil {
// 		log.Println(err.Error())
// 		return err
// 	}

// 	var DriverTrips []Models.TripStruct

// 	if err := Models.DB.Model(&Models.TripStruct{}).Where("date BETWEEN ? AND ?", DateFrom, DateTo).Where("driver_name = ?", Driver.Name).Preload("Route").Preload("Expenses").Preload("Loans").Find(&DriverTrips).Error; err != nil {
// 		log.Println(err)
// 		return err
// 	}
// 	var DriverExpenses []Models.Expense
// 	for _, trip := range DriverTrips {
// 		var TripExpenses []Models.Expense
// 		if err := Models.DB.Model(&Models.Expense{}).Where("trip_struct_id = ?", trip.ID).Find(&TripExpenses).Error; err != nil {
// 			log.Println(err.Error())
// 			return err
// 		}
// 		DriverExpenses = append(DriverExpenses, TripExpenses...)
// 	}
// 	var DriverLoans []Models.Loan

// 	for _, trip := range DriverTrips {
// 		var TripLoans []Models.Loan
// 		if err := Models.DB.Model(&Models.Loan{}).Where("trip_struct_id = ?", trip.ID).Find(&TripLoans).Error; err != nil {
// 			log.Println(err.Error())
// 			return err
// 		}
// 		DriverLoans = append(DriverLoans, TripLoans...)
// 	}

// 	var (
// 		TotalDriverFees     float64
// 		TotalDriverExpenses float64
// 		TotalDriverLoans    float64
// 	)

// 	for _, trip := range DriverTrips {
// 		TotalDriverFees += trip.Route.DriverFees
// 	}

// 	for _, expense := range DriverExpenses {
// 		TotalDriverExpenses += expense.Cost
// 	}

// 	for _, loan := range DriverLoans {
// 		TotalDriverLoans += loan.Amount
// 	}

// 	file := excelize.NewFile()
// 	file.NewSheet("Salary")
// 	file.DeleteSheet("Sheet1")

// 	headers := map[string]string{
// 		"A1": "Receipt No", "B1": "Date", "C1": "Driver Name", "D1": "Car No Plate", "E1": "Distance", "F1": "Driver Fees", "G1": "Trip Expenses", "H1": "Total Expenses", "I1": "Description", "J1": "Trip Loans", "K1": "Total Loans", "L1": "Notes", "M1": "Trip Salary", "N1": "Start Time", "O1": "End Time",
// 		"A2": "رقم الفاتورة", "B2": "التاريخ", "C2": "اسم السائق", "D2": "رقم السيارة", "E2": "المسافة", "F2": "نولون السائق", "G2": "مصروفات النقلة", "H2": "اجمالي المصروفات", "I2": "تفصيل المصروفات", " J2": "العهد", "K2": "اجمالي العهد", "L2": "ملاحظات", "M2": "اجمالي حساب النقلة", "N2": "معاد البداية", "O2": "معاد النهاية",
// 	}

// 	for k, v := range headers {
// 		file.SetCellValue("Salary", k, v)
// 	}

// 	for index, trip := range DriverTrips {
// 		file.SetCellValue("Salary", fmt.Sprintf("A%v", index+3), trip.ReceiptNo)
// 		file.SetCellValue("Salary", fmt.Sprintf("B%v", index+3), trip.Date)
// 		file.SetCellValue("Salary", fmt.Sprintf("C%v", index+3), trip.DriverName)
// 		file.SetCellValue("Salary", fmt.Sprintf("D%v", index+3), trip.CarNoPlate)
// 		file.SetCellValue("Salary", fmt.Sprintf("E%v", index+3), trip.Mileage)
// 		file.SetCellValue("Salary", fmt.Sprintf("F%v", index+3), trip.DriverFees)
// 		var totalSalary float64
// 		var totalExpenses float64
// 		var tripExpenses string
// 		var expensesDescriptions string
// 		for i, expense := range trip.Expenses {
// 			totalExpenses += expense.Cost
// 			if i == 0 {
// 				tripExpenses = fmt.Sprintf("%v", expense.Cost)
// 				expensesDescriptions = expense.Description
// 				continue
// 			}
// 			tripExpenses = fmt.Sprintf("%s+%v", tripExpenses, expense.Cost)
// 			expensesDescriptions = fmt.Sprintf("%s+%s", expensesDescriptions, expense.Description)
// 		}
// 		file.SetCellValue("Salary", fmt.Sprintf("G%v", index+3), tripExpenses)
// 		file.SetCellValue("Salary", fmt.Sprintf("H%v", index+3), totalExpenses)
// 		file.SetCellValue("Salary", fmt.Sprintf("I%v", index+3), expensesDescriptions)

// 		var totalLoans float64
// 		var tripLoans string
// 		var loansMethods string
// 		for i, loan := range trip.Loans {
// 			totalLoans += loan.Amount
// 			if i == 0 {
// 				tripLoans = fmt.Sprintf("%v", loan.Amount)
// 				loansMethods = loan.Method
// 				continue
// 			}
// 			tripLoans = fmt.Sprintf("%s+%v", tripLoans, loan.Amount)
// 			loansMethods = fmt.Sprintf("%s+%s", loansMethods, loan.Method)
// 		}
// 		file.SetCellValue("Salary", fmt.Sprintf("J%v", index+3), tripLoans)
// 		file.SetCellValue("Salary", fmt.Sprintf("K%v", index+3), totalLoans)
// 		file.SetCellValue("Salary", fmt.Sprintf("L%v", index+3), loansMethods)
// 		totalSalary = totalExpenses + trip.DriverFees - totalLoans
// 		file.SetCellValue("Salary", fmt.Sprintf("M%v", index+3), totalSalary)
// 		file.SetCellValue("Salary", fmt.Sprintf("N%v", index+3), trip.StartTime)
// 		file.SetCellValue("Salary", fmt.Sprintf("O%v", index+3), trip.EndTime)
// 	}

// 	var filename string = fmt.Sprintf("./Salaries/Salary For %s From %s To %s.xlsx", Driver.Name, input.DateFrom, input.DateTo)
// 	err = file.SaveAs(filename)
// 	if err != nil {
// 		fmt.Println(err)
// 	}
// 	return c.SendFile(filename, true)
// }

func GetDriverExpenses(c *fiber.Ctx) error {
	var input struct {
		ID uint `json:"id"`
	}

	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}

	var DriverExpenses []Models.Expense

	if err := Models.DB.Model(&Models.Expense{}).Where("driver_id = ?", input.ID).Find(&DriverExpenses).Error; err != nil {
		return err
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

	var DriverLoans []Models.Loan

	if err := Models.DB.Model(&Models.Loan{}).Where("driver_id = ?", input.ID).Find(&DriverLoans).Error; err != nil {
		return err
	}

	return c.JSON(
		DriverLoans,
	)
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
