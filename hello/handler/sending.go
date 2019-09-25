package handler

import (
	"encoding/json"
	"hello/global"
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
	log.Printf("%-8s: %s %4s %s\n\n", "written", string(messageReturn), "to", connection.RemoteAddr())
	if err != nil {
		log.Print(err)
		return
	}
}

func RoomBroadcastMessage(messageType int, messageObj interface{}, roomNum int) {
	messageReturn, err := json.Marshal(messageObj)
	if err != nil {
		log.Print(err)
		return
	}
	manila, base := global.FindRoomByNum(roomNum)
	if manila != nil {
		for _, connection := range manila.GetAllConnections() {
			err = connection.WriteMessage(messageType, messageReturn)
			log.Printf("%-8s: %s %4s %s\n\n", "castroom", string(messageReturn), "to", connection.RemoteAddr())
			if err != nil {
				log.Print(err)
				return
			}
		}
	} else if base != nil {
		for _, connection := range base.GetAllConnections() {
			err = connection.WriteMessage(messageType, messageReturn)
			log.Printf("%-8s: %s %4s %s\n\n", "castroom", string(messageReturn), "to", connection.RemoteAddr())
			if err != nil {
				log.Print(err)
				return
			}
		}
	} else {
		log.Println("Nil!")
	}
}
