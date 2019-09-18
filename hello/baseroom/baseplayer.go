package baseroom

import (
	"fmt"

	"github.com/gorilla/websocket"
)

type Player struct {
	name       string
	gold       int
	connection *websocket.Conn
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

func (self *Player) GetGold() int {
	return self.gold
}

func (self *Player) New(name string, connection *websocket.Conn, gold int) *Player {
	self.name = name
	self.connection = connection
	self.gold = gold
	return self
}

func (self *Player) AddGold(gold int) {
	self.gold += gold

}

func (self *Player) ConnectionClose() {
	self.connection.Close()
}
