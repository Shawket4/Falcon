package FiberConfig

import (
	"Falcon/AddEvent"
	"Falcon/Apis"
	"Falcon/Controllers"
	"Falcon/ManipulateData"
	"Falcon/PreviewData"
	"fmt"
	"log"

	"github.com/gofiber/adaptor/v2"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/template/html"
	"github.com/gofiber/websocket/v2"
)

func FiberConfig() {
	fmt.Println("Server Up!")
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
	app.Get("/ShowAllServiceEvents", adaptor.HTTPHandlerFunc(PreviewData.ShowAllServiceEvents))
	app.Post("/api/removedata", (ManipulateData.DeleteData))
	app.Post("/api/editdata", (ManipulateData.EditData))
	app.Post("/api/CreateCarTrip", Controllers.CreateCarTrip)
	app.Post("/api/GetDriverTrip", Controllers.GetDriverTrip)
	app.Post("/api/NextStep", Controllers.NextStep)
	app.Post("/api/PreviousStep", Controllers.PreviousStep)
	app.Post("/api/CompleteTrip", Controllers.CompleteTrip)
	app.Post("/api/GetCars", Apis.GetCars)
	app.Post("/api/GetDrivers", Apis.GetDrivers)
	app.Post("/api/GetTransporters", Apis.GetTransporters)
	app.Use("/api/GetCarProfileData", Apis.GetCarProfileData)
	app.Use("/api/GetDriverProfileData", Apis.GetDriverProfileData)
	app.Use("/api/GetTransporterProfileData", Apis.GetTransporterProfileData)
	app.Post("/api/Upload", Controllers.Upload)
	app.Post("/api/DeleteDriver", Apis.DeleteDriver)
	app.Post("/api/DeleteCar", Apis.DeleteCar)
	app.Post("/api/EditCar", Apis.EditCar)
	app.Post("/api/EditDriver", Apis.EditDriver)
	app.Post("/api/EditTransporter", Apis.EditTransporter)
	app.Post("/api/DeleteCarTrip", Apis.DeleteCarTrip)
	app.Use("/api/GetPendingRequests", Apis.GetPendingRequests)
	app.Post("/api/ApproveRequest", Apis.ApproveRequest)
	app.Post("/api/RejectRequest", Apis.RejectRequest)
	app.Post("/api/UpdateTempPermission", Apis.UpdateTempPermission)
	app.Use("/api/GetNonDriverUsers", Apis.GetNonDriverUsers)
	app.Use("/AddServiceEvent", adaptor.HTTPHandlerFunc(AddEvent.AddServiceEventTmpl))
	// app.Use("/api/AddCar", AddEvent.AddCarHandler)
	// app.Use("/api/AddServiceEvent", AddEvent.AddCarHandler)
	app.Use("/AddDailyDelivery", adaptor.HTTPHandlerFunc(AddEvent.AddDeliveryTmpl))
	app.Use("/ShowAllDeliveries", PreviewData.ShowAllDailyDeliveries)
	app.Use("/GetProgressOfCars", Apis.GetProgressOfCars)

	// WebSocket
	app.Use("/ws", func(c *fiber.Ctx) error {
		// IsWebSocketUpgrade returns true if the client
		// requested upgrade to the WebSocket protocol.
		if websocket.IsWebSocketUpgrade(c) {
			c.Locals("allowed", true)
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})

	app.Get("/api/ws/", websocket.New(func(c *websocket.Conn) {
		// c.Locals is added to the *websocket.Conn
		log.Println(c.Locals("allowed")) // true

		// websocket.Conn bindings https://pkg.go.dev/github.com/fasthttp/websocket?tab=doc#pkg-index
		var (
			mt  int
			msg []byte
			err error
		)

		for {
			if mt, msg, err = c.ReadMessage(); err != nil {
				log.Println("read:", err)
				break
			}
			log.Printf("recv: %s", msg)

			if err = c.WriteMessage(mt, msg); err != nil {
				log.Println("write:", err)
				break
			}
		}

	}))
	app.Listen(":3001")
}
