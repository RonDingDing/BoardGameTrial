package handler

import (
	"encoding/json"
	"hello/pb3"
	"log"

	"github.com/gorilla/websocket"
)

func HandleErrors(messageType int, message []byte, connection *websocket.Conn, errorChannel chan error, code string) {
	errObj := pb3.Errors{Code: code, Msg: "No handler for code " + code}
	errStr, err := json.Marshal(errObj)
	err = connection.WriteMessage(messageType, []byte(errStr))
	log.Printf("%-8s: %s\n", "WrittenError", string(errStr))
	errorChannel <- err
}

func HandleLoginMsg(messageType int, message []byte, connection *websocket.Conn, errorChannel chan error, code string) {
	err := connection.WriteMessage(messageType, message)
	log.Printf("%-8s: %s %4s %s\n", "written", string(message), "to", connection.RemoteAddr())
	errorChannel <- err
}
