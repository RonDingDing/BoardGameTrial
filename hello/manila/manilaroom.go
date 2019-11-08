package manila

import (
	"errors"
	"fmt"
	"hello/baseroom"
	"hello/msg"
	"log"
	"math/rand"
	"strconv"
	"time"

	"github.com/gorilla/websocket"
)

type ManilaRoom struct {
	room            *baseroom.Room
	mapp            map[string]*ManilaSpot
	ships           []int
	silkdeck        []ManilaStock
	coffeedeck      []ManilaStock
	ginsengdeck     []ManilaStock
	jadedeck        []ManilaStock
	manilaplayers   map[string]*ManilaPlayer
	round           int
	highestBidder   string
	highestBidPrice int
	currentPlayer   string
	phase           string
	stockPrice      []int
	casttime        int
	tickFailSpot    map[int]string
}

func (self *ManilaRoom) GetTickFailSpot(spotName int) string {
	if v, ok := self.tickFailSpot[spotName]; ok {
		return v
	}
	return "!"
}

func (self *ManilaRoom) SetTickFailSpot(spotName int, shipName string) {
	if spotName >= OneTickSpot && spotName <= ThreeFailSpot && (shipName == "coffee" || shipName == "silk" || shipName == "ginseng" || shipName == "jade") {
		self.tickFailSpot[spotName] = shipName
	}
}

func (self *ManilaRoom) GetCastTime() int {
	return self.casttime
}

func (self *ManilaRoom) AddCastTime() int {
	self.casttime++
	return self.casttime
}

func (self *ManilaRoom) ResetCastTime() {
	self.casttime = 0
}

func (self *ManilaRoom) GetOneStockPrice(typing int) int {
	return self.stockPrice[typing-1]
}

func (self *ManilaRoom) GetStockPrice() []int {
	return self.stockPrice
}

func (self *ManilaRoom) GetBuyStockPrice(typing int) int {
	price := self.stockPrice[typing-1]
	if price == 0 {
		return 5
	}
	return price
}

func (self *ManilaRoom) SetStockPrice(typing int, price int) {
	self.stockPrice[typing-1] = price
}

func (self *ManilaRoom) HasOtherBidder(username string) (bool, map[string]bool) {
	bidder := make(map[string]bool)
	for k, v := range self.GetManilaPlayers() {
		if k != username {
			if v.GetCanBid() {
				bidder[k] = true
			}
		}
	}
	return len(bidder) > 0, bidder
}

func (self *ManilaRoom) NextBidder(username string, mapp map[string]bool) string {
	names := self.GetPlayerName()
	round := append(names, names...)
	for i, n := range round {
		if n == username {
			for m := i + 1; m < len(round); m++ {
				if _, ok := mapp[round[m]]; ok {
					return round[m]
				}
			}
		}
	}
	return ""
}

func (self *ManilaRoom) NextPlayer(username string) (string, bool) {
	names := self.GetPlayerName()
	startPlayer := self.GetHighestBidder()
	roundList := append(names, names...)
	nextPhase := false
	for i, n := range roundList {
		if n == username {
			if roundList[i+1] == startPlayer {
				nextPhase = true
			}
			return roundList[i+1], nextPhase
		}
	}
	return "", nextPhase
}

func (self *ManilaRoom) GetHighestBidPrice() int {
	return self.highestBidPrice
}

func (self *ManilaRoom) SetHighestBidPrice(price int) {
	self.highestBidPrice = price
}

func (self *ManilaRoom) GetPhase() string {
	return self.phase
}

func (self *ManilaRoom) SetPhase(phase string) {
	self.phase = phase
}

func (self *ManilaRoom) ResetOther() {
	self.round = 0
	self.highestBidder = ""
	self.highestBidPrice = 0
	self.currentPlayer = ""
	self.ResetDecks()
	self.ResetMap()
	self.ResetCanBid()
	self.RidNullPlayerName()
}

func (self *ManilaRoom) GetCurrentPlayer() string {
	return self.currentPlayer
}

func (self *ManilaRoom) SetCurrentPlayer(currentPlayer string) {
	self.currentPlayer = currentPlayer
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

func (self *ManilaRoom) SetRound(round int) {
	self.round = round
}

func (self *ManilaRoom) AddRound() {
	self.round += 1
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
	self.ResetCastTime()
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

func (self *ManilaRoom) ResetGame() {
	for _, v := range self.GetManilaPlayers() {
		v.SetReady(false)
		v.SetMoney(OriginalMoney)
	}
	self.ResetOther()
}

func (self *ManilaRoom) StartGame() bool {
	started := self.room.StartGame()
	if started {
		self.ResetGame()
		self.Deal2()
		self.SetRound(1)
		self.SetPhase(PhaseBidding)
	}
	return started
}

func (self *ManilaRoom) RidNullPlayerName() {
	names := make([]string, 0)
	for _, n := range self.GetPlayerName() {
		if n != "" {
			names = append(names, n)
		}
	}
	self.SetPlayerName(names)
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

func (self *ManilaRoom) GetRoom() *baseroom.Room {
	return self.room
}

func (self *ManilaRoom) ResetMap() {
	mappingOrigin := map[string]*ManilaSpot{
		"1tick": &ManilaSpot{"1tick", "", 4, 6, true},
		"2tick": &ManilaSpot{"2tick", "", 3, 8, true},
		"3tick": &ManilaSpot{"3tick", "", 2, 15, true},

		"1fail": &ManilaSpot{"1fail", "", 4, 6, true},
		"2fail": &ManilaSpot{"2fail", "", 3, 8, true},
		"3fail": &ManilaSpot{"3fail", "", 2, 15, true},

		"1pirate": &ManilaSpot{"1pirate", "", 5, 0, true},
		"2pirate": &ManilaSpot{"2pirate", "", 5, 0, true},

		"1drag": &ManilaSpot{"1drag", "", 2, 0, true},
		"2drag": &ManilaSpot{"2drag", "", 5, 0, true},

		"repair": &ManilaSpot{"repair", "", 0, 10, true},

		"1silk": &ManilaSpot{"1silk", "", 3, 0, false},
		"2silk": &ManilaSpot{"2silk", "", 4, 0, false},
		"3silk": &ManilaSpot{"3silk", "", 5, 0, false},

		"1jade": &ManilaSpot{"1jade", "", 3, 0, false},
		"2jade": &ManilaSpot{"2jade", "", 4, 0, false},
		"3jade": &ManilaSpot{"3jade", "", 5, 0, false},
		"4jade": &ManilaSpot{"4jade", "", 5, 0, false},

		"1ginseng": &ManilaSpot{"1ginseng", "", 1, 0, false},
		"2ginseng": &ManilaSpot{"2ginseng", "", 2, 0, false},
		"3ginseng": &ManilaSpot{"3ginseng", "", 3, 0, false},

		"1coffee": &ManilaSpot{"1coffee", "", 2, 0, false},
		"2coffee": &ManilaSpot{"2coffee", "", 3, 0, false},
		"3coffee": &ManilaSpot{"3coffee", "", 4, 0, false},
	}
	self.mapp = mappingOrigin
	self.ships = []int{-1, -1, -1, -1}
	self.tickFailSpot = map[int]string{
		OneTickSpot:   "",
		TwoTickSpot:   "",
		ThreeTickSpot: "",

		OneFailSpot:   "",
		TwoFailSpot:   "",
		ThreeFailSpot: "",
	}
}

func (self *ManilaRoom) GetMap() map[string]*ManilaSpot {
	return self.mapp
}

func (self *ManilaRoom) SetMapOnboard(cargoType int, step int) {
	switch cargoType {
	case SilkColor:
		onesilk := self.mapp["1silk"]
		onesilk.SetOnboard(true)
		twosilk := self.mapp["2silk"]
		twosilk.SetOnboard(true)
		threesilk := self.mapp["3silk"]
		threesilk.SetOnboard(true)
		self.ships[cargoType-1] = step
	case JadeColor:
		onejade := self.mapp["1jade"]
		onejade.SetOnboard(true)
		twojade := self.mapp["2jade"]
		twojade.SetOnboard(true)
		threejade := self.mapp["3jade"]
		threejade.SetOnboard(true)
		fourjade := self.mapp["4jade"]
		fourjade.SetOnboard(true)
		self.ships[cargoType-1] = step
	case CoffeeColor:
		onecoffee := self.mapp["1coffee"]
		onecoffee.SetOnboard(true)
		twocoffee := self.mapp["2coffee"]
		twocoffee.SetOnboard(true)
		threecoffee := self.mapp["3coffee"]
		threecoffee.SetOnboard(true)
		self.ships[cargoType-1] = step
	case GinsengColor:
		oneginseng := self.mapp["1ginseng"]
		oneginseng.SetOnboard(true)
		twoginseng := self.mapp["2ginseng"]
		twoginseng.SetOnboard(true)
		threeginseng := self.mapp["3ginseng"]
		threeginseng.SetOnboard(true)
		self.ships[cargoType-1] = step
	}
}

func (self *ManilaRoom) GetShip() []int {
	return self.ships
}

func (self *ManilaRoom) HasBoatForPirate() bool {
	hasBoat := false
	for _, v := range self.ships {
		if v == 13 {
			return true
		}
	}
	return hasBoat
}

func (self *ManilaRoom) GetShipPirateVacant() []int {
	vacant := []int{VacantInvalid, VacantInvalid, VacantInvalid, VacantInvalid}
	for k, v := range self.ships {
		if v != -1 || v == 13 {
			vacant[k] = VacantNotVacant
			shipName := ColorString[k+1]
			for i := 1; i < 5; i++ {
				spotName := strconv.Itoa(i) + shipName
				if spot, ok := self.mapp[spotName]; ok {
					if spot.GetTaken() == "" {
						vacant[k] = i
						break
					}
				}
			}
		}
	}
	return vacant
}

func (self *ManilaRoom) ResetDecks() {
	self.jadedeck = []ManilaStock{}
	self.coffeedeck = []ManilaStock{}
	self.ginsengdeck = []ManilaStock{}
	self.silkdeck = []ManilaStock{}
	self.stockPrice = []int{0, 0, 0, 0}
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

func (self *ManilaRoom) SetPlayerName(names []string) {
	self.room.SetPlayerName(names)
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
	decks := []int{0, 0, 0, 0}
	for _, v := range []int{CoffeeColor, SilkColor, GinsengColor, JadeColor} {
		leng := self.GetOneDeck(v)
		decks[v-1] = leng
	}
	return decks
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
	deck := self.ShuffleDeck()
	i := 0
	for _, p := range self.manilaplayers {
		for dealed := 0; dealed < 2; dealed++ {
			color := deck[i].GetColor()
			card, _ := self.TakeOneStock(color)
			p.AddHand(card)
			i++
		}
	}
}

func (self *ManilaRoom) SelectRandomPlayer() string {
	rand.Seed(time.Now().UnixNano())
	playerNames := make([]string, 0)
	for k, _ := range self.manilaplayers {
		playerNames = append(playerNames, k)
	}
	num := rand.Intn(len(playerNames))
	return playerNames[num]
}

func (self *ManilaRoom) ShuffleDeck() []ManilaStock {
	deck := append(append(append(self.jadedeck, self.silkdeck...), self.ginsengdeck...), self.coffeedeck...)
	rand.Seed(time.Now().UnixNano())
	for i := 0; i < len(deck); i++ {
		swap := rand.Intn(len(deck))
		deck[i], deck[swap] = deck[swap], deck[i]
	}
	return deck
}

func (self *ManilaRoom) CastDice() ([]int, int) {
	rand.Seed(time.Now().UnixNano())
	result := []int{0, 0, 0, 0}
	for k, v := range self.ships {
		if v != -1 {
			result[k] = rand.Intn(6) + 1
		}
	}
	return []int{5, 5, 5, 0}, self.AddCastTime()
	// return result, self.AddCastTime()
}

func (self *ManilaRoom) OccupyTick(shipName string) int {
	for i := 1; i < 4; i++ {
		spotName := 13 + i
		if self.GetTickFailSpot(spotName) == "" {
			self.SetTickFailSpot(spotName, shipName)
			return spotName
		}
	}
	return 0
}

func (self *ManilaRoom) RunShip(dice []int) {
	for k, num := range dice {
		origin := self.ships[k]
		if origin < 13 {
			after := origin + num
			anoafter := after
			if after > 13 {
				anoafter = self.OccupyTick(ColorString[k+1])
			}
			self.ships[k] = anoafter
		}
	}
}

func (self *ManilaRoom) SettleRound() {
	log.Println("Settle!")
}

func (self *ManilaRoom) PostDrag() {
	log.Println("Postdrag!")
}

func (self *ManilaRoom) ThirteenToTick() {
	for k, v := range self.ships {
		shipName := ColorString[k+1]
		if v == 13 {
			anoafter := self.OccupyTick(shipName)
			self.ships[k] = anoafter
		}
	}

}
