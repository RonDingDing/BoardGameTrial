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
	str := fmt.Sprintf("%s, %d, %s, ", self.name, self.gold, self.connection.RemoteAddr())

	return str
}

func (self Player) GetName() string {
	return self.name
}

func (self *Player) New(name string, connection *websocket.Conn) *Player {
	self.name = name
	self.connection = connection
	return self
}

func (self *Player) SetGold(gold int) {
	self.gold = gold

}

func (self *Player) ConnectionClose() {
	self.connection.Close()
}
