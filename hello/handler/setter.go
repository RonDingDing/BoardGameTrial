package handler

import (
	"hello/manila"
	"hello/pb3"
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
