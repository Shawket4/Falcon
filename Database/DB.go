package Database

import (
	"database/sql"
	"log"
)

func ConnectToDB() *sql.DB {
	db, err := sql.Open("mysql", "snap:Snapsnap@2@tcp(92.205.60.182:3306)/Falcon")
	if err != nil {
		log.Println(err)
	}
	return db
}
