package Models

import (
	"Falcon/AbstractFunctions"
	"encoding/json"
	"fmt"
	"log"
	"strconv"

	"github.com/360EntSecGroup-Skylar/excelize"
	"golang.org/x/crypto/bcrypt"

	// "github.com/joho/godotenv"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() {
	// if err := godotenv.Load(".env"); err != nil {
	// 	log.Fatalf("Error loading .env file")
	// }

	// DbHost := os.Getenv("DB_HOST")
	// DbUser := os.Getenv("DB_USER")
	// DbPassword := os.Getenv("DB_PASSWORD")
	// DbName := os.Getenv("DB_NAME")
	// DbPort := os.Getenv("DB_PORT")

	// dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable", DbHost, DbUser, DbPassword, DbName, DbPort)
	// connection, err := gorm.Open(postgres.Open("snap:Snapsnap@2@tcp(92.205.60.182:3306)/Falcon?parseTime=true"), &gorm.Config{})
	// connection, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	connection, err := gorm.Open(sqlite.Open("database.db"))
	DB = connection
	connection.AutoMigrate(&User{}, &FuelEvent{}, &Driver{}, &Service{}, Car{}, &TripStruct{}, &RoutePoint{}, &FinalStructResponse{}, &TripSummary{}, &Location{}, &Terminal{})
	connection.AutoMigrate(&Expense{}, &Loan{})
	var admin User
	admin.Email = "Apex"
	passwordByte, _ := bcrypt.GenerateFromPassword([]byte("123456"), bcrypt.DefaultCost)
	admin.Password = passwordByte
	admin.Permission = 2
	admin.Name = "Apex"
	admin.IsApproved = 1
	if err != nil {
		log.Println(err)
	}
	connection.Save(&admin)
	var location Location
	location.Name = "جحدم"
	connection.Save(&location)
	var terminal Terminal
	terminal.Name = "قنا"
	connection.Save(&terminal)
	DB = connection
	// if isAdmin {
	// 	connection.AutoMigrate(&AdminUser{})
	// } else {

	// }
	SetupCars()
}

func SetupCars() {
	var OldCars []Car
	if err := DB.Model(&Car{}).Find(&OldCars).Error; err != nil {
		panic(err)
	}
	DB.Delete(&OldCars)
	f, err := excelize.OpenFile("Book2.xlsx")
	if err != nil {
		fmt.Println(err)
		return
	}
	var Cars []Car
	_ = Cars
	rows := f.GetRows("Sheet1")
	for _, row := range rows {
		var car Car
		for columnIndex, data := range row {
			if columnIndex == 0 {
				car.CarNoPlate = data
			}
			if columnIndex == 1 {
				compartment1, err := strconv.Atoi(data)
				if err != nil {
					panic(err)
				}
				car.TankCapacity = compartment1
				car.Compartments = append(car.Compartments, compartment1)
			}
			if columnIndex == 2 {
				car.LicenseExpirationDate, _ = AbstractFunctions.GetFormattedDateExcel(data)
			}
			if columnIndex == 3 {
				car.CalibrationExpirationDate, _ = AbstractFunctions.GetFormattedDateExcel(data)
			}
			if columnIndex == 4 {
				car.TankLicenseExpirationDate, _ = AbstractFunctions.GetFormattedDateExcel(data)
			}
			if columnIndex == 5 {
				fmt.Println(data)
				if data == "1" {
					car.CarType = "Trailer"
				} else if data == "0" {
					car.CarType = "No Trailer"
				}
			}
		}
		car.Transporter = "Apex"

		jsonCompartments, err := json.Marshal(car.Compartments)
		car.JSONCompartments = jsonCompartments
		if err != nil {
			panic(err)
		}
		Cars = append(Cars, car)
	}
	if err := DB.Save(&Cars).Error; err != nil {
		panic(err)
	}
}
