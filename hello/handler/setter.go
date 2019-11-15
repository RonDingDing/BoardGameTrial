package handler

import (
	"hello/manila"
	"hello/pb3"

	"github.com/gorilla/websocket"
)

func SetAnsAndSendPostDragMsg(dragger string, manilaRoom *manila.ManilaRoom, roomNum int, messageType int) {
	dragguser := manilaRoom.GetMap()[dragger].GetTaken()
	RoomObjChangePhase(manilaRoom, manila.PhasePostDrag)
	manilaRoom.SetTempCurrentPlayer(dragguser)
	RoomObjTellRoomDetail(manilaRoom, nil)
	postdragable := manilaRoom.PostDragable()
	postdragmsg := new(pb3.PostDragMsg).New()
	postdragmsg.Ans.Username = dragguser
	postdragmsg.Ans.RemindOrOperated = true
	postdragmsg.Ans.RoomNum = roomNum
	postdragmsg.Ans.Dragable = postdragable
	postdragmsg.Ans.Dragger = dragger
	postdragmsg.Ans.Ship = manilaRoom.GetShip()
	postdragmsg.Ans.Phase = manilaRoom.GetPhase()
	RoomObjBroadcastMessage(messageType, postdragmsg, manilaRoom)
}

func SetAnsAndBroadcastPirateMsg(roomNum int, pirate string, remind bool, manilaRoom *manila.ManilaRoom) {
	messageType := websocket.TextMessage
	piratemsg := new(pb3.PirateMsg).New()
	piratemsg.Ans.RoomNum = roomNum
	piratemsg.Ans.CastTime = manilaRoom.GetCastTime()
	piratemsg.Ans.Pirate = pirate
	piratemsg.Ans.ShipVacant = manilaRoom.GetShipPirateVacant()
	piratemsg.Ans.LastPlunderedShip = manilaRoom.GetLastPlunderedShip()
	piratemsg.Ans.RemindOrOperated = remind
	RoomObjBroadcastMessage(messageType, piratemsg, manilaRoom)
}

func SetAnsAndBroadcastDiceMsg(roomNum int, dice []int, casttime int, manilaRoom *manila.ManilaRoom) {
	messageType := websocket.TextMessage
	dicemsg := new(pb3.DiceMsg).New()
	dicemsg.Ans.RoomNum = roomNum
	dicemsg.Ans.Dice = dice
	dicemsg.Ans.CastTime = casttime
	RoomObjBroadcastMessage(messageType, dicemsg, manilaRoom)
}

func SetAnsAndBroadcastPostDragMsg(username string, roomNum int, remind bool, postdragmsg *pb3.PostDragMsg, manilaRoom *manila.ManilaRoom) {
	messageType := websocket.TextMessage
	postdragmsg.Ans.Username = username
	postdragmsg.Ans.RemindOrOperated = remind
	postdragmsg.Ans.RoomNum = roomNum
	postdragmsg.Ans.Phase = manilaRoom.GetPhase()
	postdragmsg.Ans.Ship = manilaRoom.GetShip()
	RoomObjBroadcastMessage(messageType, postdragmsg, manilaRoom)
}

func SetAnsAndBroadcastDecideTickFailMsg(pirate string, roomNum int, remind bool, shipToBeDecided int, manilaRoom *manila.ManilaRoom) {
	messageType := websocket.TextMessage
	decidetickfailmsg := new(pb3.DecideTickFailMsg).New()
	decidetickfailmsg.Ans.Pirate = pirate
	decidetickfailmsg.Ans.RemindOrOperated = remind
	decidetickfailmsg.Ans.RoomNum = roomNum
	decidetickfailmsg.Ans.ShipPlundered = shipToBeDecided
	RoomObjBroadcastMessage(messageType, decidetickfailmsg, manilaRoom)
}

func SetAnsAndBroadcastInvestMsg(username string, roomNum int, remind bool, invest string, investmsg *pb3.InvestMsg, manilaRoom *manila.ManilaRoom) {
	if investmsg == nil {
		investmsg = new(pb3.InvestMsg).New()
	}
	messageType := websocket.TextMessage
	investmsg.Ans.Username = username
	investmsg.Ans.RemindOrOperated = remind
	investmsg.Ans.RoomNum = roomNum
	investmsg.Ans.Invest = invest
	RoomObjBroadcastMessage(messageType, investmsg, manilaRoom)
}

func SetAnsAndBroadcastDragBoatMsg(username string, roomNum int, remind bool, dragable []int, dragboatmsg *pb3.DragBoatMsg, manilaRoom *manila.ManilaRoom) {
	if dragboatmsg == nil {
		dragboatmsg = new(pb3.DragBoatMsg).New()
	}
	messageType := websocket.TextMessage
	dragboatmsg.Ans.Username = username
	dragboatmsg.Ans.RemindOrOperated = remind
	dragboatmsg.Ans.RoomNum = roomNum
	dragboatmsg.Ans.Phase = manilaRoom.GetPhase()
	dragboatmsg.Ans.Ship = manilaRoom.GetShip()
	dragboatmsg.Ans.Dragable = dragable
	RoomObjBroadcastMessage(messageType, dragboatmsg, manilaRoom)
}

func SetAnsAndBroadcastPutBoatMsg(username string, roomNum int, remind bool, except int, putboatmsg *pb3.PutBoatMsg, manilaRoom *manila.ManilaRoom) {
	if putboatmsg == nil {
		dragboatmsg = new(pb3.DragBoatMsg).New()
	}
	putboatmsg.Ans.Username = username
	putboatmsg.Ans.RemindOrOperated = remind
	putboatmsg.Ans.RoomNum = roomNum
	putboatmsg.Ans.Except = except
	RoomObjBroadcastMessage(messageType, putboatmsg, manilaRoom)
}

func SetAnsAndBroadcastBuyStockMsg(username string, roomNum int, remind bool, bought int, buystockmsg *pb3.BuyStockMsg, manilaRoom *manila.ManilaRoom) {
	if buystockmsg == nil {
		buystockmsg = new(pb3.BuyStockMsg).New()
	}
	buystockmsg.Ans.Bought = bought
	buystockmsg.Ans.Username = username
	buystockmsg.Ans.RoomNum = roomNum
	buystockmsg.Ans.RemindOrOperated = remind
	buystockmsg.Ans.Deck = manilaRoom.GetDecks()
	RoomObjBroadcastMessage(messageType, buystockmsg, manilaRoom)
}
