package Scrapper

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"strconv"
	"strings"
	"sync"

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
	client := app.Client

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

func (app *App) login() *colly.Collector {
	authenticityToken := app.getToken()
	client := colly.NewCollector()
	loginURL := baseURL + "/"
	data := map[string]string{
		"ScriptManager1":          "UpdatePanel1|lg_AltairLogin$LoginButton",
		"__EVENTTARGET":           "lg_AltairLogin$LoginButton",
		"__VIEWSTATE":             authenticityToken.Token,
		"__VIEWSTATEGENERATOR":    "0C2F32F0",
		"lg_AltairLogin$UserName": username,
		"lg_AltairLogin$Password": password,
	}

	client.Post(loginURL, data)

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
	}
	return client
}

var jar, _ = cookiejar.New(nil)

var app = App{
	Client: &http.Client{Jar: jar},
}

func GetVehicleData() {
	VehicleStatusListTemp = []VehicleStatusStruct{}
	app.login()
	VehicleStatusList = VehicleStatusListTemp
}

type MilageStruct struct {
	VehiclePlateNo string `json:"VehiclePlateNo"`
	DateFrom       string `json:"DateFrom"`
	DateTo         string `json:"DateTo"`
	VehicleID      string
}

func GetVehicleMilageHistory(c *fiber.Ctx) error {
	var data MilageStruct
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
			fmt.Println("d")
			data.VehicleID = s.ID
		}
	}
	milage := app.getMilage(data)
	return c.JSON(milage)
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

func (app *App) getMilage(data MilageStruct) float64 {
	jar := NewJar()
	client := http.Client{Jar: jar}
	authenticityToken := app.getToken()
	loginURL := baseURL + "/"
	loginData := url.Values{
		"ScriptManager1":          {"UpdatePanel1|lg_AltairLogin$LoginButton"},
		"__EVENTTARGET":           {"lg_AltairLogin$LoginButton"},
		"__VIEWSTATE":             {authenticityToken.Token},
		"__VIEWSTATEGENERATOR":    {"0C2F32F0"},
		"lg_AltairLogin$UserName": {username},
		"lg_AltairLogin$Password": {password},
	}

	resp, _ := client.PostForm(loginURL, loginData)
	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		log.Fatal(err)
	}
	doc.Find("script").Each(func(i int, s *goquery.Selection) {
		if i == 23 {
			body := s.Text()
			fmt.Println(body)
			s.Find("document").Each(func(i int, s2 *goquery.Selection) {
				fmt.Println(s2.Text())
			})
		}
	})
	// fmt.Println()
	resp.Body.Close()

	resp, _ = client.Get("https://fms-gps.etit-eg.com/WebPages/GetHistoryTripSummary.ashx?from=9%2F9%2F2022+00%3A00%3A00&id=cd482774-6ba0-e811-80de-0025b500010d&time=6&to=9%2F9%2F2022+23%3A59%3A59")

	b, _ := ioutil.ReadAll(resp.Body)
	resp.Body.Close()

	fmt.Println(string(b))
	fmt.Println(jar)
	return 2
}

// func (app *App) getMilage(data MilageStruct) float64 {
// 	authenticityToken := app.getToken()
// 	client := colly.NewCollector()
// 	loginURL := baseURL + "/"
// 	loginData := map[string]string{
// 		"ScriptManager1":          "UpdatePanel1|lg_AltairLogin$LoginButton",
// 		"__EVENTTARGET":           "lg_AltairLogin$LoginButton",
// 		"__VIEWSTATE":             authenticityToken.Token,
// 		"__VIEWSTATEGENERATOR":    "0C2F32F0",
// 		"lg_AltairLogin$UserName": username,
// 		"lg_AltairLogin$Password": password,
// 	}
// 	// loginData := map[string]string{
// 	// 	"ScriptManager1":  "UpdatePanel1|lg_AltairLogin$LoginButton",
// 	// 	"__EVENTTARGET":   "lg_AltairLogin$LoginButton",
// 	// 	"__EVENTARGUMENT": "",
// 	// 	"lg_AltairLogin_RadW_SendEmail_ClientState": "",
// 	// 	"TokenWindow$C$txt_token":                   "",
// 	// 	"TokenWindow_ClientState":                   "",
// 	// 	"NotAuthorizedWindow_ClientState":           "",
// 	// 	"RadWindowManager2_ClientState":             "",
// 	// 	"__ASYNCPOST":                               "true",
// 	// 	"RadAJAXControlID":                          "RadAjaxManager1",
// 	// 	"__VIEWSTATE":                               authenticityToken.Token,
// 	// 	"__VIEWSTATEGENERATOR":                      "0C2F32F0",
// 	// 	"lg_AltairLogin$UserName":                   username,
// 	// 	"lg_AltairLogin$Password":                   password,
// 	// }
// 	loginData2 := url.Values{
// 		"ScriptManager1":          {"UpdatePanel1|lg_AltairLogin$LoginButton"},
// 		"__EVENTTARGET":           {"lg_AltairLogin$LoginButton"},
// 		"__VIEWSTATE":             {authenticityToken.Token},
// 		"__VIEWSTATEGENERATOR":    {"0C2F32F0"},
// 		"lg_AltairLogin$UserName": {username},
// 		"lg_AltairLogin$Password": {password},
// 	}
// 	var siteCookies []*http.Cookie

// 	var siteCookiesString string
// 	client.OnResponse(func(r *colly.Response) {
// 		siteCookies = client.Cookies(r.Request.URL.String())
// 		for i, s := range siteCookies {
// 			if i+1 == len(siteCookies) {
// 				siteCookiesString += fmt.Sprintf("%s=%s", s.Name, s.Value)
// 			} else {

// 				siteCookiesString += fmt.Sprintf("%s=%s; ", s.Name, s.Value)
// 			}
// 		}
// 	})
// 	client.Post(loginURL, loginData)
// 	client.Wait()
// 	// client.OnResponse(func(r *colly.Response) {
// 	// 	jsonResponse := string(r.Body)
// 	// 	fmt.Println(jsonResponse)
// 	// })
// 	// client.OnXML("body", func(x *colly.XMLElement) {
// 	// 	fmt.Println(x.Response.Body)
// 	// })
// 	// client.OnResponse(func(r *colly.Response) {
// 	// 	fmt.Println(string(r.Body))
// 	// })
// 	fmt.Println(data)
// 	// pageUrl := fmt.Sprintf("https://fms-gps.etit-eg.com/WebPages/GetHistoryTripSummary.ashx?id=%s&time=6&from=%s&to=%s", data.VehicleID, data.DateFrom, data.DateTo)
// 	pageUrl := "https://fms-gps.etit-eg.com/WebPages/GetHistoryTripSummary.ashx"
// 	// pageUrl = url.QueryEscape()
// 	fmt.Println(pageUrl)
// 	// type ReqStruct map[string]string
// 	// reqData := ReqStruct{
// 	// "id":   data.VehicleID,
// 	// "time": "6",
// 	// "from": data.DateFrom,
// 	// "to":   data.DateTo,
// 	// 	// "t":    "1662460189973",
// 	// }
// 	reqData := url.Values{
// 		"id":   {data.VehicleID},
// 		"time": {"6"},
// 		"from": {data.DateFrom},
// 		"to":   {data.DateTo},
// 	}
// 	fmt.Println(pageUrl + "?" + reqData.Encode())
// 	// jsonData, err := json.Marshal(reqData)
// 	// if err != nil {
// 	// 	log.Fatal(err)
// 	// }
// 	// reader := bytes.NewReader(jsonData)
// 	// _ = reader

// 	// // err = client.Request("GET", pageUrl, reader, nil, http.Header{"Content-Type": []string{"text/html; charset=utf-8"}})
// 	// // err = client.Visit(pageUrl)

// 	loginResponse, err := app.Client.PostForm(loginURL, loginData2)

// 	if err != nil {
// 		log.Fatalln(err)
// 	}

// 	defer loginResponse.Body.Close()

// 	// body, err := ioutil.ReadAll(loginResponse.Body)
// 	// fmt.Println(string(body))
// 	// if err != nil {
// 	// 	log.Fatalln(err)
// 	// }
// 	// client.Visit("https://fms-gps.etit-eg.com/WebPages/Maps.aspx")
// 	// err := client.Post("https://fms-gps.etit-eg.com/WebPages/Maps.aspx", nil)
// 	// if err != nil {
// 	// 	log.Println(err)
// 	// }
// 	// client.Visit("https://fms-gps.etit-eg.com/WebPages/Maps.aspx")
// 	// client.OnHTML("body", func(h *colly.HTMLElement) {
// 	// 	fmt.Println(h.Text)
// 	// })

// 	// response, err := app.Client.Get(pageUrl)

// 	// if err != nil {
// 	// 	log.Fatalln(err)
// 	// }

// 	// defer response.Body.Close()

// 	// body, err = ioutil.ReadAll(response.Body)
// 	// fmt.Println(string(body))
// 	// if err != nil {
// 	// 	log.Fatalln(err)
// 	// }
// 	// err := client.Request("GET", pageUrl, nil, nil, nil)
// 	// if err != nil {
// 	// 	log.Println(err)
// 	// }
// 	client.OnResponse(func(r *colly.Response) {
// 		for i, s := range siteCookies {
// 			if i+1 == len(siteCookies) {
// 				siteCookiesString += fmt.Sprintf("%s=%s", s.Name, s.Value)
// 			} else {

// 				siteCookiesString += fmt.Sprintf("%s=%s; ", s.Name, s.Value)
// 			}
// 		}
// 	})
// 	err = client.Request("GET", "https://fms-gps.etit-eg.com/WebPages/UpdateTransportersData.aspx", nil, nil, http.Header{"Content-Type": []string{"text/html; charset=utf-8"}})
// 	if err != nil {
// 		log.Println(err)
// 	}
// 	client.Wait()
// 	// client.Visit("https://etit-fms.etit-eg.com/WebPages/Transporters/List.aspx")
// 	client.OnRequest(func(r *colly.Request) {

// 		// client.SetCookies(pageUrl, siteCookies)
// 		r.Headers.Set("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9")
// 		r.Headers.Set("Accept-Encoding", "gzip, deflate, br")
// 		r.Headers.Set("Accept-Language", "en-US,en;q=0.9")
// 		r.Headers.Set("Cache-Control", "max-age=0")
// 		r.Headers.Set("Connection", "keep-alive")
// 		r.Headers.Set("Cookie", siteCookiesString)
// 		fmt.Println(siteCookies)
// 		// r.Headers.Set("SSOCookie", siteCookies[1].Value)
// 		// r.Headers.Set("SSOPCookie", siteCookies[2].Value)
// 		// r.Headers.Set("Token", siteCookies[3].Value)
// 		// fmt.Println(siteCookies)
// 		// fmt.Println(r.Headers.Values("Cookie"))
// 	})

// 	// client.Wait()
// 	// client.OnHTML("body", func(h *colly.HTMLElement) {
// 	// 	fmt.Println(h.Text)
// 	// })
// 	client.OnResponse(func(r *colly.Response) {
// 		fmt.Println(string(r.Body))
// 	})
// 	client.Visit(pageUrl)
// 	client.Wait()

// 	return 2
// }
