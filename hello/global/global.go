package global

import (
	"fmt"
	"hello/baseroom"
	"hello/manila"
	"math/rand"
	"time"
)

var ManilaLounge = map[int]manila.ManilaRoom{}
var EntranceLounge = map[int]baseroom.Room{
	baseroom.LoungeNum: *new(baseroom.Room).New(0, 0, -1, -1),
}

var UserTrace = map[string]int{}
var UserPlayerMap = map[string]baseroom.Player{}

func FindUserInManila(name string) int {
	for roomNum, manilaRoomObj := range ManilaLounge {
		roomObj := manilaRoomObj.GetRoom()
		if _, exist := roomObj.GetPlayerNames()[name]; exist {
			return roomNum
		}
	}
	return 0
}

func NewManilaRoom() *manila.ManilaRoom {
	roomNum := 0
	for {
		rand.Seed(time.Now().UnixNano())
		roomNum = rand.Intn(10000)
		if _, ok := ManilaLounge[roomNum]; ok {
			continue
		} else if roomNum == 0 {
			continue
		} else {
			break
		}
	}
	room := *new(manila.ManilaRoom).New(roomNum)
	ManilaLounge[roomNum] = room
	return &room
}

func EntranceLoungeString() string {
	str := fmt.Sprintf("{%d: ", baseroom.LoungeNum)
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
