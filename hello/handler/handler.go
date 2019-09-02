package handler

import (
	"fmt"

	"github.com/gorilla/websocket"
)

func HandleBail(messageType int, message []byte, connection *websocket.Conn, errorChannel chan error) {
	err := connection.WriteMessage(messageType, message)
	fmt.Printf("%-8s: %s\n", "written", string(message))
	errorChannel <- err
}
