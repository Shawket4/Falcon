package AbstractFunctions

import (
	"time"
)

// func DetectServiceMilage() {
// 	db := Database.ConnectToDB()
// 	query, err := db.Query("SELECT * FROM `ServiceEvents`")
// 	if err != nil {
// 		log.Println(err)
// 	}
// 	for query.Next() {
// 		var data Structs.Service
// 		var id int

// 		err = query.Scan(&id, &data.IsAlerted, &data.CarNoPlate, &data.ServiceType, &data.DateOfService, &data.ServiceCenter, &data.ServiceOdometerReading, &data.CurrentOdometerReading, &data.AlertAfter)
// 		if err != nil {
// 			log.Println(err)
// 		}
// 		// Convert readings to int
// 		serviceReading, err := strconv.Atoi(data.ServiceOdometerReading)
// 		if err != nil {
// 			fmt.Println(err)
// 		}
// 		currentReading, err := strconv.Atoi(data.CurrentOdometerReading)
// 		if err != nil {
// 			fmt.Println(err)
// 		}
// 		// Calculate Kilometers
// 		kilometers := currentReading - serviceReading
// 		// Convert Alertafter To int
// 		alertAfter, err := strconv.Atoi(data.AlertAfter)
// 		if err != nil {
// 			fmt.Println(err)
// 		}
// 		// Check if Service Odometer Reading is greater than Current Odometer Reading
// 		if alertAfter-kilometers <= 1000 && data.IsAlerted == 0 {
// 			// Send Email
// 			// from := "ibrahimjojo73@gmail.com"
// 			// password := "jojoibrahim21"
// 			// to := []string{"ibrahimjojo75@gmail.com"}
// 			// host := "smtp.gmail.com"
// 			// port := "587"
// 			// address := host + ":" + port
// 			// subject := fmt.Sprintf("Service Required...")
// 			// body := fmt.Sprintf("%s Service Needed For %s.", data.ServiceType, data.CarNoPlate)
// 			// message := []byte(subject + body)
// 			// auth := smtp.PlainAuth("", from, password, host)
// 			// err := smtp.SendMail(address, auth, from, to, message)
// 			// if err != nil {
// 			// 	log.Println(err)
// 			// }
// 			// Update Service Event Row
// 			m := gomail.NewMessage()
// 			m.SetHeader("From", "ibrahimjojo75@gmail.com")
// 			m.SetHeader("To", "falcon.transport.office@gmail.com")
// 			m.SetHeader("Subject", fmt.Sprintf("Service Required..."))
// 			m.SetBody("text/plain", fmt.Sprintf("%s Service Needed For %s.", data.ServiceType, data.CarNoPlate))
// 			d := gomail.NewDialer("smtp.gmail.com", 587, "ibrahimjojo75@gmail.com", "jojoibrahi")
// 			d.TLSConfig = &tls.Config{InsecureSkipVerify: true}
// 			if err := d.DialAndSend(m); err != nil {
// 				fmt.Println(err)
// 				panic(err)
// 			} else {
// 				fmt.Println("Email Sent")
// 			}
// 			query, err := db.Query(fmt.Sprintf("UPDATE `ServiceEvents` SET `IsAlerted` = %v WHERE `ServiceEvents`.`ServiceId` = %v", 1, id))
// 			if err != nil {
// 				log.Println(err)
// 			}
// 			defer query.Close()

// 			return
// 		} else if alertAfter-kilometers > 1000 {
// 			// Update Service Event Row
// 			query, err := db.Query(fmt.Sprintf("UPDATE `ServiceEvents` SET `IsAlerted` = %v WHERE `ServiceEvents`.`ServiceId` = %v", 0, id))
// 			if err != nil {
// 				log.Println(err)
// 			}
// 			defer query.Close()
// 		}
// 	}
// }

// // Handler To Detect Expiration Date From Database

// func CheckExpirationDates() {
// 	db := Database.ConnectToDB()
// 	query, err := db.Query("SELECT `DocumentExpirationDate` FROM `Documents`")
// 	if err != nil {
// 		log.Println(err)
// 	}
// 	for query.Next() {
// 		var date string
// 		err = query.Scan(&date)
// 		if err != nil {
// 			log.Println(err)
// 		}
// 		// Convert date to time
// 		t, err := time.Parse("2006-01-02", date)
// 		if err != nil {
// 			log.Println(err)
// 		}
// 		// Check if date is expired
// 		daysleft := t.Sub(time.Now()).Hours() / 24
// 		if daysleft < 20 {
// 			//Get Document Name from Database

// 			// Send Email
// 			from := "ibrahimjojo73@gmail.com"
// 			password := "jojoibrahim21"
// 			to := []string{"ibrahimjojo75@gmail.com"}
// 			host := "smtp.gmail.com"
// 			port := "587"
// 			address := host + ":" + port
// 			subject := "Document Expiring Soon..."
// 			body := "A Document Is Expiring."
// 			message := []byte(subject + body)
// 			auth := smtp.PlainAuth("", from, password, host)
// 			err := smtp.SendMail(address, auth, from, to, message)
// 			if err != nil {
// 				log.Println(err)
// 			}
// 		}
// 	}
// }

func GetFormattedDate(date string) (string, error) {
	const (
		layoutISO = "2006-01-02"
		layoutUS  = "01/02/2006"
	)
	start_date, err := time.Parse(layoutISO, date)
	if err != nil {
		return "", err
	}
	return start_date.Format(layoutUS), nil
}

func GetFormattedDateExcel(date string) (string, error) {
	parsedTime, err := time.Parse("01-02-06", date)
	if err != nil {
		return "", err
	}

	// Format the parsedTime to the desired layout "2006-01-02"
	formattedDate := parsedTime.Format("2006-01-02")

	return formattedDate, nil
}
