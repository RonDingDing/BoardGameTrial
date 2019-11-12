package manila

import "fmt"

const (
	EmptyColor   = 0
	CoffeeColor  = 1
	SilkColor    = 2
	GinsengColor = 3
	JadeColor    = 4

	OriginalMoney      = 30
	OriginalDeckNumber = 5

	OneTickSpot   = 14
	TwoTickSpot   = 15
	ThreeTickSpot = 16

	OneFailSpot   = 17
	TwoFailSpot   = 18
	ThreeFailSpot = 19

	VacantInvalid   = -1
	VacantNotVacant = 0
	VacnatVacant    = 1

	PhaseBidding        = "Bidding"
	PhaseBuyStock       = "BuyStock"
	PhasePutBoat        = "PutBoat"
	PhaseDragBoat       = "DragBoat"
	PhaseInvest         = "Invest"
	PhaseCastDice       = "CastDice"
	PhasePiratePlunder  = "PiratePlunder"
	PhaseDecideTickFail = "DecideTickFail"
	PhasePostDrag       = "PostDrag"
	PhaseSettle         = "Settle"
)

var ColorString = map[int]string{
	CoffeeColor:  "coffee",
	SilkColor:    "silk",
	GinsengColor: "ginseng",
	JadeColor:    "jade",
}

var Colors = []int{CoffeeColor, SilkColor, GinsengColor, JadeColor}

var StringColor = map[string]int{
	"coffee":  CoffeeColor,
	"silk":    SilkColor,
	"ginseng": GinsengColor,
	"jade":    JadeColor,
}

var ColorVend = map[int]int{
	CoffeeColor:  24,
	SilkColor:    30,
	GinsengColor: 18,
	JadeColor:    36,
}

var StockPriceNext = map[int]int{
	-1: 0,
	0:  5,
	5:  10,
	10: 20,
	20: 30,
}

type ManilaSpot struct {
	name        string
	taken       string
	price       int
	award       int
	onboard     bool
	isPassenger bool
}

func (self *ManilaSpot) String() string {
	return fmt.Sprintf("\n      {\"SpotName\": \"%-8s\", \"Taken\": \"%10s\", \"Price\": %2d, \"Award\": %2d, \"Onboard\": %5t}", self.name, self.taken, self.price, self.award, self.onboard)
}

func (self *ManilaSpot) GetTaken() string {
	return self.taken
}

func (self *ManilaSpot) GetIsPassenger() bool {
	return self.isPassenger
}

func (self *ManilaSpot) SetIsPassenger(isPassenger bool) {
	self.isPassenger = isPassenger
}

func (self *ManilaSpot) GetName() string {
	return self.name
}

func (self *ManilaSpot) GetPrice() int {
	return self.price
}
func (self *ManilaSpot) GetAward() int {
	return self.award
}

func (self *ManilaSpot) GetOnboard() bool {
	return self.onboard
}

func (self *ManilaSpot) SetTaken(name string) {
	self.taken = name
}

func (self *ManilaSpot) SetPrice(price int) {
	self.price = price
}

func (self *ManilaSpot) SetAward(award int) {
	self.award = award
}

func (self *ManilaSpot) SetOnboard(onboard bool) {
	self.onboard = onboard
}

func DeepCopy(mappingOrigin map[string]*ManilaSpot) map[string]*ManilaSpot {
	mapping := map[string]*ManilaSpot{}
	for k, v := range mappingOrigin {
		mapping[k] = v
	}
	return mapping
}
