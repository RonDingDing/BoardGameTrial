package pb3

func (m *Bail_REQ) New() {
	m.Username = ""
	m.Password = ""

}
func (m *Bail_ANS_AB) New() {
	m.M = ""

}
func (m *Bail_ANS) New() {
	m.Password = ""
	m.Ab = new(Bail_ANS_AB)

}
func (m *Bail) New() {
	m.Code = 0
	m.Exdata = []byte{'{', '}'}
	m.Req = new(Bail_REQ)
	m.Ans = new(Bail_ANS)
	m.Error = 0

}
