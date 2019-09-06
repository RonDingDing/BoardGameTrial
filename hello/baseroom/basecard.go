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

func (self *Card) SetB(b int) {
	self.b = b
}

func (self *Card) GetB() int {
	return self.b
}

func (self *Card) SetC(c int) {
	self.c = c
}

func (self *Card) GetC() int {
	return self.c
}

func (self *Card) SetD(d int) {
	self.d = d
}

func (self *Card) GetD() int {
	return self.d
}
