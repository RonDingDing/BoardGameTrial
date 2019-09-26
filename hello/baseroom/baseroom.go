package baseroom

import (
	"fmt"
	"hello/msg"

	"github.com/gorilla/websocket"
)

type Room struct {
	roomNum           int
	gameNum           int
	started           bool
	playerNumForStart int
	playerNumMax      int
	players           map[string]*Player
	seats             []string
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
func (self *Room) GetRoom() *Room {
	return self
}

func (self *Room) New(roomNum int, gameNum int, playerNumForStart int, playerNumMax int) *Room {
	self.roomNum = roomNum
	self.gameNum = gameNum
	self.playerNumForStart = playerNumForStart
	self.playerNumMax = playerNumMax
	self.started = false
	self.players = make(map[string]*Player)
	seatNum := 0
	if playerNumMax > 0 {
		seatNum = playerNumMax
	}
	self.seats = make([]string, seatNum)
	return self
}

func (self *Room) SetPlayerName(names []string) {
	self.seats = names
}

func (self *Room) GetPlayerNames() map[string]int {
	dic := make(map[string]int)
	for k := range self.players {
		dic[k] = 1
	}
	return dic
}

func (self *Room) StartGame() bool {
	if self.playerNumForStart > 0 {
		self.started = true
		return true
	}
	return false
}

func (self *Room) Enter(player *Player) int {
	name := player.GetName()
	if playerInRoom, exist := self.players[name]; exist {
		playerInRoom.SetConnection(player.GetConnection())
		playerInRoom.SetOnline(true)
		return msg.NorAlreadyInRoom
	} else if self.playerNumMax > 0 {
		if len(self.players) < self.playerNumMax && (!self.started) {
			self.players[name] = player
			self.enterSort(name)
			return msg.NorNewEntered
		}
	} else {
		self.players[name] = player
		self.enterSort(name)
		return msg.NorNewEntered
	}

	return msg.ErrFailedEntering
}

func (self *Room) enterSort(name string) {
	if self.playerNumMax > 0 {
		for _, v := range self.seats {
			if v == name {
				return
			}
		}

		for k, v := range self.seats {
			if v == "" {
				self.seats[k] = name
				self.players[name].SetSeat(k + 1)
				break
			}
		}
	} else {
		self.seats = make([]string, 0)
		for k, _ := range self.players {
			self.seats = append(self.seats, k)
		}

	}
}

func (self *Room) Exit(name string) int {
	_, ok := self.players[name]
	if ok {
		if !self.started {
			delete(self.players, name)
			self.exitSort(name)
			return msg.ErrNormal
		} else {
			return msg.ErrGameStarted
		}
	} else {
		return msg.ErrUserNotInRoom
	}
}

func (self *Room) exitSort(name string) {
	if self.playerNumMax > 0 {
		for k, v := range self.seats {
			if v == name {
				self.seats[k] = ""
				break
			}
		}
	} else {
		self.seats = make([]string, 0)
		for k, _ := range self.players {
			self.seats = append(self.seats, k)
		}
	}
}

func (self *Room) GetPlayerName() []string {
	return self.seats
}

func (self *Room) GetAllConnections() []*websocket.Conn {
	allConnections := make([]*websocket.Conn, 0)
	for _, player := range self.players {
		connection := player.GetConnection()
		allConnections = append(allConnections, connection)
	}
	return allConnections
}
