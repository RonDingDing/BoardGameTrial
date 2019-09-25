package baseroom

import (
	"fmt"

	"github.com/gorilla/websocket"
)

type Player struct {
	name       string
	gold       int
	ready      bool
	seat       int
	online     bool
	connection *websocket.Conn

	Ip string
}

func (self *Player) String() string {
	str := fmt.Sprintf("\"%s\": {\"Name\": \"%s\", \"Gold\": %d, \"Connection\": \"%s\"}, ", self.name, self.name, self.gold, self.connection.RemoteAddr())
	return str
}

func (self *Player) GetName() string {
	return self.name
}

func (self *Player) GetConnection() *websocket.Conn {
	return self.connection
}

func (self *Player) SetConnection(connection *websocket.Conn) {
	self.connection = connection
	self.Ip = connection.RemoteAddr().String()
}

func (self *Player) GetGold() int {
	return self.gold
}

func (self *Player) New(name string, connection *websocket.Conn, gold int) *Player {
	self.name = name
	self.connection = connection
	self.Ip = connection.RemoteAddr().String()
	self.gold = gold
	self.ready = false
	self.seat = 0
	self.online = false
	return self
}

func (self *Player) AddGold(gold int) {
	self.gold += gold

}

func (self *Player) ConnectionClose() {
	self.connection.Close()
}

func (self *Player) GetOnline() bool {
	return self.online
}
func (self *Player) SetOnline(online bool) {
	self.online = online
}

func (self *Player) GetSeat() int {
	return self.seat
}

func (self *Player) SetSeat(seat int) {
	self.seat = seat
}

func (self *Player) GetReadyOrNot() bool {
	return self.ready
}

func (self *Player) SetReady(readied bool) {
	self.ready = readied
}
