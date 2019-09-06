package manila

import (
	"hello/baseroom"
)

type ManilaStock struct{ card baseroom.Card }

func (self ManilaStock) New(color int) ManilaStock {
	stock := ManilaStock{}
	stock.card.SetA(color)
	return stock
}
func (self *ManilaStock) SetColor(color int) {
	self.card.SetA(color)
}

func (self *ManilaStock) GetColor(card ManilaStock) int {
	return self.card.GetA()
}
