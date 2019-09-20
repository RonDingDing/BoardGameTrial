package handler

import (
	"encoding/json"
	"log"

	"github.com/gorilla/websocket"
)

func SendMessage(messageType int, messageObj interface{}, connection *websocket.Conn) {
	messageReturn, err := json.Marshal(messageObj)
	if err != nil {
		log.Print(err)
		return
	}
	err = connection.WriteMessage(messageType, []byte(messageReturn))
	log.Printf("%-8s: %s %4s %s\n", "written", string(messageReturn), "to", connection.RemoteAddr())
	if err != nil {
		log.Print(err)
		return
	}
}

// func RoomBroadcastMessage(messageType int, messageObj interface{}, iroom baseroom.IRoom) {
// 	messageReturn, err := json.Marshal(messageObj)
// 	if err != nil {
// 		log.Print(err)
// 		return
// 	}
// 	for _, connection := range iroom.GetAllConnections() {
// 		err = connection.WriteMessage(messageType, messageReturn)
// 		log.Printf("%-8s: %s %4s %s\n", "written", string(messageReturn), "to", connection.RemoteAddr())
// 		if err != nil {
// 			log.Print(err)
// 			return
// 		}
// 	}
// }
