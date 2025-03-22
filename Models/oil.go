package Models

import (
	"log"

	"gorm.io/gorm"
)

type OilChange struct {
	gorm.Model
	CarID            uint    `json:"car_id"`
	CarNoPlate       string  `json:"car_no_plate"`
	DriverName       string  `json:"driver_name"`
	SuperVisor       string  `json:"super_visor"`
	Date             string  `json:"date"`
	Mileage          float64 `json:"mileage"`
	OdometerAtChange float64 `json:"odometer_at_change"`
	CurrentOdometer  float64 `json:"current_odometer"`
	ExcelIndex       int
	Transporter      string  `json:"transporter"`
	Cost             float64 `json:"cost"`
}

func (input *OilChange) Add() (OilChange, error) {
	// f, err := excelize.OpenFile(Constants.SMBPath + "تغير زيت.xlsx")
	// if err != nil {
	// 	log.Println(err)
	// 	return OilChange{}, err
	// }
	// data := f.GetRows("Sheet1")
	// index := strconv.Itoa(len(data) + 1)
	// input.ExcelIndex = len(data) + 1

	// difference := input.CurrentOdometer - input.OdometerAtChange
	// mileageLeft := input.Mileage - difference

	// headers := map[string]string{
	// 	"A1":        "التاريخ",
	// 	"B1":        "رقم العربية",
	// 	"C1":        "السائق",
	// 	"D1":        "عداد التغير",
	// 	"E1":        "العداد الحالي",
	// 	"F1":        "فرق الكيلومتر",
	// 	"G1":        "نوع الزيت",
	// 	"H1":        "متبقي",
	// 	"I1":        "المشرف",
	// 	"J1":        "التكلفة",
	// 	"A" + index: input.Date,
	// 	"B" + index: input.CarNoPlate,
	// 	"C" + index: input.DriverName,
	// 	"D" + index: strconv.Itoa(int(input.OdometerAtChange)),
	// 	"E" + index: strconv.Itoa(int(input.CurrentOdometer)),
	// 	"F" + index: strconv.Itoa(int(difference)),
	// 	"G" + index: strconv.Itoa(int(input.Mileage)),
	// 	"H" + index: strconv.Itoa(int(mileageLeft)),
	// 	"I" + index: input.SuperVisor,
	// 	"J" + index: fmt.Sprintf("%v", input.Cost),
	// }
	// for k, v := range headers {
	// 	f.SetCellValue("Sheet1", k, v)
	// }
	// if err := f.Save(); err != nil {
	// 	return OilChange{}, err
	// }
	// fExpenses, err := excelize.OpenFile(Constants.SMBPath + "تكاليف السيارات.xlsx")
	// if err != nil {
	// 	log.Println(err)
	// 	return OilChange{}, err
	// }
	// for k, v := range headers {
	// 	fExpenses.SetCellValue("زيت", k, v)
	// }
	// if err := fExpenses.Save(); err != nil {
	// 	return OilChange{}, err
	// }
	if err := DB.Create(&input).Error; err != nil {
		log.Println(err.Error())
		return OilChange{}, err
	}
	return *input, nil
}

func (input *OilChange) Edit() (*OilChange, error) {
	// f, err := excelize.OpenFile(Constants.SMBPath + "تغير زيت.xlsx")
	// if err != nil {
	// 	log.Println(err)
	// 	return &OilChange{}, err
	// }
	// index := strconv.Itoa(input.ExcelIndex)
	// difference := input.CurrentOdometer - input.OdometerAtChange
	// mileageLeft := input.Mileage - difference

	// headers := map[string]string{
	// 	"A" + index: input.Date,
	// 	"B" + index: input.CarNoPlate,
	// 	"C" + index: input.DriverName,
	// 	"D" + index: strconv.Itoa(int(input.OdometerAtChange)),
	// 	"E" + index: strconv.Itoa(int(input.CurrentOdometer)),
	// 	"F" + index: strconv.Itoa(int(difference)),
	// 	"G" + index: strconv.Itoa(int(input.Mileage)),
	// 	"H" + index: strconv.Itoa(int(mileageLeft)),
	// 	"I" + index: input.SuperVisor,
	// 	"J" + index: fmt.Sprintf("%v", input.Cost),
	// }
	// for k, v := range headers {
	// 	f.SetCellValue("Sheet1", k, v)
	// }
	// if err := f.Save(); err != nil {
	// 	return &OilChange{}, err
	// }

	// fExpenses, err := excelize.OpenFile(Constants.SMBPath + "تكاليف السيارات.xlsx")
	// if err != nil {
	// 	log.Println(err)
	// 	return &OilChange{}, err
	// }
	// for k, v := range headers {
	// 	fExpenses.SetCellValue("زيت", k, v)
	// }
	// if err := fExpenses.Save(); err != nil {
	// 	return &OilChange{}, err
	// }
	if err := DB.Save(&input).Error; err != nil {
		log.Println(err.Error())
		return nil, err
	}
	return input, nil
}

func (input *OilChange) Delete() (*OilChange, error) {

	// f, err := excelize.OpenFile(Constants.SMBPath + "تغير زيت.xlsx")
	// if err != nil {
	// 	log.Println(err)
	// 	return &OilChange{}, err
	// }
	// index := strconv.Itoa(input.ExcelIndex)
	// headers := map[string]string{
	// 	"A" + index: "Deleted",
	// 	"B" + index: "Deleted",
	// 	"C" + index: "Deleted",
	// 	"D" + index: "Deleted",
	// 	"E" + index: "Deleted",
	// 	"F" + index: "Deleted",
	// 	"G" + index: "Deleted",
	// 	"H" + index: "Deleted",
	// 	"I" + index: "Deleted",
	// 	"J" + index: "Deleted",
	// }
	// for k, v := range headers {
	// 	f.SetCellValue("Sheet1", k, v)
	// }
	// if err := f.Save(); err != nil {
	// 	return &OilChange{}, err
	// }

	// fExpenses, err := excelize.OpenFile(Constants.SMBPath + "تكاليف السيارات.xlsx")
	// if err != nil {
	// 	log.Println(err)
	// 	return &OilChange{}, err
	// }
	// for k, v := range headers {
	// 	fExpenses.SetCellValue("زيت", k, v)
	// }
	// if err := fExpenses.Save(); err != nil {
	// 	return &OilChange{}, err
	// }

	if err := DB.Delete(&OilChange{}, input).Error; err != nil {
		log.Println(err.Error())
		return &OilChange{}, err
	}
	return input, nil
}
