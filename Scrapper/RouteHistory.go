package Scrapper

import (
	"Falcon/Models"
	"fmt"
	"io"
	"log"
	"net/http"

	"github.com/gocolly/colly"
	"github.com/gofiber/fiber/v2"
	"gopkg.in/yaml.v3"
)

func (app *App) GetVehicleRouteHistoryData(client *colly.Collector, data MileageStruct) (Models.FinalStructResponse, error) {
	app.GetCurrentLocationData(client)
	var returnData Models.FinalStructResponse
	// reqString := "https://fms-gps.etit-eg.com/WebPages/GetAllHistoryData.aspx?_=1700575497270&id=19419bf3-6aa0-e811-80de-0025b500010d&time=6&points=1&from=11/18/2023%2000:00:00&to=11/18/2023%2023:59:59"
	reqString := fmt.Sprintf("https://fms-gps.etit-eg.com/WebPages/GetAllHistoryData.aspx?id=%s&time=6&from=%s&to=%s", data.VehicleID, data.StartTime, data.EndTime)
	client.Request("GET", "https://fms-gps.etit-eg.com", nil, nil, http.Header{})
	client.Wait()
	cookies := client.Cookies("https://fms-gps.etit-eg.com")
	req, _ := http.NewRequest("GET", reqString, nil)
	req.Header.Set("Cookie", fmt.Sprintf("%s;", cookies[4]))
	res, err := app.Client.Do(req)
	if err != nil {
		log.Println(err.Error())
		return returnData, err
	}
	client.Wait()
	defer res.Body.Close()
	buf, err := io.ReadAll(res.Body)
	if err != nil {
		log.Println(err.Error())
		return returnData, err
	}
	jsonData, err := yaml.Marshal(fmt.Sprintf("%s", buf))
	if err != nil {
		log.Println(err.Error())
		return returnData, err
	}
	var jsonString string
	err = yaml.Unmarshal(jsonData, &jsonString)
	if err != nil {
		log.Println(err.Error())
		return returnData, err
	}

	if len(jsonString) > 9 {
		jsonString = fmt.Sprintf(`{"history":%s`, jsonString[9:])
	}

	var responseData Models.RouteResponse

	if err := yaml.Unmarshal([]byte(jsonString), &responseData); err != nil {
		fmt.Println("error:", err)
	}

	var Points []Models.RoutePoint
	Points = nil
	for _, responsePoint := range responseData.History {
		var point Models.RoutePoint
		point.Latitude = responsePoint.Point[0].Latitude
		point.Longitude = responsePoint.Point[0].Longitude
		point.TimeStamp = responsePoint.DateTime
		Points = append(Points, point)
	}
	// if Points == nil {
	// 	GlobalClient, err := app.Login()
	// 	if err != nil {
	// 		return returnData, err
	// 	}
	// 	return app.GetVehicleRouteHistoryData(GlobalClient, data)
	// }

	returnData.Points = Points
	// tripSummary, err := GetTripSummary(client, data, cookies)
	// if err != nil {
	// 	return returnData, err
	// }
	// returnData.TripSummary = tripSummary

	// returnData.Mileage, err = strconv.ParseFloat(tripSummary.TotalMileage, 64)
	// if err != nil {
	// 	log.Println(err.Error())
	// }
	return returnData, nil
}

func GetTripSummary(client *colly.Collector, data MileageStruct, cookies []*http.Cookie) (Models.TripSummary, error) {
	var tripSummary Models.TripSummary
	reqStringSummary := fmt.Sprintf("https://fms-gps.etit-eg.com/WebPages/GetHistoryTripSummary.ashx?id=%s&time=6&from=%s&to=%s", data.VehicleID, data.StartTime, data.EndTime)
	client.Request("GET", "https://fms-gps.etit-eg.com", nil, nil, http.Header{})
	client.Wait()
	reqSummary, _ := http.NewRequest("GET", reqStringSummary, nil)
	reqSummary.Header.Set("Cookie", fmt.Sprintf("%s;", cookies[4]))
	resSummary, err := app.Client.Do(reqSummary)
	if err != nil {
		log.Println(err.Error())
		return Models.TripSummary{}, err
	}
	client.Wait()
	defer resSummary.Body.Close()
	bufSummary, err := io.ReadAll(resSummary.Body)
	if err != nil {
		log.Println(err.Error())
		return Models.TripSummary{}, err
	}
	jsonDataSummary, err := yaml.Marshal(fmt.Sprintf("%s", bufSummary))
	if err != nil {
		log.Println(err.Error())
		return Models.TripSummary{}, err
	}
	var jsonStringSummary string

	err = yaml.Unmarshal(jsonDataSummary, &jsonStringSummary)
	if err != nil {
		log.Println(err.Error())
		return Models.TripSummary{}, err
	}
	if len(jsonStringSummary) > 13 {
		jsonStringSummary = fmt.Sprintf(`%s}`, jsonStringSummary[13:len(jsonStringSummary)-3])
	}
	fmt.Println(jsonStringSummary)
	if err := yaml.Unmarshal([]byte(jsonStringSummary), &tripSummary); err != nil {
		fmt.Println("error:", err)
	}
	return tripSummary, nil
}

func GetVehicleRouteHistory(c *fiber.Ctx) error {
	GlobalClient, _ = app.Login()
	var data MileageStruct
	err := c.BodyParser(&data)
	if err != nil {
		log.Println(err.Error())
		return c.JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	fmt.Println(len(VehicleStatusList))
	fmt.Println(data.VehiclePlateNo)
	for _, vehicle := range VehicleStatusList {
		if vehicle.PlateNo == data.VehiclePlateNo {
			data.VehicleID = vehicle.ID
		}
	}

	route, err := app.GetVehicleRouteHistoryData(GlobalClient, data)
	if err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(route)
}

func GetTripRouteHistory(tripID uint) (Models.FinalStructResponse, error) {
	GlobalClient, _ = app.Login()

	var trip Models.TripStruct
	if err := Models.DB.Model(&Models.TripStruct{}).Where("id = ?", tripID).Find(&trip).Error; err != nil {
		log.Println(err.Error())
		return Models.FinalStructResponse{}, err
	}
	var data MileageStruct
	data.VehiclePlateNo = trip.CarNoPlate
	data.StartTime = trip.StartTime
	data.EndTime = trip.EndTime
	for _, vehicle := range VehicleStatusList {
		if vehicle.PlateNo == data.VehiclePlateNo {
			data.VehicleID = vehicle.ID
		}
	}
	fmt.Println(data)
	route, err := app.GetVehicleRouteHistoryData(GlobalClient, data)
	if err != nil {
		log.Println(err.Error())
		return Models.FinalStructResponse{}, err
	}
	return route, nil
}

func GetTripRouteHistoryAPI(c *fiber.Ctx) error {
	var input struct {
		ID uint `json:"ID"`
	}
	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}
	var trip Models.TripStruct
	var tripRoute Models.FinalStructResponse
	var tripPoints []Models.RoutePoint
	var tripSummary Models.TripSummary
	if err := Models.DB.Model(&Models.TripStruct{}).Where("id = ?", input.ID).Preload("Route").Find(&trip).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	if err := Models.DB.Model(&Models.FinalStructResponse{}).Where("id = ?", trip.Route.ID).Preload("Points").Preload("TripSummary").Find(&tripRoute).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	if err := Models.DB.Model(&Models.RoutePoint{}).Where("final_struct_response_id = ?", trip.Route.ID).Find(&tripPoints).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	if err := Models.DB.Model(&Models.TripSummary{}).Where("final_struct_response_id = ?", trip.Route.ID).Find(&tripSummary).Error; err != nil {
		log.Println(err.Error())
		return err
	}
	tripRoute.TripSummary = tripSummary
	tripRoute.Points = tripPoints
	return c.JSON(tripRoute)
}
