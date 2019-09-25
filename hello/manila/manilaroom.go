package manila

import (
	"errors"
	"fmt"
	"hello/baseroom"
	"hello/msg"
	"math/rand"
	"time"

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
	highestBidder string
}

func (self *ManilaRoom) GetHighestBidder() string {
	return self.highestBidder
}

func (self *ManilaRoom) SetHighestBidder(bidder string) {
	self.highestBidder = bidder
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
			v.SetMoney(OriginalMoney)
		}
		self.ResetDecks()
		self.ResetMap()
		self.ResetCanBid()
		self.Deal2()
	}
	return started
}

func (self *ManilaRoom) ResetCanBid() {
	for _, v := range self.GetManilaPlayers() {
		v.SetCanBid(true)
	}
}

func (self *ManilaRoom) CanStartGame() bool {
	started := self.room.GetStarted()
	numForStart := self.room.GetPlayerNumForStart()
	numMax := self.room.GetPlayerNumMax()
	playerLen := len(self.manilaplayers)
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
		for j := 0; j < OriginalDeckNumber; j++ {
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

func (self *ManilaRoom) GetOneDeck(typing int) int {
	switch typing {
	case SilkColor:
		return len(self.silkdeck)
	case GinsengColor:
		return len(self.ginsengdeck)
	case CoffeeColor:
		return len(self.coffeedeck)
	case JadeColor:
		return len(self.jadedeck)
	}
	return 0
}

func (self *ManilaRoom) GetDecks() []int {
	return []int{self.GetOneDeck(SilkColor), self.GetOneDeck(CoffeeColor), self.GetOneDeck(GinsengColor), self.GetOneDeck(JadeColor)}
}

func (self *ManilaRoom) GetManilaPlayers() map[string]*ManilaPlayer {
	return self.manilaplayers
}

func (self *ManilaRoom) GetAllConnections() []*websocket.Conn {
	return self.room.GetAllConnections()
}

func (self *ManilaRoom) TakeOneStock(typing int) (ManilaStock, error) {
	switch typing {
	case SilkColor:
		if self.GetOneDeck(SilkColor) > 0 {
			silk := self.silkdeck[0]
			self.silkdeck = self.silkdeck[:len(self.silkdeck)-1]
			return silk, nil
		}
	case GinsengColor:
		if self.GetOneDeck(GinsengColor) > 0 {
			ginseng := self.ginsengdeck[0]
			self.ginsengdeck = self.ginsengdeck[:len(self.ginsengdeck)-1]
			return ginseng, nil
		}
	case CoffeeColor:
		if self.GetOneDeck(CoffeeColor) > 0 {
			coffee := self.coffeedeck[0]
			self.coffeedeck = self.coffeedeck[:len(self.coffeedeck)-1]
			return coffee, nil
		}
	case JadeColor:
		if self.GetOneDeck(JadeColor) > 0 {
			jade := self.jadedeck[0]
			self.jadedeck = self.jadedeck[:len(self.jadedeck)-1]
			return jade, nil
		}
	}
	return ManilaStock{}, errors.New("Not enough")
}

func (self *ManilaRoom) Deal2() {
	for _, v := range self.GetManilaPlayers() {
		dealed := 0
		for dealed < 2 {
			stock := randStock()
			switch stock {
			case SilkColor:
				if self.GetOneDeck(SilkColor) > 0 {
					silk, err := self.TakeOneStock(SilkColor)
					if err == nil {
						v.AddHand(silk)
						dealed += 1
					}
				}

			case GinsengColor:
				if self.GetOneDeck(GinsengColor) > 0 {
					ginseng, err := self.TakeOneStock(GinsengColor)
					if err == nil {
						v.AddHand(ginseng)
						dealed += 1
					}
				}

			case CoffeeColor:
				if self.GetOneDeck(CoffeeColor) > 0 {
					coffee, err := self.TakeOneStock(CoffeeColor)
					if err == nil {
						v.AddHand(coffee)
						dealed += 1
					}
				}

			case JadeColor:
				if self.GetOneDeck(JadeColor) > 0 {
					jade, err := self.TakeOneStock(JadeColor)
					if err == nil {
						v.AddHand(jade)
						dealed += 1
					}
				}
			}
		}
	}
}

func (self *ManilaRoom) SelectRandomPlayer() string {
	rand.NewSource(time.Now().UnixNano())
	playerNames := make([]string, 0)
	for k, _ := range self.manilaplayers {
		playerNames = append(playerNames, k)
	}
	num := rand.Intn(100) % len(playerNames)
	return playerNames[num]
}

func randStock() int {
	rand.NewSource(time.Now().UnixNano())
	allStock := []int{1, 2, 3, 4}
	num := rand.Intn(100) % len(allStock)
	return allStock[num]
}
