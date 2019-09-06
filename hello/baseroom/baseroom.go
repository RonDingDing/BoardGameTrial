package baseroom

import (
	"errors"
)

type Room struct {
	roomNum           int
	gameNum           int
	started           bool
	playerNumForStart int
	playerNumMax      int
	players           map[string]Player
	deck1             []Card
	deck2             []Card
	deck3             []Card
	deck4             []Card
}

func (self Room) New(roomNum int, gameNum int, playerNumForStart int, playerNumMax int) Room {
	self.roomNum = roomNum
	self.gameNum = gameNum
	self.playerNumForStart = playerNumForStart
	self.playerNumMax = playerNumMax
	self.started = false
	self.players = make(map[string]Player)
	return self
}

func (self *Room) SetDeck(cards []Card, num int) error {
	switch num {
	case 1:
		self.deck1 = cards
		return nil
	case 2:
		self.deck2 = cards
		return nil
	case 3:
		self.deck3 = cards
		return nil
	case 4:
		self.deck4 = cards
		return nil
	default:
		return errors.New("Not a good num")
	}

}

func (self *Room) StartGame() bool {
	playerNum := len(self.players)

	if (!self.started) && playerNum >= self.playerNumForStart {
		self.started = true
		return true
	}
	return false
}

func (self *Room) Enter(player Player) bool {
	if len(self.players) < self.playerNumMax {
		self.players[player.GetName()] = player
		return true
	}
	return false
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
