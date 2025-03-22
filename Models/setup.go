package Models

import (
	"Falcon/AbstractFunctions"
	"encoding/json"
	"fmt"
	"log"
	"strconv"

	"github.com/360EntSecGroup-Skylar/excelize"

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
	connection.AutoMigrate(&Truck{}, &Tire{}, &TirePosition{})
	connection.AutoMigrate(&User{}, &FuelEvent{}, &Driver{}, &Service{}, &TripStruct{}, &Location{}, &Terminal{}, &OilChange{})
	connection.AutoMigrate(&Expense{}, &Loan{})
	connection.AutoMigrate(&LandMark{})
	connection.AutoMigrate(&FeeMapping{})
	// var admin User
	// admin.Email = "Apex"
	// passwordByte, _ := bcrypt.GenerateFromPassword([]byte("123456"), bcrypt.DefaultCost)
	// admin.Password = passwordByte
	// admin.Permission = 2
	// admin.Name = "Apex"
	// admin.IsApproved = 1
	if err != nil {
		log.Println(err)
	}
	// connection.Save(&admin)
	// var location Location
	// location.Name = "جحدم"
	// connection.Save(&location)
	// var terminal Terminal
	// terminal.Name = "قنا"
	// connection.Save(&terminal)
	// DB = connection
	// if isAdmin {
	// 	connection.AutoMigrate(&AdminUser{})
	// } else {

	// }
	// SetupCars()
}

func CreateDefaultPositions(db *gorm.DB, truckID uint) error {
	positions := []TirePosition{
		// Steering positions (2)
		{TruckID: truckID, PositionType: "steering", PositionIndex: 1, Side: "left"},
		{TruckID: truckID, PositionType: "steering", PositionIndex: 2, Side: "right"},

		// Head axle 1 positions (4) - Properly ordered
		{TruckID: truckID, PositionType: "head_axle_1", PositionIndex: 1, Side: "left"},        // Outer Left
		{TruckID: truckID, PositionType: "head_axle_1", PositionIndex: 2, Side: "inner_left"},  // Inner Left
		{TruckID: truckID, PositionType: "head_axle_1", PositionIndex: 3, Side: "inner_right"}, // Inner Right
		{TruckID: truckID, PositionType: "head_axle_1", PositionIndex: 4, Side: "right"},       // Outer Right

		// Head axle 2 positions (4) - Properly ordered
		{TruckID: truckID, PositionType: "head_axle_2", PositionIndex: 1, Side: "left"},        // Outer Left
		{TruckID: truckID, PositionType: "head_axle_2", PositionIndex: 2, Side: "inner_left"},  // Inner Left
		{TruckID: truckID, PositionType: "head_axle_2", PositionIndex: 3, Side: "inner_right"}, // Inner Right
		{TruckID: truckID, PositionType: "head_axle_2", PositionIndex: 4, Side: "right"},       // Outer Right

		// Trailer axle 1 positions - Properly ordered
		{TruckID: truckID, PositionType: "trailer_axle_1", PositionIndex: 1, Side: "left"},        // Outer Left
		{TruckID: truckID, PositionType: "trailer_axle_1", PositionIndex: 2, Side: "inner_left"},  // Inner Left
		{TruckID: truckID, PositionType: "trailer_axle_1", PositionIndex: 3, Side: "inner_right"}, // Inner Right
		{TruckID: truckID, PositionType: "trailer_axle_1", PositionIndex: 4, Side: "right"},       // Outer Right

		// Trailer axle 2 positions - Properly ordered
		{TruckID: truckID, PositionType: "trailer_axle_2", PositionIndex: 1, Side: "left"},        // Outer Left
		{TruckID: truckID, PositionType: "trailer_axle_2", PositionIndex: 2, Side: "inner_left"},  // Inner Left
		{TruckID: truckID, PositionType: "trailer_axle_2", PositionIndex: 3, Side: "inner_right"}, // Inner Right
		{TruckID: truckID, PositionType: "trailer_axle_2", PositionIndex: 4, Side: "right"},       // Outer Right

		// Trailer axle 3 positions - Properly ordered
		{TruckID: truckID, PositionType: "trailer_axle_3", PositionIndex: 1, Side: "left"},        // Outer Left
		{TruckID: truckID, PositionType: "trailer_axle_3", PositionIndex: 2, Side: "inner_left"},  // Inner Left
		{TruckID: truckID, PositionType: "trailer_axle_3", PositionIndex: 3, Side: "inner_right"}, // Inner Right
		{TruckID: truckID, PositionType: "trailer_axle_3", PositionIndex: 4, Side: "right"},       // Outer Right

		// Trailer axle 4 positions - Properly ordered
		{TruckID: truckID, PositionType: "trailer_axle_4", PositionIndex: 1, Side: "left"},        // Outer Left
		{TruckID: truckID, PositionType: "trailer_axle_4", PositionIndex: 2, Side: "inner_left"},  // Inner Left
		{TruckID: truckID, PositionType: "trailer_axle_4", PositionIndex: 3, Side: "inner_right"}, // Inner Right
		{TruckID: truckID, PositionType: "trailer_axle_4", PositionIndex: 4, Side: "right"},       // Outer Right

		// Spare positions (2)
		{TruckID: truckID, PositionType: "spare", PositionIndex: 1, Side: "none"},
		{TruckID: truckID, PositionType: "spare", PositionIndex: 2, Side: "none"},
	}

	result := db.Create(&positions)
	return result.Error
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
	if err := DB.Create(&Cars).Error; err != nil {
		panic(err)
	}
}
