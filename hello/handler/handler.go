package handler

import (
	"encoding/json"
	"hello/msg"
	"hello/pb3"
	"log"

	"github.com/gorilla/websocket"
)

func HandleErrors(messageType int, message []byte, connection *websocket.Conn, errorChannel chan error, code string) {
	errObj := pb3.Errors{Code: code, Error: msg.ErrNoHandler}
	errStr, err := json.Marshal(errObj)
	err = connection.WriteMessage(messageType, []byte(errStr))
	log.Printf("%-8s: %s\n", "WrittenError", string(errStr))
	errorChannel <- err
}

func HandleLoginMsg(messageType int, message []byte, connection *websocket.Conn, errorChannel chan error, code string) {
	loginmsg := pb3.LoginMsg{}
	loginmsg.New()
	err := json.Unmarshal(message, &loginmsg)

	// err = connection.WriteMessage(messageType, message)
	// log.Printf("%-8s: %s %4s %s\n", "written", string(loginmsg), "to", connection.RemoteAddr())
	errorChannel <- err
}
