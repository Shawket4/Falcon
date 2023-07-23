package Models

import (
	"log"

	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() {
	if err := godotenv.Load(".env"); err != nil {
		log.Fatalf("Error loading .env file")
	}

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
	connection.AutoMigrate(&User{}, &FuelEvent{}, &Driver{}, &Service{}, Car{}, &TripStruct{}, &Location{}, &Terminal{})
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
	location.Name = "KM 106"
	connection.Save(&location)
	var terminal Terminal
	terminal.Name = "Mobil Mostorod"
	connection.Save(&terminal)
	// DB = connection
	// if isAdmin {
	// connection.AutoMigrate(&Models.AdminUser{})
	// } else {

	// }
}
