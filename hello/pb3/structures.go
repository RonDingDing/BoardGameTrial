package pb3

type Errors struct {
	Code  string
	Error int
}

type LoginMsgReq struct {
	Username string
	Password string
}

type LoginMsgAns struct {
	Username string
	Gold     int
	Mobile   string
	Email    string
}

type LoginMsg struct {
	Code  string
	Req   *LoginMsgReq
	Ans   *LoginMsgAns
	Error int
}

func (self *LoginMsgReq) New() {
	self.Username = ""
	self.Password = ""
}

func (self *LoginMsgAns) New() {
	self.Username = ""
	self.Gold = 0
	self.Mobile = ""
	self.Email = ""
}

func (self *LoginMsg) New() {
	self.Code = ""
	self.Req = new(LoginMsgReq)
	self.Ans = new(LoginMsgAns)
	self.Error = 0
}

type SignUpMsgReq struct {
	Username string
	Password string
	Mobile   string
	Email    string
}

type SignUpMsgAns struct {
	Username string
	Gold     int
	Mobile   string
	Email    string
}

type SignUpMsg struct {
	Code  string
	Req   *SignUpMsgReq
	Ans   *SignUpMsgAns
	Error int
}

func (self *SignUpMsgReq) New() {
	self.Username = ""
	self.Password = ""
	self.Mobile = ""
	self.Email = ""
}

func (self *SignUpMsgAns) New() {
	self.Username = ""
	self.Gold = 0
	self.Mobile = ""
	self.Email = ""
}

func (self *SignUpMsg) New() {
	self.Code = ""
	self.Req = new(SignUpMsgReq)
	self.Ans = new(SignUpMsgAns)
	self.Error = 0
}
