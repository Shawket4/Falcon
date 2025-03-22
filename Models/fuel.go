package Models

import (
	"Falcon/Constants"
	"fmt"
	"log"
	"strconv"

	"github.com/360EntSecGroup-Skylar/excelize"
	"gorm.io/gorm"
)

type FuelEvent struct {
	gorm.Model
	CarID              uint    `json:"car_id"`
	CarNoPlate         string  `json:"car_no_plate"`
	DriverName         string  `json:"driver_name"`
	Date               string  `json:"date"`
	Liters             float64 `json:"liters"`
	PricePerLiter      float64 `json:"price_per_liter"`
	Price              float64 `json:"price"`
	FuelRate           float64 `json:"fuel_rate"`
	Transporter        string  `json:"transporter"`
	OdometerBefore     int     `json:"odometer_before"`
	OdometerAfter      int     `json:"odometer_after"`
	ExcelIndex         int
	ExcelIndexExpenses int
}

func (input *FuelEvent) Add() (*FuelEvent, error) {
	// fmt.Println(input.Date)
	// f, err := excelize.OpenFile(Constants.SMBPath + "تفويلات.xlsx")
	// if err != nil {
	// 	log.Println(err)
	// 	return &FuelEvent{}, err
	// }

	// sheets := f.GetSheetMap()
	// var carSheetExists bool
	// var activeSheet string
	// for _, sheet := range sheets {
	// 	if sheet == input.CarNoPlate {
	// 		carSheetExists = true
	// 	}
	// }
	// if !carSheetExists {
	// 	f.NewSheet(input.CarNoPlate)

	// }
	// activeSheet = input.CarNoPlate
	// data := f.GetRows(activeSheet)
	// input.ExcelIndex = len(data) + 1
	// if input.ExcelIndex == 1 {
	// 	input.ExcelIndex++
	// }
	// index := strconv.Itoa(input.ExcelIndex)
	// differenceKM := input.OdometerAfter - input.OdometerBefore
	// fuelRate := fmt.Sprintf("%v", input.FuelRate)
	// headers := map[string]string{
	// 	"A1":        "التاريخ",
	// 	"B1":        "رقم العربية",
	// 	"C1":        "السائق",
	// 	"D1":        "العداد الحالي",
	// 	"E1":        "العداد السابق",
	// 	"F1":        "فرق الكيلومتر",
	// 	"G1":        "المعدل",
	// 	"H1":        "كمية التفويل",
	// 	"I1":        "سعر اللتر",
	// 	"J1":        "التكلفة",
	// 	"A" + index: input.Date,
	// 	"B" + index: input.CarNoPlate,
	// 	"C" + index: input.DriverName,
	// 	"D" + index: strconv.Itoa(int(input.OdometerAfter)),
	// 	"E" + index: strconv.Itoa(int(input.OdometerBefore)),
	// 	"F" + index: strconv.Itoa(int(differenceKM)),
	// 	"G" + index: fuelRate,
	// 	"H" + index: fmt.Sprintf("%v", input.Liters),
	// 	"I" + index: fmt.Sprintf("%v", input.PricePerLiter),
	// 	"J" + index: fmt.Sprintf("%v", input.Price),
	// }
	// for k, v := range headers {
	// 	f.SetCellValue(activeSheet, k, v)
	// }
	// if err := f.Save(); err != nil {
	// 	return &FuelEvent{}, err
	// }

	// fExpenses, err := excelize.OpenFile(Constants.SMBPath + "تكاليف السيارات.xlsx")
	// if err != nil {
	// 	log.Println(err)
	// 	return &FuelEvent{}, err
	// }
	// dataExpenses := fExpenses.GetRows("تفويل")
	// indexExpenses := strconv.Itoa(len(dataExpenses) + 1)
	// input.ExcelIndexExpenses = len(dataExpenses) + 1

	// headersExpenses := map[string]string{
	// 	"A1":                "التاريخ",
	// 	"B1":                "رقم العربية",
	// 	"C1":                "السائق",
	// 	"D1":                "العداد الحالي",
	// 	"E1":                "العداد السابق",
	// 	"F1":                "فرق الكيلومتر",
	// 	"G1":                "المعدل",
	// 	"H1":                "كمية التفويل",
	// 	"I1":                "سعر اللتر",
	// 	"J1":                "التكلفة",
	// 	"A" + indexExpenses: input.Date,
	// 	"B" + indexExpenses: input.CarNoPlate,
	// 	"C" + indexExpenses: input.DriverName,
	// 	"D" + indexExpenses: strconv.Itoa(int(input.OdometerAfter)),
	// 	"E" + indexExpenses: strconv.Itoa(int(input.OdometerBefore)),
	// 	"F" + indexExpenses: strconv.Itoa(int(differenceKM)),
	// 	"G" + indexExpenses: fuelRate,
	// 	"H" + indexExpenses: fmt.Sprintf("%v", input.Liters),
	// 	"I" + indexExpenses: fmt.Sprintf("%v", input.PricePerLiter),
	// 	"J" + indexExpenses: fmt.Sprintf("%v", input.Price),
	// }

	// for k, v := range headersExpenses {
	// 	fExpenses.SetCellValue("تفويل", k, v)
	// }
	// if err := fExpenses.Save(); err != nil {
	// 	return &FuelEvent{}, err
	// }

	// // dateFormatted, _ := convertDate(input.Date)
	// // input.Date = dateFormatted
	if err := DB.Create(input).Error; err != nil {
		log.Println(err.Error())
		return &FuelEvent{}, err
	}
	return input, nil
}

// func convertDate(dateString string) (string, error) {
// 	// Define the layout for parsing the input date
// 	inputLayout := "2006-01-02 15:04:05"
// 	// Parse the date string
// 	t, err := time.Parse(inputLayout, dateString)
// 	if err != nil {
// 		return "", err
// 	}

// 	// Define the layout for formatting the output date
// 	outputLayout := "02-01-2006"
// 	// Format the date
// 	formattedDate := t.Format(outputLayout)

// 	return formattedDate, nil
// }

func (input *FuelEvent) Edit() (*FuelEvent, error) {
	var CurrentFuelEvent FuelEvent
	if err := DB.Model(&FuelEvent{}).Where("id = ?", input.ID).Find(&CurrentFuelEvent).Error; err != nil {
		log.Println(err.Error())
		return &FuelEvent{}, err
	}
	fmt.Println(CurrentFuelEvent)
	CurrentFuelEvent.CarNoPlate = input.CarNoPlate
	CurrentFuelEvent.DriverName = input.DriverName
	CurrentFuelEvent.Date = input.Date
	CurrentFuelEvent.Liters = input.Liters
	CurrentFuelEvent.PricePerLiter = input.PricePerLiter
	CurrentFuelEvent.Price = input.Price
	CurrentFuelEvent.FuelRate = input.FuelRate
	CurrentFuelEvent.OdometerBefore = input.OdometerBefore
	CurrentFuelEvent.OdometerAfter = input.OdometerAfter

	f, err := excelize.OpenFile(Constants.SMBPath + "تفويلات.xlsx")
	if err != nil {
		log.Println(err)
		return &FuelEvent{}, err
	}
	sheets := f.GetSheetMap()
	var carSheetExists bool
	var activeSheet string
	for _, sheet := range sheets {
		if sheet == input.CarNoPlate {
			carSheetExists = true
		}
	}
	if !carSheetExists {
		f.NewSheet(input.CarNoPlate)

	}
	activeSheet = input.CarNoPlate
	index := strconv.Itoa(CurrentFuelEvent.ExcelIndex)

	differenceKM := input.OdometerAfter - input.OdometerBefore
	fuelRate := fmt.Sprintf("%v", input.FuelRate)
	headers := map[string]string{
		"A1":        "التاريخ",
		"B1":        "رقم العربية",
		"C1":        "السائق",
		"D1":        "العداد الحالي",
		"E1":        "العداد السابق",
		"F1":        "فرق الكيلومتر",
		"G1":        "المعدل",
		"H1":        "كمية التفويل",
		"I1":        "سعر اللتر",
		"J1":        "التكلفة",
		"A" + index: input.Date,
		"B" + index: input.CarNoPlate,
		"C" + index: input.DriverName,
		"D" + index: strconv.Itoa(int(input.OdometerAfter)),
		"E" + index: strconv.Itoa(int(input.OdometerBefore)),
		"F" + index: strconv.Itoa(int(differenceKM)),
		"G" + index: fuelRate,
		"H" + index: fmt.Sprintf("%v", input.Liters),
		"I" + index: fmt.Sprintf("%v", input.PricePerLiter),
		"J" + index: fmt.Sprintf("%v", input.Price),
	}
	for k, v := range headers {
		f.SetCellValue(activeSheet, k, v)
	}
	if err := f.Save(); err != nil {
		return &FuelEvent{}, err
	}

	fExpenses, err := excelize.OpenFile(Constants.SMBPath + "تكاليف السيارات.xlsx")
	if err != nil {
		log.Println(err)
		return &FuelEvent{}, err
	}
	indexExpenses := strconv.Itoa(CurrentFuelEvent.ExcelIndexExpenses)
	headersExpenses := map[string]string{
		"A1":                "التاريخ",
		"B1":                "رقم العربية",
		"C1":                "السائق",
		"D1":                "العداد الحالي",
		"E1":                "العداد السابق",
		"F1":                "فرق الكيلومتر",
		"G1":                "المعدل",
		"H1":                "كمية التفويل",
		"I1":                "سعر اللتر",
		"J1":                "التكلفة",
		"A" + indexExpenses: input.Date,
		"B" + indexExpenses: input.CarNoPlate,
		"C" + indexExpenses: input.DriverName,
		"D" + indexExpenses: strconv.Itoa(int(input.OdometerAfter)),
		"E" + indexExpenses: strconv.Itoa(int(input.OdometerBefore)),
		"F" + indexExpenses: strconv.Itoa(int(differenceKM)),
		"G" + indexExpenses: fuelRate,
		"H" + indexExpenses: fmt.Sprintf("%v", input.Liters),
		"I" + indexExpenses: fmt.Sprintf("%v", input.PricePerLiter),
		"J" + indexExpenses: fmt.Sprintf("%v", input.Price),
	}
	for k, v := range headersExpenses {
		fExpenses.SetCellValue("تفويل", k, v)
	}
	if err := fExpenses.Save(); err != nil {
		return &FuelEvent{}, err
	}

	if err := DB.Save(&CurrentFuelEvent).Error; err != nil {
		log.Println(err.Error())
		return &FuelEvent{}, err
	}
	return &CurrentFuelEvent, nil
}

func (input *FuelEvent) Delete() (*FuelEvent, error) {
	f, err := excelize.OpenFile(Constants.SMBPath + "تفويلات.xlsx")
	if err != nil {
		log.Println(err)
		return &FuelEvent{}, err
	}
	index := strconv.Itoa(input.ExcelIndex)
	headers := map[string]string{
		"A" + index: "Deleted",
		"B" + index: "Deleted",
		"C" + index: "Deleted",
		"D" + index: "Deleted",
		"D" + index: "Deleted",
		"E" + index: "Deleted",
		"F" + index: "Deleted",
		"G" + index: "Deleted",
		"H" + index: "Deleted",
		"I" + index: "Deleted",
		"J" + index: "Deleted",
	}
	for k, v := range headers {
		f.SetCellValue(input.CarNoPlate, k, v)
	}
	if err := f.Save(); err != nil {
		return &FuelEvent{}, err
	}

	fExpenses, err := excelize.OpenFile(Constants.SMBPath + "تكاليف السيارات.xlsx")
	if err != nil {
		log.Println(err)
		return &FuelEvent{}, err
	}
	indexExpenses := strconv.Itoa(input.ExcelIndexExpenses)
	headersExpenses := map[string]string{
		"A" + indexExpenses: "Deleted",
		"B" + indexExpenses: "Deleted",
		"C" + indexExpenses: "Deleted",
		"D" + indexExpenses: "Deleted",
		"D" + indexExpenses: "Deleted",
		"E" + indexExpenses: "Deleted",
		"F" + indexExpenses: "Deleted",
		"G" + indexExpenses: "Deleted",
		"H" + indexExpenses: "Deleted",
		"I" + indexExpenses: "Deleted",
		"J" + indexExpenses: "Deleted",
	}
	for k, v := range headersExpenses {
		fExpenses.SetCellValue("تفويل", k, v)
	}
	if err := fExpenses.Save(); err != nil {
		return &FuelEvent{}, err
	}
	if err := DB.Delete(&FuelEvent{}, input).Error; err != nil {
		log.Println(err.Error())
		return &FuelEvent{}, err
	}
	return input, nil
}
