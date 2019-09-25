package manila

import (
	"fmt"
	"hello/baseroom"
	"hello/msg"

	"github.com/gorilla/websocket"
)

type ManilaRoom struct {
	room          *baseroom.Room
	mapp          map[string]ManilaSpot
	silkdeck      []ManilaStock
	coffeedeck    []ManilaStock
	ginsengdeck   []ManilaStock
	jadedeck      []ManilaStock
	manilaplayers map[string]*ManilaPlayer
	round         int
}

func (self *ManilaRoom) GetRound() int {
	return self.round
}

func (self *ManilaRoom) GetRoomNum() int {
	return self.room.GetRoomNum()
}

func (self *ManilaRoom) GetGameNum() int {
	return self.room.GetGameNum()
}

func (self *ManilaRoom) GetStarted() bool {
	return self.room.GetStarted()
}

func (self *ManilaRoom) GetPlayerNumForStart() int {
	return self.room.GetPlayerNumForStart()
}

func (self *ManilaRoom) GetPlayerNumMax() int {
	return self.room.GetPlayerNumMax()
}

func (self *ManilaRoom) String() string {
	str := self.room.String()

	str += ",\n    \"OtherProp\": {"
	for name, v := range self.manilaplayers {
		str += fmt.Sprintf("\n      \"%s\": {\"money\": %d, \"hand\": %s", name, v.GetMoney(), v.GetHand())
	}
	str += "}"
	str += ",\n    \"Mapp\": {"
	for _, v := range self.mapp {
		str += v.String()
	}
	str += ""
	str += "\n    }"

	str += fmt.Sprintf(",\n    \"Decks\": {\"Silk\": %d, \"Jade\": %d, \"Coffee\": %d, \"Ginseng\": %d}", len(self.silkdeck), len(self.jadedeck), len(self.coffeedeck), len(self.ginsengdeck))

	str += "\n  }"
	return str

}
func (self *ManilaRoom) New(roomNum int) *ManilaRoom {
	self.room = new(baseroom.Room).New(roomNum, 1, 3, 5)
	self.manilaplayers = make(map[string]*ManilaPlayer)
	self.ResetMap()
	self.ResetDecks()
	return self
}

func (self *ManilaRoom) Enter(player *ManilaPlayer) int {
	baseplayer := player.GetPlayer()
	entered := self.room.Enter(baseplayer)
	username := player.GetPlayer().GetName()
	if entered == msg.NorAlreadyInRoom {

	} else if entered == msg.NorNewEntered {
		self.manilaplayers[username] = player
	}
	return entered
}

func (self *ManilaRoom) Exit(name string) int {
	exited := self.room.Exit(name)
	if exited == msg.ErrNormal {
		delete(self.manilaplayers, name)
	}
	return exited
}

func (self *ManilaRoom) StartGame() bool {
	started := self.room.StartGame()
	if started {
		for _, v := range self.GetManilaPlayers() {
			v.SetReady(false)
		}
		self.ResetDecks()
		self.ResetMap()
	}
	return started
}

func (self *ManilaRoom) CanStartGame() bool {
	started := self.room.GetStarted()
	numForStart := self.room.GetPlayerNumForStart()
	numMax := self.room.GetPlayerNumMax()
	playerLen := len(self.GetManilaPlayers())
	if (playerLen >= numForStart) && (started == false) && (playerLen <= numMax) {
		for _, v := range self.GetManilaPlayers() {
			if v.GetReadyOrNot() == false {
				return false
			}
		}
		return true
	}
	return false
}

func (self *ManilaRoom) ResetMap() {
	self.mapp = DeepCopy(MappingOrigin)
}

func (self *ManilaRoom) GetRoom() *baseroom.Room {
	return self.room
}

func (self *ManilaRoom) GetMap() map[string]ManilaSpot {
	return self.mapp
}

func (self *ManilaRoom) ResetDecks() {
	self.jadedeck = []ManilaStock{}
	self.coffeedeck = []ManilaStock{}
	self.ginsengdeck = []ManilaStock{}
	self.silkdeck = []ManilaStock{}
	for _, color := range []int{JadeColor, SilkColor, CoffeeColor, GinsengColor} {
		card := new(ManilaStock).New(color)
		for j := 0; j < 5; j++ {
			switch color {
			case JadeColor:
				self.jadedeck = append(self.jadedeck, *card)
			case SilkColor:
				self.silkdeck = append(self.silkdeck, *card)
			case CoffeeColor:
				self.coffeedeck = append(self.coffeedeck, *card)
			case GinsengColor:
				self.ginsengdeck = append(self.ginsengdeck, *card)
			}
		}
	}
}

func (self *ManilaRoom) GetPlayerName() []string {
	return self.room.GetPlayerName()
}

func (self *ManilaRoom) GetSilkDeck() int {
	return len(self.silkdeck)
}

func (self *ManilaRoom) GetCoffeeDeck() int {
	return len(self.coffeedeck)
}

func (self *ManilaRoom) GetGinsengDeck() int {
	return len(self.ginsengdeck)
}

func (self *ManilaRoom) GetJadeDeck() int {
	return len(self.jadedeck)
}

func (self *ManilaRoom) GetDecks() []int {
	return []int{self.GetSilkDeck(), self.GetCoffeeDeck(), self.GetGinsengDeck(), self.GetJadeDeck()}
}

func (self *ManilaRoom) GetManilaPlayers() map[string]*ManilaPlayer {
	return self.manilaplayers
}

func (self *ManilaRoom) GetAllConnections() []*websocket.Conn {
	return self.room.GetAllConnections()
}
