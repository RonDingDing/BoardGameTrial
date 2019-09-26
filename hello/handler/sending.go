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
	messageReturn, err := json.Marshal(messageObj)
	if err != nil {
		log.Print(err)
		return
	}
	manila, base := global.FindRoomByNum(roomNum)
	if manila != nil {
		for _, connection := range manila.GetAllConnections() {
			err = connection.WriteMessage(messageType, messageReturn)
			log.Printf("%-8s: %s %4s %s\n\n", "castroom", string(messageReturn), "to", connection.RemoteAddr())
			if err != nil {
				log.Print(err)
				return
			}
		}
	} else if base != nil {
		for _, connection := range base.GetAllConnections() {
			err = connection.WriteMessage(messageType, messageReturn)
			log.Printf("%-8s: %s %4s %s\n\n", "castroom", string(messageReturn), "to", connection.RemoteAddr())
			if err != nil {
				log.Print(err)
				return
			}
		}
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
		room := base
		roomdetailmsg.Ans.RoomNum = 0
		roomdetailmsg.Ans.GameNum = room.GetGameNum()
		roomdetailmsg.Ans.Started = room.GetStarted()
		roomdetailmsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		roomdetailmsg.Ans.PlayerNumMax = room.GetPlayerNumMax()

		roomdetailmsg.Ans.PlayerName = room.GetPlayerName()
	} else if manilaRoom != nil {
		room := manilaRoom
		roomdetailmsg.Ans.RoomNum = room.GetRoomNum()
		roomdetailmsg.Ans.GameNum = room.GetGameNum()
		roomdetailmsg.Ans.Started = room.GetStarted()
		roomdetailmsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		roomdetailmsg.Ans.PlayerNumMax = room.GetPlayerNumMax()
		roomdetailmsg.Ans.PlayerName = room.GetPlayerName()
		roomdetailmsg.Ans.SilkDeck = room.GetOneDeck(manila.SilkColor)
		roomdetailmsg.Ans.CoffeeDeck = room.GetOneDeck(manila.CoffeeColor)
		roomdetailmsg.Ans.GinsengDeck = room.GetOneDeck(manila.GinsengColor)
		roomdetailmsg.Ans.JadeDeck = room.GetOneDeck(manila.JadeColor)
		roomdetailmsg.Ans.Round = room.GetRound()
		roomdetailmsg.Ans.HighestBidder = room.GetHighestBidder()
		roomdetailmsg.Ans.HighestPrice = room.GetHighestBidPrice()
		roomdetailmsg.Ans.CurrentPlayer = room.GetCurrentPlayer()
		roomdetailmsg.Ans.Phase = room.GetPhase()

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

	}
}

func HelperSetRoomObjPropertyRoomDetail(roomdetailmsg *pb3.RoomDetailMsg, roomObj interface{}) {
	switch room := roomObj.(type) {
	case *baseroom.Room:
		roomdetailmsg.Ans.RoomNum = 0
		roomdetailmsg.Ans.GameNum = room.GetGameNum()
		roomdetailmsg.Ans.Started = room.GetStarted()
		roomdetailmsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		roomdetailmsg.Ans.PlayerNumMax = room.GetPlayerNumMax()
		roomdetailmsg.Ans.PlayerName = room.GetPlayerName()
	case *manila.ManilaRoom:
		roomdetailmsg.Ans.RoomNum = room.GetRoomNum()
		roomdetailmsg.Ans.GameNum = room.GetGameNum()
		roomdetailmsg.Ans.Started = room.GetStarted()
		roomdetailmsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		roomdetailmsg.Ans.PlayerNumMax = room.GetPlayerNumMax()
		roomdetailmsg.Ans.PlayerName = room.GetPlayerName()
		roomdetailmsg.Ans.SilkDeck = room.GetOneDeck(manila.SilkColor)
		roomdetailmsg.Ans.CoffeeDeck = room.GetOneDeck(manila.CoffeeColor)
		roomdetailmsg.Ans.GinsengDeck = room.GetOneDeck(manila.GinsengColor)
		roomdetailmsg.Ans.JadeDeck = room.GetOneDeck(manila.JadeColor)
		roomdetailmsg.Ans.Round = room.GetRound()
		roomdetailmsg.Ans.HighestBidder = room.GetHighestBidder()
		roomdetailmsg.Ans.HighestPrice = room.GetHighestBidPrice()
		roomdetailmsg.Ans.CurrentPlayer = room.GetCurrentPlayer()
		roomdetailmsg.Ans.Phase = room.GetPhase()

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

	}
}
