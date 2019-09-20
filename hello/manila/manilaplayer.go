package manila

import (
	"hello/baseroom"

	"github.com/gorilla/websocket"
)

type OtherProps struct {
	hand   []ManilaStock
	money  int
	online bool
	seat   int
}

func (self *OtherProps) New() *OtherProps {
	self.hand = []ManilaStock{}
	self.money = 0
	self.online = true
	self.seat = 0
	return self
}

func (self *OtherProps) GetMoney() int {
	return self.money
}

func (self *OtherProps) GetHand() []ManilaStock {
	return self.hand
}

type ManilaPlayer struct {
	player     *baseroom.Player
	otherProps *OtherProps
}

func (self *ManilaPlayer) New(name string, connection *websocket.Conn, gold int) *ManilaPlayer {
	self.player = new(baseroom.Player).New(name, connection, gold)
	self.otherProps = new(OtherProps).New()
	return self
}

func (self *OtherProps) GetStocks() []int {
	stocks := []int{0, 0, 0, 0, 0}
	for _, v := range self.GetHand() {
		switch v.GetColor() {
		case SilkColor:
			stocks[SilkColor] += 1
		case JadeColor:
			stocks[JadeColor] += 1
		case CoffeeColor:
			stocks[CoffeeColor] += 1
		case GinsengColor:
			stocks[GinsengColor] += 1
		}
	}
	return stocks[1:]
}
func (self *ManilaPlayer) GetPlayer() *baseroom.Player {
	return self.player
}

func (self *ManilaPlayer) SetPlayer(player *baseroom.Player) {
	self.player = player
}

func (self *ManilaPlayer) GetHand() []ManilaStock {
	return self.otherProps.GetHand()
}

func (self *ManilaPlayer) GetMoney() int {
	return self.otherProps.GetMoney()
}

func (self *ManilaPlayer) AddHand(card ManilaStock) {
	self.otherProps.hand = append(self.otherProps.hand, card)
}

func (self *ManilaPlayer) AddMoney(money int) {
	self.otherProps.money += money
}

func (self *ManilaPlayer) GetOtherProps() *OtherProps {
	return self.otherProps
}

func (self *ManilaPlayer) SetOtherProps(OtherProps *OtherProps) {
	self.otherProps = OtherProps
}

func (self *OtherProps) GetOnline() bool {
	return self.online
}
func (self *OtherProps) SetOnline(online bool) {
	self.online = online
}

func (self *OtherProps) GetSeat() int {
	return self.seat
}

func (self *OtherProps) SetSeat(seat int) int {
	self.seat = seat
}
