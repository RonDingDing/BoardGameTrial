package pb3

import (
	"hello/msg"
)

// Errors
type Errors struct {
	Code  string
	Error int
}

// LoginMsg

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
	self.Code = msg.LoginMsg
	self.Req = new(LoginMsgReq).New()
	self.Ans = new(LoginMsgAns).New()
	self.Error = 0
	return self
}

// SignUpMsg

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
	self.Code = msg.SignUpMsg
	self.Req = new(SignUpMsgReq).New()
	self.Ans = new(SignUpMsgAns).New()
	self.Error = 0
	return self
}

// EnterRoomMsg

type EnterRoomMsgReq struct {
	Username string
	RoomNum  int
}

type EnterRoomMsgAns struct {
	GameNum int
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
	self.GameNum = 0
	self.RoomNum = 0
	return self
}

func (self *EnterRoomMsg) New() *EnterRoomMsg {
	self.Code = msg.EnterRoomMsg
	self.Req = new(EnterRoomMsgReq).New()
	self.Ans = new(EnterRoomMsgAns).New()
	self.Error = 0
	return self
}

// ReadyMsg

type ReadyMsgReq struct {
	Username string
	Ready    bool
}

type ReadyMsgAns struct {
	Username string
	Ready    bool
	RoomNum  int
}

type ReadyMsg struct {
	Code  string
	Req   *ReadyMsgReq
	Ans   *ReadyMsgAns
	Error int
}

func (self *ReadyMsgReq) New() *ReadyMsgReq {
	self.Username = ""
	self.Ready = false
	return self
}

func (self *ReadyMsgAns) New() *ReadyMsgAns {
	self.Username = ""
	self.Ready = false
	self.RoomNum = 0
	return self
}

func (self *ReadyMsg) New() *ReadyMsg {
	self.Code = msg.ReadyMsg
	self.Req = new(ReadyMsgReq).New()
	self.Ans = new(ReadyMsgAns).New()
	self.Error = 0
	return self
}

// RoomDetailMsg
type RoomDetailMsgReq struct {
}

type MappS struct {
	Name    string
	Taken   string
	Price   int
	Award   int
	Onboard bool
}

type PlayersS struct {
	Money  int
	Name   string
	Online bool
	Stock  int
	Seat   int
	Ready  bool
	Canbid bool
}

type RoomDetailMsgAns struct {
	CoffeeDeck        int
	GameNum           int
	GinsengDeck       int
	JadeDeck          int
	Mapp              []MappS
	PlayerName        []string
	PlayerNumForStart int
	PlayerNumMax      int
	Players           []PlayersS
	RoomNum           int
	Round             int
	SilkDeck          int
	Started           bool
	HighestBidder     string
}

type RoomDetailMsg struct {
	Code  string
	Req   *RoomDetailMsgReq
	Ans   *RoomDetailMsgAns
	Error int
}

func (self *RoomDetailMsgReq) New() *RoomDetailMsgReq {
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

func (self *PlayersS) New() *PlayersS {
	self.Money = 0
	self.Name = ""
	self.Online = false
	self.Stock = 0
	self.Seat = 0
	self.Ready = false
	self.Canbid = true
	return self
}

func (self *RoomDetailMsgAns) New() *RoomDetailMsgAns {
	self.CoffeeDeck = 0
	self.GameNum = 0
	self.GinsengDeck = 0
	self.JadeDeck = 0
	self.Mapp = make([]MappS, 0)
	self.PlayerName = make([]string, 0)
	self.PlayerNumForStart = 0
	self.PlayerNumMax = 0
	self.Players = make([]PlayersS, 0)
	self.RoomNum = 0
	self.Round = 0
	self.SilkDeck = 0
	self.Started = false
	self.HighestBidder = ""
	return self
}

func (self *RoomDetailMsg) New() *RoomDetailMsg {
	self.Code = msg.RoomDetailMsg
	self.Req = new(RoomDetailMsgReq).New()
	self.Ans = new(RoomDetailMsgAns).New()
	self.Error = 0
	return self
}

// GameStartMsg
type GameStartMsgReq struct {
}

type GameStartMsgAns struct {
	RoomNum int
}

type GameStartMsg struct {
	Code  string
	Req   *GameStartMsgReq
	Ans   *GameStartMsgAns
	Error int
}

func (self *GameStartMsgReq) New() *GameStartMsgReq {
	return self
}

func (self *GameStartMsgAns) New() *GameStartMsgAns {
	self.RoomNum = 0
	return self
}

func (self *GameStartMsg) New() *GameStartMsg {
	self.Code = msg.GameStartMsg
	self.Req = new(GameStartMsgReq).New()
	self.Ans = new(GameStartMsgAns).New()
	self.Error = 0
	return self
}

// BidMsg

type BidMsgReq struct {
	Username string
	Bid      int
}

type BidMsgAns struct {
	Username string
}

type BidMsg struct {
	Code  string
	Req   *BidMsgReq
	Ans   *BidMsgAns
	Error int
}

func (self *BidMsgReq) New() *BidMsgReq {
	self.Username = ""
	self.Bid = 0
	return self
}

func (self *BidMsgAns) New() *BidMsgAns {
	self.Username = ""
	return self
}

func (self *BidMsg) New() *BidMsg {
	self.Code = msg.BidMsg
	self.Req = new(BidMsgReq).New()
	self.Ans = new(BidMsgAns).New()
	self.Error = 0
	return self
}
