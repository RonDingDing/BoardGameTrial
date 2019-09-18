package baseroom

import (
	"fmt"
)

const (
	AlreadyInRoom  = 1
	NewEntered     = 2
	FailedEntering = 0
	LoungeNum      = 0
)

type Room struct {
	roomNum           int
	gameNum           int
	started           bool
	playerNumForStart int
	playerNumMax      int
	players           map[string]*Player
}

func (self *Room) GetRoomNum() int {
	return self.roomNum
}

func (self *Room) String() string {
	str := ""
	str += "{"
	str += fmt.Sprintf("\n    \"%s\": %d, ", "RoomNum", self.roomNum)
	str += fmt.Sprintf("\n    \"%s\": %d, ", "GameNum", self.gameNum)
	str += fmt.Sprintf("\n    \"%s\": %d, ", "Started", self.started)
	str += "\n    \"Players\": {\n"
	for _, player := range self.players {
		str += "      "
		str += player.String()
	}
	str += "    }"
	return str
}

func (self *Room) New(roomNum int, gameNum int, playerNumForStart int, playerNumMax int) *Room {
	self.roomNum = roomNum
	self.gameNum = gameNum
	self.playerNumForStart = playerNumForStart
	self.playerNumMax = playerNumMax
	self.started = false
	self.players = make(map[string]*Player)
	return self
}

func (self *Room) GetPlayerNames() map[string]int {
	dic := make(map[string]int)
	for name := range self.players {
		dic[name] = 1
	}
	return dic
}

func (self *Room) StartGame() bool {
	playerNum := len(self.players)

	if (self.playerNumForStart > 0) && (!self.started) && (playerNum >= self.playerNumForStart) {
		self.started = true
		return true
	}
	return false
}

func (self *Room) Enter(player *Player) (*Player, int) {
	name := player.GetName()
	if playerOrigin, exist := self.players[name]; exist {
		return playerOrigin, AlreadyInRoom
	} else if self.playerNumMax > 0 {
		if len(self.players) < self.playerNumMax {
			self.players[name] = player
			return player, NewEntered
		}
	} else {
		self.players[name] = player
		return player, NewEntered
	}
	return player, FailedEntering
}

func (self *Room) Exit(name string) bool {
	_, ok := self.players[name]
	if ok && (!self.started) {
		delete(self.players, name)
		return true
	} else {
		return false
	}

}
