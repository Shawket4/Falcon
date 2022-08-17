package PreviewData

import (
	"Falcon/Database"
	"Falcon/Structs"
	"log"
	"net/http"
	"text/template"

	"github.com/gofiber/fiber/v2"
)

var (
	tmplShowServiceEvent = template.Must(template.ParseFiles("./Templates/all-service-events.html"))
)

// Display All Service Events

func ShowAllServiceEvents(w http.ResponseWriter, r *http.Request) {
	db := Database.ConnectToDB()
	query, err := db.Query("SELECT * FROM `ServiceEvents`")
	if err != nil {
		log.Println(err)
	}
	defer query.Close()
	var data []Structs.Service
	for query.Next() {
		var queryData Structs.Service
		var IsAlerted int64
		err = query.Scan(&queryData.EventId, &IsAlerted, &queryData.CarNoPlate, &queryData.ServiceType, &queryData.DateOfService, &queryData.ServiceCenter, &queryData.ServiceOdometerReading, &queryData.CurrentOdometerReading, &queryData.AlertAfter)
		if err != nil {
			log.Println(err)
		}
		data = append(data, queryData)
	}
	// Make an array for each property
	var serviceId []string
	var carNoPlate []string
	var serviceType []string
	var dateOfService []string
	var serviceCenter []string
	var serviceOdometerReading []string
	var currentOdometerReading []string
	var alertAfter []string
	// Loop through the data and append the properties to the array
	for _, v := range data {
		serviceId = append(serviceId, v.EventId+",")
		carNoPlate = append(carNoPlate, v.CarNoPlate+",")
		serviceType = append(serviceType, v.ServiceType+",")
		dateOfService = append(dateOfService, v.DateOfService+",")
		serviceCenter = append(serviceCenter, v.ServiceCenter+",")
		serviceOdometerReading = append(serviceOdometerReading, v.ServiceOdometerReading+",")
		currentOdometerReading = append(currentOdometerReading, v.CurrentOdometerReading+",")
		alertAfter = append(alertAfter, v.AlertAfter+",")
	}
	// Remove the last character of the last element in each array
	// Check if array is empty
	if len(serviceId) > 0 {
		serviceId[len(serviceId)-1] = serviceId[len(serviceId)-1][:len(serviceId[len(serviceId)-1])-1]
		carNoPlate[len(carNoPlate)-1] = carNoPlate[len(carNoPlate)-1][:len(carNoPlate[len(carNoPlate)-1])-1]
		serviceType[len(serviceType)-1] = serviceType[len(serviceType)-1][:len(serviceType[len(serviceType)-1])-1]
		dateOfService[len(dateOfService)-1] = dateOfService[len(dateOfService)-1][:len(dateOfService[len(dateOfService)-1])-1]
		serviceCenter[len(serviceCenter)-1] = serviceCenter[len(serviceCenter)-1][:len(serviceCenter[len(serviceCenter)-1])-1]
		serviceOdometerReading[len(serviceOdometerReading)-1] = serviceOdometerReading[len(serviceOdometerReading)-1][:len(serviceOdometerReading[len(serviceOdometerReading)-1])-1]
		currentOdometerReading[len(currentOdometerReading)-1] = currentOdometerReading[len(currentOdometerReading)-1][:len(currentOdometerReading[len(currentOdometerReading)-1])-1]
		alertAfter[len(alertAfter)-1] = alertAfter[len(alertAfter)-1][:len(alertAfter[len(alertAfter)-1])-1]
	}
	// Pass the arrays to the template
	tmplShowServiceEvent.Execute(w, struct {
		ServiceEventId         []string
		CarNoPlate             []string
		ServiceType            []string
		DateOfService          []string
		ServiceCenter          []string
		ServiceOdometerReading []string
		CurrentOdometerReading []string
		AlertAfter             []string
	}{
		ServiceEventId:         serviceId,
		CarNoPlate:             carNoPlate,
		ServiceType:            serviceType,
		DateOfService:          dateOfService,
		ServiceCenter:          serviceCenter,
		ServiceOdometerReading: serviceOdometerReading,
		CurrentOdometerReading: currentOdometerReading,
		AlertAfter:             alertAfter,
	})
}

// Display All Daily Deliveries
func ShowAllDailyDeliveries(c *fiber.Ctx) error {
	db := Database.ConnectToDB()
	query, err := db.Query("SELECT * FROM `DailyDeliverySheet`")
	if err != nil {
		log.Println(err)
	}
	defer query.Close()
	var data []Structs.DailyDelivery
	for query.Next() {
		var queryData Structs.DailyDelivery
		err = query.Scan(&queryData.DeliveryId, &queryData.Date, &queryData.DriverName, &queryData.AmountDelivered, &queryData.CarNoPlate, &queryData.TrailerNoPlate, &queryData.PickUpPoint, &queryData.DepositPoint1, &queryData.DepositPoint2, &queryData.DepositPoint3, &queryData.Distance, &queryData.Fees, &queryData.Notes)
		if err != nil {
			log.Println(err)
		}
		data = append(data, queryData)
	}
	// Make an array for each property
	var deliveryId []string
	var date []string
	var driverName []string
	var amountDelivered []string
	var carNoPlate []string
	var trailerNoPlate []string
	var pickUpPoint []string
	var depositPoint1 []string
	var depositPoint2 []string
	var depositPoint3 []string
	var distance []string
	var fees []string
	var notes []string
	// Loop through the data and append the properties to the array
	for _, v := range data {
		deliveryId = append(deliveryId, v.DeliveryId+",")
		date = append(date, v.Date+",")
		driverName = append(driverName, v.DriverName+",")
		amountDelivered = append(amountDelivered, v.AmountDelivered+",")
		carNoPlate = append(carNoPlate, v.CarNoPlate+",")
		trailerNoPlate = append(trailerNoPlate, v.TrailerNoPlate+",")
		pickUpPoint = append(pickUpPoint, v.PickUpPoint+",")
		depositPoint1 = append(depositPoint1, v.DepositPoint1+",")
		depositPoint2 = append(depositPoint2, v.DepositPoint2+",")
		depositPoint3 = append(depositPoint3, v.DepositPoint3+",")
		distance = append(distance, v.Distance+",")
		fees = append(fees, v.Fees+",")
		notes = append(notes, v.Notes+",")
	}
	// Remove the last character of the last element in each array
	// Check if array is empty
	if len(date) > 0 {
		deliveryId[len(deliveryId)-1] = deliveryId[len(deliveryId)-1][:len(deliveryId[len(deliveryId)-1])-1]
		date[len(date)-1] = date[len(date)-1][:len(date[len(date)-1])-1]
		driverName[len(driverName)-1] = driverName[len(driverName)-1][:len(driverName[len(driverName)-1])-1]
		amountDelivered[len(amountDelivered)-1] = amountDelivered[len(amountDelivered)-1][:len(amountDelivered[len(amountDelivered)-1])-1]
		carNoPlate[len(carNoPlate)-1] = carNoPlate[len(carNoPlate)-1][:len(carNoPlate[len(carNoPlate)-1])-1]
		trailerNoPlate[len(trailerNoPlate)-1] = trailerNoPlate[len(trailerNoPlate)-1][:len(trailerNoPlate[len(trailerNoPlate)-1])-1]
		pickUpPoint[len(pickUpPoint)-1] = pickUpPoint[len(pickUpPoint)-1][:len(pickUpPoint[len(pickUpPoint)-1])-1]
		depositPoint1[len(depositPoint1)-1] = depositPoint1[len(depositPoint1)-1][:len(depositPoint1[len(depositPoint1)-1])-1]
		depositPoint2[len(depositPoint2)-1] = depositPoint2[len(depositPoint2)-1][:len(depositPoint2[len(depositPoint2)-1])-1]
		depositPoint3[len(depositPoint3)-1] = depositPoint3[len(depositPoint3)-1][:len(depositPoint3[len(depositPoint3)-1])-1]
		distance[len(distance)-1] = distance[len(distance)-1][:len(distance[len(distance)-1])-1]
		fees[len(fees)-1] = fees[len(fees)-1][:len(fees[len(fees)-1])-1]
		notes[len(notes)-1] = notes[len(notes)-1][:len(notes[len(notes)-1])-1]
	}
	// Pass the arrays to the template
	return c.Render("all-daily-deliveries", fiber.Map{
		"DeliveryEventId": deliveryId,
		"Date":            date,
		"DriverName":      driverName,
		"AmountDelivered": amountDelivered,
		"CarNoPlate":      carNoPlate,
		"TrailerNoPlate":  trailerNoPlate,
		"PickUpPoint":     pickUpPoint,
		"DepositPoint1":   depositPoint1,
		"DepositPoint2":   depositPoint2,
		"DepositPoint3":   depositPoint3,
		"Distance":        distance,
		"Fees":            fees,
		"Notes":           notes,
	})
	// tmplShowDailyDeliveries.Execute(w, struct {
	// 	DeliveryEventId []string
	// 	Date            []string
	// 	DriverName      []string
	// 	AmountDelivered []string
	// 	CarNoPlate      []string
	// 	TrailerNoPlate  []string
	// 	PickUpPoint     []string
	// 	DepositPoint1   []string
	// 	DepositPoint2   []string
	// 	DepositPoint3   []string
	// 	Distance        []string
	// 	Fees            []string
	// 	Notes           []string
	// }{
	// 	DeliveryEventId: deliveryId,
	// 	Date:            date,
	// 	DriverName:      driverName,
	// 	AmountDelivered: amountDelivered,
	// 	CarNoPlate:      carNoPlate,
	// 	TrailerNoPlate:  trailerNoPlate,
	// 	PickUpPoint:     pickUpPoint,
	// 	DepositPoint1:   depositPoint1,
	// 	DepositPoint2:   depositPoint2,
	// 	DepositPoint3:   depositPoint3,
	// 	Distance:        distance,
	// 	Fees:            fees,
	// 	Notes:           notes,
	// })
}
