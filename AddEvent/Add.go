package AddEvent

import (
	"Falcon/Database"
	"Falcon/Structs"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

var (
	tmplAddServiceEvent  = template.Must(template.ParseFiles("./Templates/AddServiceEvent.html"))
	tmplAddDailyDelivery = template.Must(template.ParseFiles("./Templates/AddDailyDelivery.html"))
)

func AddServiceEventTmpl(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		tmplAddServiceEvent.Execute(w, nil)
		return
	}
	var data Structs.Service
	// Populate data from form values
	data.CarNoPlate = r.FormValue("CarNoPlate")
	data.ServiceType = r.FormValue("ServiceType")
	data.DateOfService = r.FormValue("DateOfService")
	data.ServiceCenter = r.FormValue("ServiceCenter")
	data.ServiceOdometerReading = r.FormValue("ServiceOdometerReading")
	data.CurrentOdometerReading = r.FormValue("CurrentOdometerReading")
	data.AlertAfter = r.FormValue("AlertAfter")
	db := Database.ConnectToDB()
	ServiceReading, err := strconv.Atoi(data.ServiceOdometerReading)
	if err != nil {
		fmt.Fprintf(w, err.Error())
	}
	CurrentReading, err := strconv.Atoi(data.CurrentOdometerReading)
	if err != nil {
		fmt.Fprintf(w, err.Error())
	}
	AlertAfter, err := strconv.Atoi(data.AlertAfter)
	if err != nil {
		fmt.Fprintf(w, err.Error())
	}
	query := fmt.Sprintf("INSERT INTO `ServiceEvents` (`CarNoPlate`, `ServiceType`, `DateOfService`, `ServiceCenter`, `ServiceOdometerReading`, `CurrentOdometerReading`, `AlertAfter`) VALUES ('%s', '%s', '%s', '%s', '%v', '%v', '%v');", data.CarNoPlate, data.ServiceType, data.DateOfService, data.ServiceCenter, ServiceReading, CurrentReading, AlertAfter)

	insert, err := db.Query(query)
	if err != nil {
		log.Println(err)
	}

	defer insert.Close()
	tmplAddServiceEvent.Execute(w, nil)
}

func AddServiceEvent(c *fiber.Ctx) error {
	var data Structs.Service

	if err := c.BodyParser(&data); err != nil {
		return err
	}

	db := Database.ConnectToDB()
	query := fmt.Sprintf("INSERT INTO `ServiceEvents` (`CarNoPlate`, `ServiceType`, `DateOfService`, `ServiceCenter`, `ServiceOdometerReading`, `CurrentOdometerReading`, `AlertAfter`) VALUES (%s, %s, %s, %s, %s, %s, %s);", data.CarNoPlate, data.ServiceType, data.DateOfService, data.ServiceCenter, data.ServiceOdometerReading, data.CurrentOdometerReading, data.AlertAfter)
	insert, err := db.Query(query)
	if err != nil {
		log.Println(err)
		return c.JSON(fiber.Map{
			"An Error Occured Please Contact Your System Adminstrator.": err.Error(),
		})
	}
	defer insert.Close()
	return c.JSON(fiber.Map{
		"Message": "Success",
	})
}

func AddCarHandler(c *fiber.Ctx) error {

	var data struct {
		CarNoPlate              string `json:"CarNoPlate"`
		TankNoPlate             string `json:"TankNoPlate"`
		TankCapacity            string `json:"TankCapacity"`
		InsuranceExpirationDate string `json:"InsuranceExpirationDate"`
		DriverName              string `json:"DriverName"`
	}

	if err := c.BodyParser(&data); err != nil {
		return err
	}
	db := Database.ConnectToDB()

	query := fmt.Sprintf("INSERT INTO `Cars` (`CarNoPlate`, `TankNoPlate`, `TankCapacity`, `InsuranceExpirationDate`) VALUES ('%s', '%s', '%s', '%s');", data.CarNoPlate, data.TankNoPlate, data.TankCapacity, data.InsuranceExpirationDate)
	insert, err := db.Query(query)
	if err != nil {
		log.Println(err)
	}
	defer insert.Close()
	return c.JSON(data)
}

// AddDelivery Function From Tmpl

func AddDeliveryTmpl(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		tmplAddDailyDelivery.Execute(w, nil)
		return
	}
	var data Structs.DailyDelivery
	// Populate data from form values
	data.Date = r.FormValue("Date")
	data.DriverName = r.FormValue("DriverName")
	data.AmountDelivered = r.FormValue("AmountDelivered")
	data.CarNoPlate = r.FormValue("CarNoPlate")
	data.TrailerNoPlate = r.FormValue("TrailerNoPlate")
	data.PickUpPoint = r.FormValue("PickUpPoint")
	data.DepositPoint1 = r.FormValue("DepositPoint1")
	data.DepositPoint2 = r.FormValue("DepositPoint2")
	data.DepositPoint3 = r.FormValue("DepositPoint3")
	data.Distance = r.FormValue("Distance")
	data.Fees = r.FormValue("Fees")
	data.Notes = r.FormValue("Notes")
	db := Database.ConnectToDB()
	query := fmt.Sprintf("INSERT INTO `DailyDeliverySheet` (`Date`, `DriverName`, `AmountDelivered`, `CarNoPlate`, `TrailerNoPlate`, `PickUpPoint`, `DepositPoint1`, `DepositPoint2`, `DepositPoint3`, `Distance`, `Fees`, `Notes`) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');", data.Date, data.DriverName, data.AmountDelivered, data.CarNoPlate, data.TrailerNoPlate, data.PickUpPoint, data.DepositPoint1, data.DepositPoint2, data.DepositPoint3, data.Distance, data.Fees, data.Notes)

	insert, err := db.Query(query)
	if err != nil {
		log.Println(err)
	}
	defer insert.Close()

	tmplAddDailyDelivery.Execute(w, nil)
}
