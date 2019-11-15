package handler

import (
	"hello/manila"
	"hello/pb3"

	"github.com/gorilla/websocket"
)

func PirateRelated(piratePoint string, manilaRoom *manila.ManilaRoom) {
	RoomObjChangePhase(manilaRoom, manila.PhasePiratePlunder)
	pirate := manilaRoom.GetMap()[piratePoint].GetTaken()
	manilaRoom.SetTempCurrentPlayer(pirate)
	RoomObjTellRoomDetail(manilaRoom, nil)
	SetAnsAndBroadcastPirateMsg(pirate, true, manilaRoom)
}

func PostDragRelated(dragger string, manilaRoom *manila.ManilaRoom) {
	dragguser := manilaRoom.GetMap()[dragger].GetTaken()
	RoomObjChangePhase(manilaRoom, manila.PhasePostDrag)
	manilaRoom.SetTempCurrentPlayer(dragguser)
	RoomObjTellRoomDetail(manilaRoom, nil)
	SetAnsAndBroadcastPostDragMsg(dragguser, true, dragger, nil, manilaRoom)
}

func SetAnsAndBroadcastPirateMsg(pirate string, remind bool, manilaRoom *manila.ManilaRoom) {
	messageType := websocket.TextMessage
	roomNum := manilaRoom.GetRoomNum()
	piratemsg := new(pb3.PirateMsg).New()
	piratemsg.Ans.RoomNum = roomNum
	piratemsg.Ans.CastTime = manilaRoom.GetCastTime()
	piratemsg.Ans.Pirate = pirate
	piratemsg.Ans.ShipVacant = manilaRoom.GetShipPirateVacant()
	piratemsg.Ans.LastPlunderedShip = manilaRoom.GetLastPlunderedShip()
	piratemsg.Ans.RemindOrOperated = remind
	RoomObjBroadcastMessage(messageType, piratemsg, manilaRoom)
}

func SetAnsAndBroadcastDiceMsg(dice []int, casttime int, manilaRoom *manila.ManilaRoom) {
	roomNum := manilaRoom.GetRoomNum()
	messageType := websocket.TextMessage
	dicemsg := new(pb3.DiceMsg).New()
	dicemsg.Ans.RoomNum = roomNum
	dicemsg.Ans.Dice = dice
	dicemsg.Ans.CastTime = casttime
	RoomObjBroadcastMessage(messageType, dicemsg, manilaRoom)
}

func SetAnsAndBroadcastPostDragMsg(username string, remind bool, dragger string, postdragmsg *pb3.PostDragMsg, manilaRoom *manila.ManilaRoom) {
	roomNum := manilaRoom.GetRoomNum()
	messageType := websocket.TextMessage
	if postdragmsg == nil {
		postdragmsg = new(pb3.PostDragMsg).New()
	}
	postdragmsg.Ans.Username = username
	postdragmsg.Ans.RemindOrOperated = remind
	postdragmsg.Ans.RoomNum = roomNum
	postdragmsg.Ans.Phase = manilaRoom.GetPhase()
	postdragmsg.Ans.Dragger = dragger
	postdragmsg.Ans.Ship = manilaRoom.GetShip()
	postdragmsg.Ans.Dragable = manilaRoom.PostDragable()
	RoomObjBroadcastMessage(messageType, postdragmsg, manilaRoom)
}

func SetAnsAndBroadcastDecideTickFailMsg(pirate string, remind bool, shipToBeDecided int, manilaRoom *manila.ManilaRoom) {
	messageType := websocket.TextMessage
	roomNum := manilaRoom.GetRoomNum()
	decidetickfailmsg := new(pb3.DecideTickFailMsg).New()
	decidetickfailmsg.Ans.Pirate = pirate
	decidetickfailmsg.Ans.RemindOrOperated = remind
	decidetickfailmsg.Ans.RoomNum = roomNum
	decidetickfailmsg.Ans.ShipPlundered = shipToBeDecided
	RoomObjBroadcastMessage(messageType, decidetickfailmsg, manilaRoom)
}

func SetAnsAndBroadcastInvestMsg(username string, remind bool, invest string, investmsg *pb3.InvestMsg, manilaRoom *manila.ManilaRoom) {
	if investmsg == nil {
		investmsg = new(pb3.InvestMsg).New()
	}
	messageType := websocket.TextMessage
	roomNum := manilaRoom.GetRoomNum()
	investmsg.Ans.Username = username
	investmsg.Ans.RemindOrOperated = remind
	investmsg.Ans.RoomNum = roomNum
	investmsg.Ans.Invest = invest
	RoomObjBroadcastMessage(messageType, investmsg, manilaRoom)
}

func SetAnsAndBroadcastDragBoatMsg(username string, remind bool, dragable []int, dragboatmsg *pb3.DragBoatMsg, manilaRoom *manila.ManilaRoom) {
	if dragboatmsg == nil {
		dragboatmsg = new(pb3.DragBoatMsg).New()
	}
	messageType := websocket.TextMessage
	roomNum := manilaRoom.GetRoomNum()
	dragboatmsg.Ans.Username = username
	dragboatmsg.Ans.Phase = manilaRoom.GetPhase()
	dragboatmsg.Ans.RoomNum = roomNum
	dragboatmsg.Ans.RemindOrOperated = remind
	dragboatmsg.Ans.Ship = manilaRoom.GetShip()
	dragboatmsg.Ans.Dragable = dragable
	RoomObjBroadcastMessage(messageType, dragboatmsg, manilaRoom)
}

func SetAnsAndBroadcastPutBoatMsg(username string, remind bool, except int, putboatmsg *pb3.PutBoatMsg, manilaRoom *manila.ManilaRoom) {
	if putboatmsg == nil {
		putboatmsg = new(pb3.PutBoatMsg).New()
	}
	messageType := websocket.TextMessage
	roomNum := manilaRoom.GetRoomNum()
	putboatmsg.Ans.Username = username
	putboatmsg.Ans.RoomNum = roomNum
	putboatmsg.Ans.RemindOrOperated = remind
	putboatmsg.Ans.Except = except
	RoomObjBroadcastMessage(messageType, putboatmsg, manilaRoom)
}

func SetAnsAndBroadcastBuyStockMsg(username string, remind bool, bought int, buystockmsg *pb3.BuyStockMsg, manilaRoom *manila.ManilaRoom) {
	if buystockmsg == nil {
		buystockmsg = new(pb3.BuyStockMsg).New()
	}
	messageType := websocket.TextMessage
	roomNum := manilaRoom.GetRoomNum()
	buystockmsg.Ans.Bought = bought
	buystockmsg.Ans.Username = username
	buystockmsg.Ans.RoomNum = roomNum
	buystockmsg.Ans.RemindOrOperated = remind
	buystockmsg.Ans.Deck = manilaRoom.GetDecks()
	RoomObjBroadcastMessage(messageType, buystockmsg, manilaRoom)
}

func SetAnsAndBroadcastBidMsg(username string, bidmsg *pb3.BidMsg, manilaRoom *manila.ManilaRoom) {
	if bidmsg == nil {
		bidmsg = new(pb3.BidMsg).New()
	}
	messageType := websocket.TextMessage
	roomNum := manilaRoom.GetRoomNum()
	bidmsg.Ans.Username = username
	bidmsg.Ans.RoomNum = roomNum
	bidmsg.Ans.HighestBidPrice = manilaRoom.GetHighestBidPrice()
	bidmsg.Ans.HighestBidder = manilaRoom.GetHighestBidder()
	RoomObjBroadcastMessage(messageType, bidmsg, manilaRoom)

}
