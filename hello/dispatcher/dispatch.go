package dispatcher

import (
	"encoding/json"
	"fmt"
	"hello/handler"
	"hello/msg"
	"log"

	"github.com/astaxie/beego/orm"
	"github.com/gorilla/websocket"
)

type Code struct {
	Code string
}

func Dispatch(messageType int, message []byte, connection *websocket.Conn, ormManager orm.Ormer) {
	var code Code
	err := json.Unmarshal(message, &code)
	if err != nil {
		log.Print(err)
		return
	}
	fmt.Printf("%-8s: %s %4s %s\n\n", "receive", string(message), "from", connection.RemoteAddr())

	switch code.Code {

	case msg.LoginMsg:
		go handler.HandleLoginMsg(messageType, message, connection, code.Code, ormManager)
	case msg.SignUpMsg:
		go handler.HandleSignUpMsg(messageType, message, connection, code.Code, ormManager)
	case msg.EnterRoomMsg:
		go handler.HandleEnterRoomMsg(messageType, message, connection, code.Code, ormManager)
	case msg.ReadyMsg:
		go handler.HandleReadyMsg(messageType, message, connection, code.Code, ormManager)
	case msg.BidMsg:
		go handler.HandleBidMsg(messageType, message, connection, code.Code, ormManager)
	case msg.BuyStockMsg:
		go handler.HandleBuyStockMsg(messageType, message, connection, code.Code, ormManager)
	case msg.PutBoatMsg:
		go handler.HandlePutBoatMsg(messageType, message, connection, code.Code, ormManager)
	case msg.DragBoatMsg:
		go handler.HandleDragBoatMsg(messageType, message, connection, code.Code, ormManager)
	case msg.InvestMsg:
		go handler.HandleInvestMsg(messageType, message, connection, code.Code, ormManager)
	case msg.PirateMsg:
		go handler.HandlePirateMsg(messageType, message, connection, code.Code, ormManager)
	case msg.DecideTickFailMsg:
		go handler.HandleDecideTickFailMsg(messageType, message, connection, code.Code, ormManager)
	default:
		go handler.HandleErrors(messageType, message, connection, code.Code, ormManager)
	}

}

func ClearState(ip string, connection *websocket.Conn, ormManager orm.Ormer) {
	go handler.ClearState(ip, connection, ormManager)
}
