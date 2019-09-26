package global

import (
	"fmt"
	"hello/baseroom"
	"hello/manila"
	"hello/msg"
)

var ManilaLounge = map[int]*manila.ManilaRoom{}
var EntranceLounge = map[int]*baseroom.Room{
	msg.LoungeNum: new(baseroom.Room).New(0, 0, -1, -1),
}

var UserPlayerMap = map[string]baseroom.Player{}
var IpUserMap = map[string]string{}

func FindUserInManila(name string) (*manila.ManilaRoom, *baseroom.Room, int) {
	for roomNum, manilaRoomObj := range ManilaLounge {
		roomObj := manilaRoomObj.GetRoom()
		if _, exist := roomObj.GetPlayerNames()[name]; exist {
			return manilaRoomObj, nil, roomNum
		}
	}
	roomObj := EntranceLounge[msg.LoungeNum]
	lounge := roomObj.GetRoom()
	return nil, lounge, msg.LoungeNum
}

func FindRoomByNum(roomNum int) (*manila.ManilaRoom, *baseroom.Room) {
	if roomNum == msg.LoungeNum {
		roomObj := EntranceLounge[msg.LoungeNum]
		lounge := roomObj.GetRoom()
		return nil, lounge
	} else if room, ok := ManilaLounge[roomNum]; ok {
		return room, nil
	}
	return nil, nil
}

func NewManilaRoom(roomNum int) *manila.ManilaRoom {
	room := new(manila.ManilaRoom).New(roomNum)
	ManilaLounge[roomNum] = room
	return room
}

func EntranceLoungeString() string {
	str := fmt.Sprintf("{%d: ", msg.LoungeNum)
	for _, v := range EntranceLounge {
		str += v.String()
	}
	str += "}"
	return str
}

func ManilaLoungeString() string {
	str := "{\n  "
	for k, v := range ManilaLounge {
		str += fmt.Sprintf("%d: %s,\n", k, v.String())
	}
	str += "}"
	return str
}

func ToManilaPlayer(baseplayer *baseroom.Player) *manila.ManilaPlayer {
	return new(manila.ManilaPlayer).New(baseplayer.GetName(), baseplayer.GetConnection(), baseplayer.GetGold())
}
