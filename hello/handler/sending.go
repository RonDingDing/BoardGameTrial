package handler

import (
	"encoding/json"
	"hello/baseroom"
	"hello/global"
	"hello/manila"
	"hello/pb3"
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
	manila, base := global.FindRoomByNum(roomNum)
	if manila != nil {
		RoomObjBroadcastMessage(messageType, messageObj, manila)
	} else if base != nil {
		RoomObjBroadcastMessage(messageType, messageObj, base)
	} else {
		log.Println("Nil!")
	}
}

func RoomObjBroadcastMessage(messageType int, messageObj interface{}, roomObj interface{}) {
	messageReturn, err := json.Marshal(messageObj)
	if err != nil {
		log.Print(err)
		return
	}
	switch roomObj := roomObj.(type) {
	case *baseroom.Room:
	case *manila.ManilaRoom:
		for _, connection := range roomObj.GetAllConnections() {
			err = connection.WriteMessage(messageType, messageReturn)
			log.Printf("%-8s: %s %4s %s\n\n", "castroom", string(messageReturn), "to", connection.RemoteAddr())
			if err != nil {
				log.Print(err)
				return
			}
		}
	}
}

func HelperSetRoomPropertyRoomDetail(roomdetailmsg *pb3.RoomDetailMsg, roomNum int) {
	manilaRoom, base := global.FindRoomByNum(roomNum)
	if base != nil {
		HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, base, 0)
	} else if manilaRoom != nil {
		HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, manilaRoom, 0)
	}
}

func HelperSetRoomObjPropertyRoomDetail(roomdetailmsg *pb3.RoomDetailMsg, roomObj interface{}, renderAfter float32) {
	switch room := roomObj.(type) {
	case *baseroom.Room:
		roomdetailmsg.Ans.RoomNum = 0
		roomdetailmsg.Ans.GameNum = room.GetGameNum()
		roomdetailmsg.Ans.Started = room.GetStarted()
		roomdetailmsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		roomdetailmsg.Ans.PlayerNumMax = room.GetPlayerNumMax()
		roomdetailmsg.Ans.PlayerName = room.GetPlayerName()
		roomdetailmsg.Ans.RenderAfter = renderAfter
	case *manila.ManilaRoom:
		roomdetailmsg.Ans.RoomNum = room.GetRoomNum()
		roomdetailmsg.Ans.GameNum = room.GetGameNum()
		roomdetailmsg.Ans.Started = room.GetStarted()
		roomdetailmsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		roomdetailmsg.Ans.PlayerNumMax = room.GetPlayerNumMax()
		roomdetailmsg.Ans.PlayerName = room.GetPlayerName()
		roomdetailmsg.Ans.Deck = room.GetDecks()

		roomdetailmsg.Ans.Round = room.GetRound()
		roomdetailmsg.Ans.HighestBidder = room.GetHighestBidder()
		roomdetailmsg.Ans.HighestBidPrice = room.GetHighestBidPrice()
		roomdetailmsg.Ans.CurrentPlayer = room.GetCurrentPlayer()
		roomdetailmsg.Ans.Phase = room.GetPhase()
		roomdetailmsg.Ans.StockPrice = room.GetStockPrice()

		roomdetailmsg.Ans.Ship = room.GetShip()

		for k, v := range room.GetMap() {
			mapSpot := pb3.MappS{Name: k, Taken: v.GetTaken(),
				Price: v.GetPrice(), Award: v.GetAward(), Onboard: v.GetOnboard()}
			roomdetailmsg.Ans.Mapp = append(roomdetailmsg.Ans.Mapp, mapSpot)
		}

		for n, p := range room.GetManilaPlayers() {
			pl := pb3.PlayersS{Name: n, Stock: p.GetStockNum(),
				Money: p.GetMoney(), Online: p.GetOnline(),
				Seat: p.GetSeat(), Ready: p.GetReadyOrNot(), Canbid: p.GetCanBid()}
			roomdetailmsg.Ans.Players = append(roomdetailmsg.Ans.Players, pl)
		}
		roomdetailmsg.Ans.RenderAfter = renderAfter
	}
}

func RoomObjTellDeck(manilaRoom *manila.ManilaRoom) {
	messageType := 1
	for k, v := range manilaRoom.GetManilaPlayers() {
		handmsg := new(pb3.HandMsg).New()
		handmsg.Ans.Username = k
		handmsg.Ans.Hand = v.GetStocks()
		SendMessage(messageType, handmsg, v.GetConnection())
	}
}

func RoomObjChangePhase(manilaRoom *manila.ManilaRoom, phase string) {
	messageType := 1
	manilaRoom.SetPhase(phase)
	for _, v := range manilaRoom.GetManilaPlayers() {
		changephasemsg := new(pb3.ChangePhaseMsg).New()
		changephasemsg.Ans.RoomNum = manilaRoom.GetRoomNum()
		changephasemsg.Ans.Phase = manilaRoom.GetPhase()
		SendMessage(messageType, changephasemsg, v.GetConnection())
	}
}
