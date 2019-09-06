package baseroom

import "github.com/gorilla/websocket"

type Player struct {
	name       string
	hand1      []Card
	hand2      []Card
	hand3      []Card
	hand4      []Card
	gold1      int
	gold2      int
	gold3      int
	gold4      int
	money1     int
	money2     int
	money3     int
	money4     int
	connection *websocket.Conn
}

func (self Player) GetName() string {
	return self.name
}
