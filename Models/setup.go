package Models

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() {
	if err := godotenv.Load(".env"); err != nil {
		log.Fatalf("Error loading .env file")
	}

	DbHost := os.Getenv("DB_HOST")
	DbUser := os.Getenv("DB_USER")
	DbPassword := os.Getenv("DB_PASSWORD")
	DbName := os.Getenv("DB_NAME")
	DbPort := os.Getenv("DB_PORT")

	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable", DbHost, DbUser, DbPassword, DbName, DbPort)
	// connection, err := gorm.Open(postgres.Open("snap:Snapsnap@2@tcp(92.205.60.182:3306)/Falcon?parseTime=true"), &gorm.Config{})
	fmt.Println(dsn)
	connection, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	DB = connection
	if err != nil {
		log.Println(err)
	}
	// DB = connection
	// if isAdmin {
	// connection.AutoMigrate(&Models.AdminUser{})
	// } else {
	connection.AutoMigrate(&User{})
	connection.AutoMigrate(&FuelEvent{})
	connection.AutoMigrate(&Driver{})
	connection.AutoMigrate(&Service{})
	connection.AutoMigrate(&Car{})
	connection.AutoMigrate(&TripStruct{})
	connection.AutoMigrate(&Location{})
	connection.AutoMigrate(&Terminal{})
	// }

}
