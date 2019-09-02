package dispatcher

import (
	"encoding/json"
	"errors"
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
	fmt.Println("messageType: ", messageType)
	fmt.Println("message: ", message)

	switch code.Code {
	case msg.Bail:
		go handler.HandleBail(messageType, message, connection, errorChannel)
	default:
		errStr := fmt.Sprintf("No handler for code %s.", code.Code)
		return errors.New(errStr)
	}

	err2 := <-errorChannel
	return err2
}
