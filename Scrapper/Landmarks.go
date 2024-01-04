package Scrapper

import (
	"Falcon/Models"
	"encoding/json"
	"fmt"
	"log"
	"math"
	"strconv"
	"time"
)

var LandMarks []Models.LandMark

func Bod(t time.Time) time.Time {
	year, month, day := t.Date()
	return time.Date(year, month, day, 0, 0, 0, 0, t.Location())
}

func CheckLandMarks() error {
	LandMarks = append(LandMarks, Models.LandMark{Name: "قنا", Point: Models.RoutePoint{Latitude: "26.178385", Longitude: "32.687133"}})
	LandMarks = append(LandMarks, Models.LandMark{Name: "الهيكستب", Point: Models.RoutePoint{Latitude: "30.125916", Longitude: "31.358002"}})
	LandMarks = append(LandMarks, Models.LandMark{Name: "الفيوم", Point: Models.RoutePoint{Latitude: "29.339004", Longitude: "30.926716"}})
	fmt.Println(VehicleStatusList[0].ID)
	GlobalClient, _ = app.Login()
	routes := make(map[string]Models.FinalStructResponse)
	for _, vehicle := range VehicleStatusList {
		var data MileageStruct
		data.VehiclePlateNo = vehicle.PlateNo
		data.VehicleID = vehicle.ID
		startTime := time.Now().Add(-24 * time.Hour)
		startDate := Bod(startTime)
		formatedStartDate := startDate.Format("01/02/2006 15:04:05")
		data.StartTime = formatedStartDate[:10] + "%20" + formatedStartDate[11:]
		endTime := time.Now()
		endDate := Bod(endTime)
		formatedEndDate := endDate.Format("01/02/2006 15:04:05")
		data.EndTime = formatedEndDate[:10] + "%20" + formatedEndDate[11:]
		route, err := app.GetVehicleRouteHistoryData(GlobalClient, data)
		if err != nil {
			log.Println(err.Error())
			return err
		}
		routes[data.VehiclePlateNo] = route
		time.Sleep(time.Second * 4)
	}
	// fmt.Println(routes)
	for VehiclePlateNo, route := range routes {
		isInRange, pointLandMarkMap := CheckIfRouteIsInRange(route.Points)
		if isInRange {
			for landMark, point := range pointLandMarkMap {
				timeStampFormatted, err := convertTimeStampFormat(point.TimeStamp)
				if err != nil {
					return err
				}
				ChangeCarTripStatus(point, VehiclePlateNo, timeStampFormatted, landMark)
			}
		}
	}
	return nil
}

func convertTimeStampFormat(inputDate string) (string, error) {
	// Parse the input date string
	parsedTime, err := time.Parse("02/01/2006 15:04:05", inputDate)
	if err != nil {
		return "", err
	}

	// Format the time as per the desired layout
	formattedTime := parsedTime.Format("01/02/2006 15:04:05")

	// Replace the space with '%20' as per the requirement
	formattedTime = formattedTime[:10] + "%20" + formattedTime[11:]

	return formattedTime, nil
}

func ChangeCarTripStatus(point Models.RoutePoint, VehiclePlateNo, pointTimeFormatteed string, landMark Models.LandMark) error {
	var vehicle Models.Car
	if err := Models.DB.Model(&Models.Car{}).Where("car_no_plate = ?", VehiclePlateNo).Find(&vehicle).Error; err != nil {
		return err
	}
	if !vehicle.IsInTrip {
		var trip Models.TripStruct
		trip.StepCompleteTime.Terminal.TerminalName = landMark.Name
		trip.StartTime = pointTimeFormatteed
		trip.CarNoPlate = vehicle.CarNoPlate
		var err error
		if trip.StepCompleteTimeDB, err = json.Marshal(trip.StepCompleteTime); err != nil {
			log.Println(err.Error())
			return err
		}

		tripExists, err := CheckIfTripExists(trip)
		if err != nil {
			return err
		}
		fmt.Println(tripExists)
		if !tripExists {
			vehicle.IsInTrip = true
			if err := Models.DB.Save(&vehicle).Error; err != nil {
				return err
			}
			if err := Models.DB.Create(&trip).Error; err != nil {
				return err
			}
		}
	} else {
		var trip Models.TripStruct
		vehicle.IsInTrip = false
		if err := Models.DB.Save(&vehicle).Error; err != nil {
			return err
		}
		if err := Models.DB.Model(&Models.TripStruct{}).Where("car_no_plate = ?", vehicle.CarNoPlate).Last(&trip).Error; err != nil {
			return err
		}
		var dropOffPoint struct {
			TimeStamp    string `json:"time_stamp"`
			LocationName string `json:"location_name"`
			Capacity     int    `json:"capacity"`
			GasType      string `json:"gas_type"`
			Status       bool   `json:"status"`
		}
		dropOffPoint.LocationName = landMark.Name
		if err := json.Unmarshal(trip.StepCompleteTimeDB, &trip.StepCompleteTime); err != nil {
			return err
		}
		if trip.StepCompleteTime.Terminal.TerminalName == dropOffPoint.LocationName {
			return nil
		}
		trip.StepCompleteTime.DropOffPoints = []struct {
			TimeStamp    string `json:"time_stamp"`
			LocationName string `json:"location_name"`
			Capacity     int    `json:"capacity"`
			GasType      string `json:"gas_type"`
			Status       bool   `json:"status"`
		}{dropOffPoint}
		trip.EndTime = pointTimeFormatteed
		var err error
		if trip.StepCompleteTimeDB, err = json.Marshal(trip.StepCompleteTime); err != nil {
			log.Println(err.Error())
			return err
		}
		if err := Models.DB.Save(&trip).Error; err != nil {
			return err
		}
		fmt.Println(trip)
	}

	return nil
}

func CheckIfTripExists(trip Models.TripStruct) (bool, error) {
	var trips []Models.TripStruct
	if err := Models.DB.Model(&Models.TripStruct{}).Find(&trips).Error; err != nil {
		return false, err
	}
	for _, dbTrip := range trips {
		if dbTrip.CarNoPlate == trip.CarNoPlate && dbTrip.StartTime == trip.StartTime {
			return true, nil
		}
	}
	return false, nil
}

const earthRadiusKm = 6371.0

type LatLng struct {
	Lat float64
	Lng float64
}

func convertToLatLng(routePoint Models.RoutePoint) (LatLng, error) {
	// Convert latitude and longitude from strings to float64
	lat, errLat := strconv.ParseFloat(routePoint.Latitude, 64)
	lng, errLng := strconv.ParseFloat(routePoint.Longitude, 64)

	// Check for conversion errors
	if errLat != nil || errLng != nil {
		// Return an error if conversion fails
		return LatLng{}, fmt.Errorf("error converting latitude or longitude: %v, %v", errLat, errLng)
	}

	// Return the LatLng struct
	return LatLng{Lat: lat, Lng: lng}, nil
}

func haversine(lat1, lon1, lat2, lon2 float64) float64 {
	// Convert latitude and longitude from degrees to radians
	lat1, lon1, lat2, lon2 = degToRad(lat1), degToRad(lon1), degToRad(lat2), degToRad(lon2)

	// Calculate differences between latitudes and longitudes
	dLat := lat2 - lat1
	dLon := lon2 - lon1

	// Haversine formula
	a := math.Sin(dLat/2)*math.Sin(dLat/2) + math.Cos(lat1)*math.Cos(lat2)*math.Sin(dLon/2)*math.Sin(dLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	// Distance in kilometers
	distance := earthRadiusKm * c

	return distance
}

func degToRad(deg float64) float64 {
	return deg * (math.Pi / 180.0)
}

func isIn1KmRange(point1, point2 Models.RoutePoint) bool {
	point1LatLng, _ := convertToLatLng(point1)
	point2LatLng, _ := convertToLatLng(point2)
	distance := haversine(point1LatLng.Lat, point1LatLng.Lng, point2LatLng.Lat, point2LatLng.Lng)
	return distance <= 1.0
}

func CheckIfRouteIsInRange(points []Models.RoutePoint) (bool, map[Models.LandMark]Models.RoutePoint) {
	output := make(map[Models.LandMark]Models.RoutePoint)
	for _, landMark := range LandMarks {
		for _, point := range points {
			isInRange := isIn1KmRange(landMark.Point, point)
			if isInRange {
				if _, exists := output[landMark]; !exists {
					output[landMark] = point
				}
			}
		}
	}
	if len(output) == 0 {
		return false, output
	}
	return true, output
}
