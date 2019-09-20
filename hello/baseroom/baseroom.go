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
	sorted            []string
}

func (self *Room) GetRoomNum() int {
	return self.roomNum
}

func (self *Room) GetGameNum() int {
	return self.gameNum
}

func (self *Room) GetStarted() bool {
	return self.started
}

func (self *Room) GetPlayerNumForStart() int {
	return self.playerNumForStart
}

func (self *Room) GetPlayerNumMax() int {
	return self.playerNumMax
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

func (self *Room) Enter(player interface{}) int {
	switch player := player.(type) {
	case *Player:
		name := player.GetName()
		if _, exist := self.players[name]; exist {
			return AlreadyInRoom
		} else if self.playerNumMax > 0 {
			if len(self.players) < self.playerNumMax {
				self.players[name] = player
				self.enterSort(name)
				return NewEntered
			}
		} else {
			self.players[name] = player
			self.enterSort(name)
			return NewEntered
		}
	}
	return FailedEntering
}

func (self *Room) enterSort(name string) {
	self.sorted = append(self.sorted, name)
}

func (self *Room) Exit(name string) bool {
	_, ok := self.players[name]
	if ok && (!self.started) {
		delete(self.players, name)
		self.exitSort(name)
		return true
	} else {
		return false
	}
}

func (self *Room) exitSort(name string) {
	breakPoint := -1
	array := self.sorted[:]
	for i, v := range self.sorted {
		if v == name {
			breakPoint = i
		}
	}
	if breakPoint != -1 {
		if len(self.sorted) == 1 {
			array = make([]string, 0)
		} else if breakPoint == len(self.sorted)-1 {
			array = self.sorted[:len(self.sorted)-1]
		} else {
			for m := breakPoint; m < len(self.sorted)-1; m++ {
				array[m] = array[m+1]
			}
			array = self.sorted[:len(self.sorted)-1]
		}
		self.sorted = array
	}
}

func (self *Room) GetPlayerName() []string {
	return self.sorted
}
