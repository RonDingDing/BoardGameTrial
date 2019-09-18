package manila

type ManilaStock struct {
	color int
}

func (self *ManilaStock) New(color int) *ManilaStock {
	self.color = color
	return self
}

func (self *ManilaStock) GetColor(card ManilaStock) int {
	return self.color
}
