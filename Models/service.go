package Models

import (
	"Falcon/Constants"
	"fmt"
	"log"
	"strconv"

	"github.com/360EntSecGroup-Skylar/excelize"
	"gorm.io/gorm"
)

type Service struct {
	gorm.Model
	CarID           uint   `json:"car_id"`
	CarNoPlate      string `json:"car_no_plate"`
	DriverName      string `json:"driver_name"`
	ServiceType     string `json:"service_type"`
	DateOfService   string `json:"date_of_service"`
	OdometerReading int    `json:"odometer_reading"`
	Transporter     string `json:"transporter"`
	ExcelIndex      int
	// CurrentOdometerReading int    `json:"CurrentOdometerReading"`
	SuperVisor     string  `json:"super_visor"`
	Cost           float64 `json:"cost"`
	ProofImageName string  `json:"proof_image_name"`
}

func (input *Service) Add() (*Service, error) {
	f, err := excelize.OpenFile(Constants.SMBPath + "صيانة.xlsx")
	if err != nil {
		log.Println(err)
		return &Service{}, err
	}
	data := f.GetRows("Sheet1")
	index := strconv.Itoa(len(data) + 1)
	input.ExcelIndex = len(data) + 1

	headers := map[string]string{
		"A1":        "التاريخ",
		"B1":        "رقم العربية",
		"C1":        "السائق",
		"D1":        "وصف الصيانة",
		"E1":        "عداد الصيانة",
		"F1":        "المشرف",
		"G1":        "التكلفة",
		"A" + index: input.DateOfService,
		"B" + index: input.CarNoPlate,
		"C" + index: input.DriverName,
		"D" + index: input.ServiceType,
		"E" + index: strconv.Itoa(input.OdometerReading),
		"F" + index: input.SuperVisor,
		"G" + index: fmt.Sprintf("%v", input.Cost),
	}
	for k, v := range headers {
		f.SetCellValue("Sheet1", k, v)
	}
	if err := f.Save(); err != nil {
		return &Service{}, err
	}

	fExpenses, err := excelize.OpenFile(Constants.SMBPath + "تكاليف السيارات.xlsx")
	if err != nil {
		log.Println(err)
		return &Service{}, err
	}
	for k, v := range headers {
		fExpenses.SetCellValue("صيانة", k, v)
	}
	if err := fExpenses.Save(); err != nil {
		return &Service{}, err
	}

	if err := DB.Create(&input).Error; err != nil {
		log.Println(err.Error())
		return &Service{}, err
	}
	return input, nil
}

func (input *Service) Edit() (*Service, error) {
	f, err := excelize.OpenFile(Constants.SMBPath + "صيانة.xlsx")
	if err != nil {
		log.Println(err)
		return &Service{}, err
	}
	index := strconv.Itoa(input.ExcelIndex)

	headers := map[string]string{
		"A" + index: input.DateOfService,
		"B" + index: input.CarNoPlate,
		"C" + index: input.DriverName,
		"D" + index: input.ServiceType,
		"E" + index: strconv.Itoa(input.OdometerReading),
		"F" + index: input.SuperVisor,
		"G" + index: fmt.Sprintf("%v", input.Cost),
	}
	for k, v := range headers {
		f.SetCellValue("Sheet1", k, v)
	}
	if err := f.Save(); err != nil {
		return &Service{}, err
	}

	fExpenses, err := excelize.OpenFile(Constants.SMBPath + "تكاليف السيارات.xlsx")
	if err != nil {
		log.Println(err)
		return &Service{}, err
	}
	for k, v := range headers {
		fExpenses.SetCellValue("صيانة", k, v)
	}
	if err := fExpenses.Save(); err != nil {
		return &Service{}, err
	}

	if err := DB.Save(&input).Error; err != nil {
		log.Println(err.Error())
		return nil, err
	}
	return input, nil
}

func (input *Service) Delete() (*Service, error) {
	f, err := excelize.OpenFile(Constants.SMBPath + "صيانة.xlsx")
	if err != nil {
		log.Println(err)
		return &Service{}, err
	}
	index := strconv.Itoa(input.ExcelIndex)
	headers := map[string]string{
		"A" + index: "Deleted",
		"B" + index: "Deleted",
		"C" + index: "Deleted",
		"D" + index: "Deleted",
		"E" + index: "Deleted",
		"F" + index: "Deleted",
		"G" + index: "Deleted",
	}
	for k, v := range headers {
		f.SetCellValue("Sheet1", k, v)
	}
	if err := f.Save(); err != nil {
		return &Service{}, err
	}

	fExpenses, err := excelize.OpenFile(Constants.SMBPath + "تكاليف السيارات.xlsx")
	if err != nil {
		log.Println(err)
		return &Service{}, err
	}
	for k, v := range headers {
		fExpenses.SetCellValue("صيانة", k, v)
	}
	if err := fExpenses.Save(); err != nil {
		return &Service{}, err
	}
	if err := DB.Delete(&Service{}, input).Error; err != nil {
		log.Println(err.Error())
		return &Service{}, err
	}
	return input, nil
}
