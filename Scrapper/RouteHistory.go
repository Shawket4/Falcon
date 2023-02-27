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

type RoutePoint struct {
	Latitude  string `json:"latitude"`
	Longitude string `json:"longitude"`
	TimeStamp string `json:"time_stamp"`
}

type FinalStructResponse struct {
	Points      []RoutePoint
	TripSummary TripSummary `json:"trip_summary"`
}

type TripSummary struct {
	TotalMileage          string `yaml:"TotalMileage"`
	TotalActiveTime       string `yaml:"TotalActiveTime"`
	TotalPassiveTime      string `yaml:"TotalPassiveTime"`
	TotalIdleTime         string `yaml:"TotalIdleTime"`
	NumberofStops         string `yaml:"NumberofStops"`
	TotalDisConnectedTime string `yaml:"TotalDisConnectedTime"`
	Sensor1               string `yaml:"Sensor1"`
	Sensor2               string `yaml:"Sensor2"`
}

type RouteResponse struct {
	History []struct {
		Point []struct {
			Latitude  string `yaml:"a"`
			Longitude string `yaml:"o"`
		} `yaml:"p"`
		DateTime string `yaml:"d"`
	} `yaml:"history"`
}

func (app *App) GetVehicleRouteHistoryData(client *colly.Collector, data MileageStruct) (FinalStructResponse, error) {
	app.GetCurrentLocationData(client)
	var returnData FinalStructResponse
	var tripSummary TripSummary
	// reqString := fmt.Sprintf("https://fms-gps.etit-eg.com/WebPages/GetHistoryTripSummary.ashx?id=%s&time=6&from=%s&to=%s", data.VehicleID, "11/1/2022%2000:00:00", "11/1/2022%2023:59:59")
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

	var responseData RouteResponse

	if err := yaml.Unmarshal([]byte(jsonString), &responseData); err != nil {
		fmt.Println("error:", err)
	}

	var Points []RoutePoint
	Points = nil
	for _, responsePoint := range responseData.History {
		var point RoutePoint
		point.Latitude = responsePoint.Point[0].Latitude
		point.Longitude = responsePoint.Point[0].Longitude
		point.TimeStamp = responsePoint.DateTime
		Points = append(Points, point)
	}
	if Points == nil {
		GlobalClient, err := app.Login()
		if err != nil {
			return returnData, err
		}
		return app.GetVehicleRouteHistoryData(GlobalClient, data)
	}
	reqStringSummary := fmt.Sprintf("https://fms-gps.etit-eg.com/WebPages/GetHistoryTripSummary.ashx?id=%s&time=6&from=%s&to=%s", data.VehicleID, data.StartTime, data.EndTime)
	client.Request("GET", "https://fms-gps.etit-eg.com", nil, nil, http.Header{})
	client.Wait()
	reqSummary, _ := http.NewRequest("GET", reqStringSummary, nil)
	reqSummary.Header.Set("Cookie", fmt.Sprintf("%s;", cookies[4]))
	resSummary, err := app.Client.Do(reqSummary)
	if err != nil {
		log.Println(err.Error())
		return returnData, err
	}
	client.Wait()
	defer resSummary.Body.Close()
	bufSummary, err := io.ReadAll(resSummary.Body)
	if err != nil {
		log.Println(err.Error())
		return returnData, err
	}
	jsonDataSummary, err := yaml.Marshal(fmt.Sprintf("%s", bufSummary))
	if err != nil {
		log.Println(err.Error())
		return returnData, err
	}
	var jsonStringSummary string

	err = yaml.Unmarshal(jsonDataSummary, &jsonStringSummary)
	if err != nil {
		log.Println(err.Error())
		return returnData, err
	}
	if len(jsonStringSummary) > 13 {
		jsonStringSummary = fmt.Sprintf(`%s}`, jsonStringSummary[13:len(jsonStringSummary)-3])
	}
	fmt.Println(jsonStringSummary)
	if err := yaml.Unmarshal([]byte(jsonStringSummary), &tripSummary); err != nil {
		fmt.Println("error:", err)
	}

	returnData.Points = Points
	returnData.TripSummary = tripSummary
	return returnData, nil
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

	if err != nil {
		log.Println(err.Error())
		return err
	}
	route, err := app.GetVehicleRouteHistoryData(GlobalClient, data)
	if err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(route)
}

func GetTripRouteHistory(c *fiber.Ctx) error {
	GlobalClient, _ = app.Login()
	var input struct {
		ID uint `json:"ID"`
	}
	if err := c.BodyParser(&input); err != nil {
		log.Println(err.Error())
		return err
	}
	var trip Models.TripStruct
	if err := Models.DB.Model(&Models.TripStruct{}).Where("id = ?", input.ID).Find(&trip).Error; err != nil {
		log.Println(err.Error())
		return err
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
		return err
	}
	return c.JSON(route)
}
