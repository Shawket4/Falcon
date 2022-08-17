package Database

import (
	"Falcon/Models"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() {
	connection, err := gorm.Open(mysql.Open("snap:Snapsnap@2@tcp(92.205.60.182:3306)/Falcon"), &gorm.Config{})

	if err != nil {
		panic("Could not connect to the database")
	}

	DB = connection
	// if isAdmin {
	// connection.AutoMigrate(&Models.AdminUser{})
	// } else {
	connection.AutoMigrate(&Models.User{})
	// }
}
