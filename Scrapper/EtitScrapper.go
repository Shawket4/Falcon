package Scrapper

import (
	"Falcon/Structs"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"

	// "time"

	"github.com/PuerkitoBio/goquery"
	"github.com/gocolly/colly"
	"github.com/gofiber/fiber/v2"
)

const (
	baseURL = "https://etit-fms.etit-eg.com"
)

var (
	username = "magda.adly"
	password = "etit135"
)

type VehicleStatusStruct struct {
	PlateNo      string
	Speed        int
	Longitude    string
	Latitude     string
	EngineStatus string
	ID           string
}

var VehicleStatusList []VehicleStatusStruct
var VehicleStatusListTemp []VehicleStatusStruct
var AllCoordinates map[string][]Structs.Coordinate

var Data struct {
	Data struct {
		Rows []struct {
			PlateNo string `json:"plateNo"`
			CodeNo  string `json:"CodePlateNumber"`
			ID      string `json:"ID"`
		} `json:"rows"`
	} `json:"d"`
}

type App struct {
	Client *http.Client
}

type AuthenticityToken struct {
	Token string
}

type Project struct {
	Name string
}

func (app *App) getToken() AuthenticityToken {
	loginURL := baseURL
	// client := app.Client
	customTransport := http.DefaultTransport.(*http.Transport).Clone()
	customTransport.TLSClientConfig = &tls.Config{InsecureSkipVerify: true}
	client := &http.Client{Transport: customTransport}
	response, err := client.Get(loginURL)

	if err != nil {
		log.Fatalln("Error fetching response. ", err)
	}

	defer response.Body.Close()

	document, err := goquery.NewDocumentFromReader(response.Body)
	if err != nil {
		log.Fatal("Error loading HTTP response body. ", err)
	}

	token, _ := document.Find("input[name='__VIEWSTATE']").Attr("value")

	authenticityToken := AuthenticityToken{
		Token: token,
	}

	return authenticityToken
}

func (app *App) GetVehicleHistoryData(VehicleID string, client *colly.Collector) []Structs.Coordinate {
	//var HistoryData struct {
	//	HistoryPoint []struct {
	//		Points []struct {
	//			Latitude  string `json:"a"`
	//			Longitude string `json:"o"`
	//		} `json:"p"`
	//		Date string `json:"d"`
	//	}
	//}
	var HistoryData Structs.TimeLineStruct
	//var HistoryData interface{}
	client.OnResponse(func(r *colly.Response) {
		jsonString := string(r.Body)
		var finalJson string
		client2 := colly.NewCollector()
		client2.OnResponse(func(jsonR *colly.Response) {
			formattedJson := string(jsonR.Body)
			var data struct {
				Result struct {
					Data string `json:"data"`
				} `json:"result"`
			}
			//fmt.Println(formattedJson)
			err := json.Unmarshal([]byte(formattedJson), &data)
			if err != nil {
				log.Println(err.Error())
			}
			finalJson = data.Result.Data
			//fmt.Println(finalJson)
			err = json.Unmarshal([]byte(finalJson), &HistoryData)
			if err != nil {
				log.Println(err.Error())
			}
		})
		client2.Post("https://jsonformatter.curiousconcept.com/process", map[string]string{"data": jsonString, "jsontemplate": "1", "jsonfix": "yes"})
		fmt.Println(HistoryData.History[0])
		// jsonString = strings.Replace(jsonString, "\"{", "{", -1)
		// jsonString = strings.Replace(jsonString, "\"}", "}", -1)
		// fmt.Println(jsonString)
		//fmt.Println(VehicleID)
		//fmt.Println(HistoryData.History[0].P)
		// fmt.Println(Data.Data.Rows[0])
		// for i := 0; i < len(Data.Data.Rows); i++ {
		// 	for i2 := 0; i2 < len(VehicleStatusListTemp); i2++ {
		// 		if Data.Data.Rows[i].PlateNo == VehicleStatusListTemp[i2].PlateNo {
		// 			VehicleStatusListTemp[i2].ID = Data.Data.Rows[i].ID
		// 		}
		// 	}
		// }
	})
	queryString := fmt.Sprintf("https://fms-gps.etit-eg.com/WebPages/GetAllHistoryData.aspx?id=%s&time=6&from=%s&to=%s", VehicleID, "12/24/2022%2000:00:00", "12/24/2022%2023:59:59")
	fmt.Println(queryString)
	err := client.Request("GET", queryString, nil, nil, http.Header{"Content-Type": []string{"text/html; charset=utf-8"}})
	if err != nil {
		log.Println(err)
	}

	for _, s := range HistoryData.History {
		var coordinate Structs.Coordinate
		coordinate.Longitude = s.P[0].A
		coordinate.Latitude = s.P[0].O
		coordinate.DateTime = s.D
		AllCoordinates[VehicleID] = append(AllCoordinates[VehicleID], coordinate)
	}
	return AllCoordinates[VehicleID]
	// err := client.Request("POST", baseURL+"/WebPages/Transporters/List.aspx/GetAllTransporterBySearchCriteria", strings.NewReader(jsonString), nil, http.Header{"Content-Type": []string{"application/json; charset=utf-8"}})
	// if err != nil {
	// 	log.Println(err)
	// }
	//return HistoryData
}

func (app *App) Login() (*colly.Collector, error) {
	authenticityToken := app.getToken()
	client := colly.NewCollector()
	client.WithTransport(&http.Transport{TLSClientConfig: &tls.Config{InsecureSkipVerify: true}})
	// http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}

	loginURL := baseURL + "/"
	data := map[string]string{
		"ScriptManager1":          "UpdatePanel1|lg_AltairLogin$LoginButton",
		"__EVENTTARGET":           "lg_AltairLogin$LoginButton",
		"__VIEWSTATE":             authenticityToken.Token,
		"__VIEWSTATEGENERATOR":    "0C2F32F0",
		"lg_AltairLogin$UserName": username,
		"lg_AltairLogin$Password": password,
	}

	if err := client.Post(loginURL, data); err != nil {
		return nil, err
	}
	fmt.Println("Logged In.")
	return client, nil
}

func (app *App) GetCurrentLocationData(client *colly.Collector) error {
	client.OnHTML("#ctl00_ContentPlaceHolder1_grd_TransportersData_ctl00", func(h *colly.HTMLElement) {
		h.ForEach("tr.rgRow", func(_ int, tr *colly.HTMLElement) {
			var CurrentVehicleStatus VehicleStatusStruct
			tr.ForEach("td", func(i int, td *colly.HTMLElement) {
				if i == 2 {
					CurrentVehicleStatus.PlateNo = td.Text
				} else if i == 7 {
					CurrentVehicleStatus.Latitude = td.Text
				} else if i == 8 {
					CurrentVehicleStatus.Longitude = td.Text
				} else if i == 12 {
					CurrentVehicleStatus.EngineStatus = td.Text
				} else if i == 13 {
					id, _ := strconv.Atoi(td.Text)
					CurrentVehicleStatus.Speed = id
					VehicleStatusListTemp = append(VehicleStatusListTemp, CurrentVehicleStatus)
				}
			})
		})
		h.ForEach("tr.rgAltRow", func(_ int, tr *colly.HTMLElement) {
			var CurrentVehicleStatus VehicleStatusStruct
			tr.ForEach("td", func(i int, td *colly.HTMLElement) {
				if i == 2 {
					CurrentVehicleStatus.PlateNo = td.Text
				} else if i == 7 {
					CurrentVehicleStatus.Latitude = td.Text
				} else if i == 8 {
					CurrentVehicleStatus.Longitude = td.Text
				} else if i == 12 {
					CurrentVehicleStatus.EngineStatus = td.Text
				} else if i == 13 {
					id, _ := strconv.Atoi(td.Text)
					CurrentVehicleStatus.Speed = id
					VehicleStatusListTemp = append(VehicleStatusListTemp, CurrentVehicleStatus)
				}
			})
		})
	})
	err := client.Request("GET", "https://fms-gps.etit-eg.com/WebPages/UpdateTransportersData.aspx", nil, nil, http.Header{"Content-Type": []string{"text/html; charset=utf-8"}})
	if err != nil {
		log.Println(err)
		return err
	}
	client.OnResponse(func(r *colly.Response) {
		jsonString := string(r.Body)
		jsonString = strings.Replace(jsonString, "\\", "", -1)
		jsonString = strings.Replace(jsonString, "\"{", "{", -1)
		jsonString = strings.Replace(jsonString, "\"}", "}", -1)

		err := json.Unmarshal([]byte(jsonString), &Data)
		if err != nil {
			log.Println(err.Error())
		}
		// fmt.Println(Data.Data.Rows[0])
		for i := 0; i < len(Data.Data.Rows); i++ {
			for i2 := 0; i2 < len(VehicleStatusListTemp); i2++ {
				if Data.Data.Rows[i].PlateNo == VehicleStatusListTemp[i2].PlateNo {
					VehicleStatusListTemp[i2].ID = Data.Data.Rows[i].ID
				}
			}
		}
	})
	jsonString := `{"transpoterCriteria":{"SubId":"","StuffId":"","TransporterCodeName":"","TransporterId":"","TransporterTypeId":"","TransporterGroupID":"","LandmarkId":"","ManufacturerId":"","ProductionYearID":"","BranchID":"","SubBranchID":"","NextExaminationDate":"","LicenseExpiryDate":"","InsuranceEndDate":"","EntranceDate":"","TransporterBrand":"","DasboardGPsStatus":"","IsdasboardGPsStatus":0,"TransporterStatus":"","Category":"","EntranceDateBeforeAfter":"","InsuranceEndDateBeforeAfter":"","LicenseExpiryDateBeforeAfter":"","NextExaminationDateBeforAfter":"","PageCount":0,"PageIndex":1,"PageSize":20,"TotalTransCount":0,"TransporterIdList":[]}}`

	err = client.Request("POST", baseURL+"/WebPages/Transporters/List.aspx/GetAllTransporterBySearchCriteria", strings.NewReader(jsonString), nil, http.Header{"Content-Type": []string{"application/json; charset=utf-8"}})
	if err != nil {
		log.Println(err)
		return err
	}

	if len(VehicleStatusListTemp) == 0 {
		return errors.New("Empty")
	}
	VehicleStatusList = VehicleStatusListTemp
	return nil
}

var jar, _ = cookiejar.New(nil)

var app = App{
	Client: &http.Client{Jar: jar},
}

var isLoaded bool = false
var GlobalClient *colly.Collector

func GetVehicleData() {
	GlobalClient, err := app.Login()

	if err != nil {
		log.Println(err.Error())
		return
	}
	VehicleStatusListTemp = []VehicleStatusStruct{}
	app.GetCurrentLocationData(GlobalClient)

	if VehicleStatusList != nil {
		fmt.Println(isLoaded)
		isLoaded = true
	}
	time.Sleep(time.Second * 20)
	fmt.Println(VehicleStatusList)
	// CheckMileageSinceOilChangeWorker(GlobalClient)
	// UpdateVehiclePlace(VehicleStatusList)
	//AllCoordinates := app.GetVehicleHistoryData(VehicleStatusList[0].ID, client)
	//fmt.Println(AllCoordinates[0:6])
}

// func GetVehicleHistoryData() {
// 	if isLoaded {
// 		for _, s := range VehicleStatusList {
// 			client := app.Login()
// 			fmt.Println(s.ID)
// 			app.GetVehicleHistoryData(s.ID, client)
// 			time.Sleep(time.Second * 20)
// 			//fmt.Printf("%s Cooridinates %v", s.ID, AllCoordinates[s.ID][0:5])
// 		}
// 	}
// }

type MileageStruct struct {
	VehiclePlateNo string `json:"VehiclePlateNo"`
	StartTime      string `json:"StartTime"`
	EndTime        string `json:"EndTime"`
	VehicleID      string
}

// func CalculateDistanceWorker() {
// 	var Trips []Models.TripStruct
// 	if err := Models.DB.Model(&Models.TripStruct{}).Where("is_closed = ?", true).Where("mileage = 0").Find(&Trips).Error; err != nil {
// 		log.Println(err.Error())
// 	}
// 	for _, trip := range Trips {
// 		var truckID string
// 		for _, vehicle := range VehicleStatusList {
// 			if vehicle.PlateNo == trip.CarNoPlate {
// 				truckID = vehicle.ID
// 			}
// 		}
// 		feeRate, mileage, err := GetFeeRate(MileageStruct{VehiclePlateNo: trip.CarNoPlate, StartTime: trip.StartTime, EndTime: trip.EndTime, VehicleID: truckID})
// 		if err != nil {
// 			log.Println(err.Error())
// 		}
// 		trip.FeeRate = feeRate
// 		trip.Route.Mileage = mileage
// 		if err := Models.DB.Save(&trip).Error; err != nil {
// 			log.Println(err.Error())
// 		}
// 		time.Sleep(time.Second * 10)
// 	}
// }

func GetVehicleMileageHistory(c *fiber.Ctx) error {
	if err := app.GetCurrentLocationData(GlobalClient); err != nil {
		var loginErr error
		GlobalClient, loginErr = app.Login()
		if loginErr != nil {
			log.Println(err.Error())
			return err
		}
		app.GetCurrentLocationData(GlobalClient)
	}
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
	for _, s := range VehicleStatusList {
		if s.PlateNo == data.VehiclePlateNo {
			data.VehicleID = s.ID
		}
	}
	feeRate, mileage, err := GetFeeRate(data)
	if err != nil {
		log.Println(err.Error())
		return err
	}
	return c.JSON(fiber.Map{
		"Fee":     feeRate,
		"mileage": mileage,
	})
}

type Jar struct {
	lk      sync.Mutex
	cookies map[string][]*http.Cookie
}

func NewJar() *Jar {
	jar := new(Jar)
	jar.cookies = make(map[string][]*http.Cookie)
	return jar
}

func (jar *Jar) SetCookies(u *url.URL, cookies []*http.Cookie) {
	jar.lk.Lock()
	jar.cookies[u.Host] = cookies
	jar.lk.Unlock()
}

func (jar *Jar) Cookies(u *url.URL) []*http.Cookie {
	return jar.cookies[u.Host]
}

func trimLeftChars(s string, n int) string {
	m := 0
	for i := range s {
		if m >= n {
			return s[i:]
		}
		m++
	}
	return s[:0]
}

func GetFeeRate(data MileageStruct) (float64, float64, error) {
	GlobalClient, _ = app.Login()
	app.GetCurrentLocationData(GlobalClient)
	// reqString := fmt.Sprintf("https://fms-gps.etit-eg.com/WebPages/GetHistoryTripSummary.ashx?id=%s&time=6&from=%s&to=%s", data.VehicleID, "11/1/2022%2000:00:00", "11/1/2022%2023:59:59")
	reqString := fmt.Sprintf("https://fms-gps.etit-eg.com/WebPages/GetHistoryTripSummary.ashx?id=%s&time=6&from=%s&to=%s", data.VehicleID, data.StartTime, data.EndTime)
	GlobalClient.Request("GET", "https://fms-gps.etit-eg.com", nil, nil, http.Header{})
	cookies := GlobalClient.Cookies("https://fms-gps.etit-eg.com")
	req, _ := http.NewRequest("GET", reqString, nil)
	req.Header.Set("Cookie", fmt.Sprintf("%s;", cookies[4]))
	res, err := app.Client.Do(req)
	if err != nil {
		log.Println(err.Error())
		return 0, 0, err
	}
	defer res.Body.Close()
	buf, err := io.ReadAll(res.Body)
	if err != nil {
		log.Println(err.Error())
		return 0, 0, err
	}
	jsonData, err := json.Marshal(fmt.Sprintf("%s", buf))
	if err != nil {
		log.Println(err.Error())
		return 0, 0, err
	}
	var jsonString string
	err = json.Unmarshal(jsonData, &jsonString)
	if err != nil {
		log.Println(err.Error())
		return 0, 0, err
	}
	jsonString = trimLeftChars(jsonString, 13)
	stringLen := len(jsonString)
	fmt.Println(stringLen)
	if len(jsonString) > 0 {
		jsonString = jsonString[:len(jsonString)-5]
	} else {
		return 0, 0, err
	}

	// jsonString = strings.Trim(jsonString, ", ")
	jsonString = jsonString + "\n}"
	fmt.Println(jsonString)
	// fmt.Println(jsonString)
	var unMarshalledData struct {
		TotalMilage string `json:"TotalMileage"`
	}
	err = json.Unmarshal([]byte(jsonString), &unMarshalledData)
	if err != nil {
		log.Println(err.Error())
		return 0, 0, err
	}
	// err = json.NewDecoder(res.Body).Decode(&unMarshalledData)
	if err != nil {
		log.Println(err.Error())
		return 0, 0, err
	}
	fmt.Println(unMarshalledData.TotalMilage)
	mileage, err := strconv.ParseFloat(unMarshalledData.TotalMilage, 64)
	if err != nil {
		log.Println(err.Error())
	}
	if mileage == 0 {
		GlobalClient, err = app.Login()
		if err != nil {
			return 0, 0, err
		}
		return GetFeeRate(data)
	}
	feeRate := GetFeeFromMilage(mileage)

	return feeRate, mileage, nil
}

func GetFeeFromMilage(mileage float64) float64 {
	if mileage > 0 {
		if mileage <= 100 {
			return 76
		} else if mileage <= 150 {
			return 91
		} else if mileage <= 200 {
			return 107
		} else if mileage <= 250 {
			return 122
		} else if mileage <= 300 {
			return 138
		} else if mileage <= 350 {
			return 154
		} else if mileage <= 400 {
			return 169
		} else if mileage <= 450 {
			return 185
		} else if mileage <= 500 {
			return 200
		} else if mileage <= 550 {
			return 216
		} else if mileage <= 600 {
			return 268
		} else if mileage <= 650 {
			return 283
		} else if mileage <= 700 {
			return 299
		} else if mileage <= 750 {
			return 350
		} else if mileage <= 800 {
			return 366
		} else if mileage <= 850 {
			return 418
		} else if mileage <= 900 {
			return 433
		} else {
			return 485
		}
	}
	return 0
}
