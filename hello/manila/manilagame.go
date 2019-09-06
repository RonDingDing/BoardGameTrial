package manila

const (
	SilkVend    = 30
	JadeVend    = 36
	CoffeeVend  = 24
	GinsengVend = 18
)

var (
	SilkDice    = 0
	JadeDice    = 0
	CoffeeDice  = 0
	GinsengDice = 0

	SilkPos    = 0
	JadePos    = 0
	CoffeePos  = 0
	GinsengPos = 0

	MappingOrigin = map[string]ManilaSpot{
		"1Tick":   ManilaSpot{"1Tick", "", 4, 6, true},
		"2Tick":   ManilaSpot{"2Tick", "", 3, 8, true},
		"3Tick":   ManilaSpot{"3Tick", "", 2, 15, true},
		"1Fail":   ManilaSpot{"1Fail", "", 4, 6, true},
		"2Fail":   ManilaSpot{"2Fail", "", 3, 8, true},
		"3Fail":   ManilaSpot{"3Fail", "", 2, 15, true},
		"1pirate": ManilaSpot{"1pirate", "", 5, 0, true},
		"2pirate": ManilaSpot{"2pirate", "", 5, 0, true},
		"1drag":   ManilaSpot{"1drag", "", 2, 0, true},
		"2drag":   ManilaSpot{"2drag", "", 5, 0, true},
		"repair":  ManilaSpot{"repair", "", 0, 10, true},

		"1silk": ManilaSpot{"1silk", "", 3, 0, false},
		"2silk": ManilaSpot{"2silk", "", 4, 0, false},
		"3silk": ManilaSpot{"3silk", "", 5, 0, false},

		"1jade": ManilaSpot{"1jade", "", 3, 0, false},
		"2jade": ManilaSpot{"2jade", "", 4, 0, false},
		"3jade": ManilaSpot{"3jade", "", 5, 0, false},
		"4jade": ManilaSpot{"4jade", "", 5, 0, false},

		"1ginseng": ManilaSpot{"1ginseng", "", 1, 0, false},
		"2ginseng": ManilaSpot{"2ginseng", "", 2, 0, false},
		"3ginseng": ManilaSpot{"3ginseng", "", 3, 0, false},

		"1coffee": ManilaSpot{"1coffee", "", 2, 0, false},
		"2coffee": ManilaSpot{"2coffee", "", 3, 0, false},
		"3coffee": ManilaSpot{"3coffee", "", 4, 0, false},
	}
)

type ManilaSpot struct {
	name    string
	taken   string
	price   int
	award   int
	onboard bool
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

func DeepCopy(mappingOrigin map[string]ManilaSpot) map[string]ManilaSpot {
	mapping := map[string]ManilaSpot{}
	for k, v := range mappingOrigin {
		mapping[k] = v
	}
	return mapping
}
