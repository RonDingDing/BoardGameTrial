package dispatcher

import (
	"errors"
	"hello/msg"

	"github.com/gorilla/websocket"
)	
	
func Dispatch(code int32, msgByte []byte, connection *websocket.Conn) error {
	answer := false
	switch code {
	case msg.Mail:
		answer = handleMail(msgByte, connection)
	case msg.Bail:
		answer = handleBail(msgByte, connection)
    }
	if answer == false {
		return errors.New("No handler for this type of message")
	}
	return nil
}

func handleMail(msgByte []byte, connection *websocket.Conn) bool {
	
	return true
}		

func handleBail(msgByte []byte, connection *websocket.Conn) bool {
	
	return true
}		
