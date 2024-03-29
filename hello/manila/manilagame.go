package manila

import "fmt"

const (
	SilkVend    = 30
	JadeVend    = 36
	CoffeeVend  = 24
	GinsengVend = 18

	EmptyColor   = 0
	CoffeeColor  = 1
	SilkColor    = 2
	GinsengColor = 3
	JadeColor    = 4

	OriginalMoney      = 30
	OriginalDeckNumber = 5

	PhaseBidding      = "Bidding"
	PhaseBuyStock     = "BuyStock"
	PhasePutBoat      = "PutBoat"
	PhaseDragBoat     = "DragBoat"
	PhaseInvest       = "Invest"
	PhaseCastDice     = "CastDice"
	PhasePostDragBoat = "PostDragBoat"
	PhaseSettle       = "Settle"
 
)



type ManilaSpot struct {
	name    string
	taken   string
	price   int
	award   int
	onboard bool
}

func (self *ManilaSpot) String() string {
	return fmt.Sprintf("\n      {\"SpotName\": \"%-8s\", \"Taken\": \"%10s\", \"Price\": %2d, \"Award\": %2d, \"Onboard\": %5t}", self.name, self.taken, self.price, self.award, self.onboard)
}

func (self *ManilaSpot) GetTaken() string {
	return self.taken
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
