package pb3

type Errors struct {
	Code  string
	Error int
}

////////

type LoginMsgReq struct {
	Username string
	Password string
}

type LoginMsgAns struct {
	Username string
	Gold     int
	Mobile   string
	Email    string
	RoomNum  int
}

type LoginMsg struct {
	Code  string
	Req   *LoginMsgReq
	Ans   *LoginMsgAns
	Error int
}

func (self *LoginMsgReq) New() *LoginMsgReq {
	self.Username = ""
	self.Password = ""
	return self
}

func (self *LoginMsgAns) New() *LoginMsgAns {
	self.Username = ""
	self.Gold = 0
	self.Mobile = ""
	self.Email = ""
	self.RoomNum = 0
	return self
}

func (self *LoginMsg) New() *LoginMsg {
	self.Code = ""
	self.Req = new(LoginMsgReq).New()
	self.Ans = new(LoginMsgAns).New()
	self.Error = 0
	return self
}

////////

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

func (self *SignUpMsgReq) New() *SignUpMsgReq {
	self.Username = ""
	self.Password = ""
	self.Mobile = ""
	self.Email = ""
	return self
}

func (self *SignUpMsgAns) New() *SignUpMsgAns {
	self.Username = ""
	self.Gold = 0
	self.Mobile = ""
	self.Email = ""
	return self
}

func (self *SignUpMsg) New() *SignUpMsg {
	self.Code = ""
	self.Req = new(SignUpMsgReq).New()
	self.Ans = new(SignUpMsgAns).New()
	self.Error = 0
	return self
}

////

type EnterRoomMsgReq struct {
	Username string
	RoomNum  int
}

type EnterRoomMsgAns struct {
	RoomNum int
}

type EnterRoomMsg struct {
	Code  string
	Req   *EnterRoomMsgReq
	Ans   *EnterRoomMsgAns
	Error int
}

func (self *EnterRoomMsgReq) New() *EnterRoomMsgReq {
	self.Username = ""
	self.RoomNum = 0
	return self
}

func (self *EnterRoomMsgAns) New() *EnterRoomMsgAns {
	self.RoomNum = 0
	return self
}

func (self *EnterRoomMsg) New() *EnterRoomMsg {
	self.Code = ""
	self.Req = new(EnterRoomMsgReq).New()
	self.Ans = new(EnterRoomMsgAns).New()
	self.Error = 0
	return self
}
