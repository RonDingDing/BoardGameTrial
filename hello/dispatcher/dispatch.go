package dispatcher

import (
	"encoding/json"
	"fmt"
	"hello/handler"
	"hello/msg"

	"github.com/gorilla/websocket"
)

type Code struct {
	Code string
}

func Dispatch(messageType int, message []byte, connection *websocket.Conn, errorChannel chan error) error {
	var code Code
	err := json.Unmarshal(message, &code)
	if err != nil {
		return err
	}
	fmt.Printf("%-8s: %s %4s %s\n", "receive", string(message), "from", connection.RemoteAddr())

	switch code.Code {

	case msg.LoginMsg:
		go handler.HandleLoginMsg(messageType, message, connection, errorChannel, code.Code)
	default:
		go handler.HandleErrors(messageType, message, connection, errorChannel, code.Code)
	}

	err2 := <-errorChannel
	return err2
}
