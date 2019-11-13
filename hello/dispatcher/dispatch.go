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
		go handler.HandleLoginMsg(message, connection, ormManager)
	case msg.SignUpMsg:
		go handler.HandleSignUpMsg(message, connection, ormManager)
	case msg.EnterRoomMsg:
		go handler.HandleEnterRoomMsg(message, connection, ormManager)
	case msg.ReadyMsg:
		go handler.HandleReadyMsg(message, connection, ormManager)
	case msg.BidMsg:
		go handler.HandleBidMsg(message, connection, ormManager)
	case msg.BuyStockMsg:
		go handler.HandleBuyStockMsg(message, connection, ormManager)
	case msg.PutBoatMsg:
		go handler.HandlePutBoatMsg(message, connection, ormManager)
	case msg.DragBoatMsg:
		go handler.HandleDragBoatMsg(message, connection, ormManager)
	case msg.InvestMsg:
		go handler.HandleInvestMsg(message, connection, ormManager)
	case msg.PirateMsg:
		go handler.HandlePirateMsg(message, connection, ormManager)
	case msg.DecideTickFailMsg:
		go handler.HandleDecideTickFailMsg(message, connection, ormManager)
	case msg.PostDragMsg:
		go handler.HandlePostDragMsg(message, connection, ormManager)
	default:
		go handler.HandleErrors(message, connection, code.Code, ormManager)
	}

}

func ClearState(ip string, connection *websocket.Conn, ormManager orm.Ormer) {
	go handler.ClearState(ip, connection, ormManager)
}
