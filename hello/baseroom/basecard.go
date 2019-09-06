package baseroom

type Card struct {
	a int
	b int
	c int
	d int
}

func (self *Card) SetA(a int) {
	self.a = a
}

func (self *Card) GetA() int {
	return self.a
}
