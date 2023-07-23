package FiberConfig

import (
	"Falcon/Apis"
	"Falcon/Controllers"
	"Falcon/ManipulateData"
	"Falcon/Notifications"
	"Falcon/PreviewData"
	"Falcon/Scrapper"
	"Falcon/middleware"
	"fmt"
	"time"

	// "log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/template/html"
	// "github.com/gofiber/websocket/v2"
)

func FiberConfig() {
	fmt.Println("Server Up...")
	engine := html.New("./Templates", ".html")
	// Html Template engine
	app := fiber.New(fiber.Config{
		Views: engine,
	})
	app.Use(cors.New())
	app.Post("/api/RegisterUser", Controllers.RegisterUser)
	app.Post("/api/RegisterCar", Apis.RegisterCar)
	app.Post("/api/RegisterTransporter", Apis.RegisterTransporter)
	app.Post("/api/Login", Controllers.Login)
	app.Use("/api/User", Controllers.User)
	app.Use("/api/Logout", Controllers.Logout)

	// app.Get("/ShowAllServiceEvents", adaptor.HTTPHandlerFunc(PreviewData.ShowAllServiceEvents))
	app.Post("/api/removedata", (ManipulateData.DeleteData))
	app.Post("/api/editdata", (ManipulateData.EditData))
	app.Post("/api/CreateCarTrip", Apis.CreateCarTrip)
	app.Post("/api/EditCarTrip", Apis.EditCarTrip)
	app.Post("/api/GenerateCSVTable", Apis.GenerateTripsExcelTable)
	//app.Post("/api/GetDriverTrip", Controllers.GetDriverTrip)
	app.Post("/api/NextStep", Controllers.NextStep)
	app.Post("/api/PreviousStep", Controllers.PreviousStep)
	app.Post("/api/CompleteTrip", Controllers.CompleteTrip)
	app.Post("/api/GetCars", Apis.GetCars)
	app.Post("/api/GetDrivers", Apis.GetDrivers)
	app.Post("/api/GetTransporters", Apis.GetTransporters)
	app.Use("/api/GetCarProfileData", Apis.GetCarProfileData)
	app.Use("/api/GetDriverProfileData", Apis.GetDriverProfileData)
	app.Use("/api/GetTransporterProfileData", Apis.GetTransporterProfileData)
	app.Post("/api/DeleteDriver", Apis.DeleteDriver)
	app.Post("/api/DeleteCar", Apis.DeleteCar)
	app.Post("/api/UpdateCar", Apis.UpdateCar)
	app.Post("/api/EditTransporter", Apis.EditTransporter)
	app.Post("/api/DeleteCarTrip", Apis.DeleteCarTrip)
	app.Use("/api/GetPendingRequests", Apis.GetPendingRequests)
	app.Post("/api/ApproveRequest", Apis.ApproveRequest)
	app.Post("/api/RejectRequest", Apis.RejectRequest)
	app.Post("/api/UpdateTempPermission", Apis.UpdateTempPermission)
	app.Use("/api/GetNonDriverUsers", Apis.GetNonDriverUsers)
	// app.Use("/AddServiceEvent", adaptor.HTTPHandlerFunc(AddEvent.AddServiceEventTmpl))
	app.Post("/api/CreateServiceEvent", Apis.CreateServiceEvent)
	app.Post("/api/EditServiceEvent", Apis.EditServiceEvent)
	app.Post("/api/DeleteServiceEvent", Apis.DeleteServiceEvent)
	app.Get("/api/GetAllServiceEvents", Apis.GetAllServiceEvents)
	app.Use("/api/GetVehicleStatus", Apis.GetVehicleStatus)
	app.Use("/api/GetVehicleMapPoints", Apis.GetVehicleMapPoints)
	app.Use("/api/GetVehicleMilage", Scrapper.GetVehicleMileageHistory)
	app.Get("/api/GetLocations", Apis.GetLocations)

	app.Use("/api/GetNotifications", Notifications.ReturnNotifications)
	protectedApis := app.Group("/api/protected/", middleware.Verify)
	protectedApis.Post("/CreateLocation/", Apis.CreateLocation)
	protectedApis.Post("/CreateTerminal/", Apis.CreateTerminal)
	protectedApis.Post("/GetRouteHistory", Scrapper.GetVehicleRouteHistory)
	protectedApis.Post("/GetTripRouteHistory", Scrapper.GetTripRouteHistory)
	protectedApis.Post("/GetPhotoAlbum", Apis.GetPhotoAlbum)
	protectedApis.Post("/RegisterDriver", Controllers.RegisterDriver)
	protectedApis.Post("/UpdateDriver", Controllers.UpdateDriver)
	//protectedApis.Use(middleware.Verify)
	protectedApis.Post("/AddFuelEvent", Apis.AddFuelEvent)
	protectedApis.Post("/EditFuelEvent", Apis.EditFuelEvent)
	protectedApis.Post("/DeleteFuelEvent", Apis.DeleteFuelEvent)
	protectedApis.Get("/GetFuelEvents", Apis.GetFuelEvents)
	protectedApis.Post("/GenerateFuelTable", Apis.GenerateFuelEventsExcelTable)
	protectedApis.Post("/GenerateReceipt", Apis.GenerateReceipt)
	// app.Post("/api/GenerateReceipt", Apis.GenerateCSVReceipt)
	// app.Use("/api/AddCar", AddEvent.AddCarHandler)
	// app.Use("/api/AddServiceEvent", AddEvent.AddCarHandler)
	app.Use("/ShowAllDeliveries", PreviewData.ShowAllDailyDeliveries)
	app.Use("/GetProgressOfCars", Apis.GetProgressOfCars)
	// Serve Static Images
	app.Static("/CarLicenses", "./CarLicenses", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/CarLicensesBack", "./CarLicensesBack", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/CalibrationLicenses", "./CalibrationLicenses", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/CalibrationLicensesBack", "./CalibrationLicensesBack", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/DriverLicenses", "./DriverLicenses", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/SafetyLicenses", "./SafetyLicenses", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/DrugTests", "./DrugTests", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/CriminalRecords", "./CriminalRecords", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/IDLicenses", "./IDLicenses", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/IDLicensesBack", "./IDLicensesBack", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/TankLicenses", "./TankLicenses", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/TankLicensesBack", "./TankLicensesBack", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	app.Static("/ServiceProofs", "./ServiceProofs", fiber.Static{Compress: true, CacheDuration: time.Second * 10})
	// WebSocket
	// app.Use("/ws", func(c *fiber.Ctx) error {
	// 	// IsWebSocketUpgrade returns true if the client
	// 	// requested upgrade to the WebSocket protocol.
	// 	if websocket.IsWebSocketUpgrade(c) {
	// 		c.Locals("allowed", true)
	// 		return c.Next()
	// 	}
	// 	return fiber.ErrUpgradeRequired
	// })

	// app.Get("/api/ws/", websocket.New(func(c *websocket.Conn) {
	// 	// c.Locals is added to the *websocket.Conn
	// 	log.Println(c.Locals("allowed")) // true

	// 	// websocket.Conn bindings https://pkg.go.dev/github.com/fasthttp/websocket?tab=doc#pkg-index
	// 	var (
	// 		mt  int
	// 		msg []byte
	// 		err error
	// 	)

	// 	for {
	// 		if mt, msg, err = c.ReadMessage(); err != nil {
	// 			log.Println("read:", err)
	// 			break
	// 		}
	// 		log.Printf("recv: %s", msg)

	// 		if err = c.WriteMessage(mt, msg); err != nil {
	// 			log.Println("write:", err)
	// 			break
	// 		}
	// 	}

	// }))
	// app.ListenTLS(":3001", "selfsigned.crt", "selfsigned.key")
	app.Listen(":3001")
}
