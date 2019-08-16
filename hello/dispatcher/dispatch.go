package dispatcher

import (
	"errors"
	"hello/msg"

	"github.com/gorilla/websocket"
)	
	
func Dispatch(code int32, msgByte []byte, connection *websocket.Conn) error {
	answer := false
	switch code {
	case msg.Bail:
		answer = handleBail(msgByte, connection)
    }
	if answer == false {
		return errors.New("No handler for this type of message")
	}
	return nil
}

func handleBail(msgByte []byte, connection *websocket.Conn) bool {
	
	return true
}		
