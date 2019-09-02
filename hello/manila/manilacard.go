package manila

import (
	"hello/baseroom"
)

type ManilaStock baseroom.Card

func (self ManilaStock) New(color int) ManilaStock {
	return ManilaStock{A: color}
}

func (self ManilaStock) GetColor(card ManilaStock) int {
	return card.A
}
