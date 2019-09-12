package global

import (
	"hello/baseroom"
	"hello/manila"
)

var ManilaLounge = map[int]manila.ManilaRoom{}
var EntranceLounge = map[int]baseroom.Room{
	0: *((&baseroom.Room{}).New(0, 0, -1, -1)),
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

func EntranceLoungeString() string {
	str := "{0: "
	for _, v := range EntranceLounge {
		str += v.String()
	}
	str += "}"
	return str
}
