package baseroom

import "github.com/gorilla/websocket"

type Player struct {
	Name       string
	Hand1      []Card
	Hand2      []Card
	Hand3      []Card
	Hand4      []Card
	Money1     int
	Money2     int
	Money3     int
	Money4     int
	Connection *websocket.Conn
}
