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

type PlayersS struct {
	Name   string
	Money  int
	Stock  []int
	Online bool
	Seat   int
}

type MappS struct {
	Name    string
	Taken   string
	Price   int
	Award   int
	Onboard bool
}

type EnterRoomMsgAns struct {
	RoomNum           int
	GameNum           int
	Started           bool
	PlayerNumForStart int
	PlayerNumMax      int
	PlayerName        []string
	Players           []PlayersS
	SilkDeck          int
	CoffeeDeck        int
	GinsengDeck       int
	JadeDeck          int
	Round             int
	Mapp              []MappS
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

func (self *PlayersS) New() *PlayersS {
	self.Name = ""
	self.Money = 0
	self.Stock = make([]int, 0)
	self.Online = false
	self.Seat = 0
	return self
}

func (self *MappS) New() *MappS {
	self.Name = ""
	self.Taken = ""
	self.Price = 0
	self.Award = 0
	self.Onboard = false
	return self
}

func (self *EnterRoomMsgAns) New() *EnterRoomMsgAns {
	self.RoomNum = 0
	self.GameNum = 0
	self.Started = false
	self.PlayerNumForStart = 0
	self.PlayerNumMax = 0
	self.PlayerName = make([]string, 0)
	self.Players = make([]PlayersS, 0)
	self.SilkDeck = 0
	self.CoffeeDeck = 0
	self.GinsengDeck = 0
	self.JadeDeck = 0
	self.Round = 0
	self.Mapp = make([]MappS, 0)
	return self
}

func (self *EnterRoomMsg) New() *EnterRoomMsg {
	self.Code = ""
	self.Req = new(EnterRoomMsgReq).New()
	self.Ans = new(EnterRoomMsgAns).New()
	self.Error = 0
	return self
}
