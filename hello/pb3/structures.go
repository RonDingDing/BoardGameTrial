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
	GameNum           int
	Mapp              []MappS
	Ship              []int
	PlayerName        []string
	PlayerNumForStart int
	PlayerNumMax      int
	Players           []PlayersS
	RoomNum           int
	Round             int
	Deck              []int
	StockPrice        []int
	Started           bool
	HighestBidder     string
	HighestBidPrice   int
	CurrentPlayer     string
	Phase             string
	CastTime          int
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
	self.GameNum = 0
	self.Mapp = make([]MappS, 0)
	self.PlayerName = make([]string, 0)
	self.PlayerNumForStart = 0
	self.PlayerNumMax = 0
	self.Players = make([]PlayersS, 0)
	self.RoomNum = 0
	self.Round = 0
	self.Deck = make([]int, 4)
	self.StockPrice = make([]int, 4)
	self.Started = false
	self.HighestBidder = ""
	self.HighestBidPrice = 0
	self.CurrentPlayer = ""
	self.Phase = ""
	self.CastTime = 0
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
	Username        string
	RoomNum         int
	HighestBidPrice int
	HighestBidder   string
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
	self.RoomNum = 0
	self.HighestBidPrice = 0
	self.HighestBidder = ""
	return self
}

func (self *BidMsg) New() *BidMsg {
	self.Code = msg.BidMsg
	self.Req = new(BidMsgReq).New()
	self.Ans = new(BidMsgAns).New()
	self.Error = 0
	return self
}

// HandMsg

type HandMsgReq struct {
	Username string
}

type HandMsgAns struct {
	Username string
	Hand     []int
}

type HandMsg struct {
	Code  string
	Req   *HandMsgReq
	Ans   *HandMsgAns
	Error int
}

func (self *HandMsgReq) New() *HandMsgReq {
	self.Username = ""
	return self
}

func (self *HandMsgAns) New() *HandMsgAns {
	self.Username = ""
	self.Hand = make([]int, 0)
	return self
}

func (self *HandMsg) New() *HandMsg {
	self.Code = msg.HandMsg
	self.Req = new(HandMsgReq).New()
	self.Ans = new(HandMsgAns).New()
	self.Error = 0
	return self
}

// BuyStockMsg

type BuyStockMsgReq struct {
	Username string
	Stock    int
}

type BuyStockMsgAns struct {
	Username         string
	RoomNum          int
	RemindOrOperated bool
	Bought           int
	Deck             []int
}

type BuyStockMsg struct {
	Code  string
	Req   *BuyStockMsgReq
	Ans   *BuyStockMsgAns
	Error int
}

func (self *BuyStockMsgReq) New() *BuyStockMsgReq {
	self.Username = ""
	self.Stock = 0
	return self
}

func (self *BuyStockMsgAns) New() *BuyStockMsgAns {
	self.Username = ""
	self.RoomNum = 0
	self.RemindOrOperated = false
	self.Bought = 0
	self.Deck = make([]int, 4)
	return self
}

func (self *BuyStockMsg) New() *BuyStockMsg {
	self.Code = msg.BuyStockMsg
	self.Req = new(BuyStockMsgReq).New()
	self.Ans = new(BuyStockMsgAns).New()
	self.Error = 0
	return self
}

// ChangePhaseMsg

type ChangePhaseMsgReq struct {
}

type ChangePhaseMsgAns struct {
	RoomNum int
	Phase   string
}

type ChangePhaseMsg struct {
	Code  string
	Req   *ChangePhaseMsgReq
	Ans   *ChangePhaseMsgAns
	Error int
}

func (self *ChangePhaseMsgReq) New() *ChangePhaseMsgReq {
	return self
}

func (self *ChangePhaseMsgAns) New() *ChangePhaseMsgAns {
	self.RoomNum = 0
	self.Phase = ""
	return self
}

func (self *ChangePhaseMsg) New() *ChangePhaseMsg {
	self.Code = msg.ChangePhaseMsg
	self.Req = new(ChangePhaseMsgReq).New()
	self.Ans = new(ChangePhaseMsgAns).New()
	self.Error = 0
	return self
}

// PutBoatMsg

type PutBoatMsgReq struct {
	Username string
	RoomNum  int
	Except   int
}

type PutBoatMsgAns struct {
	Username         string
	RemindOrOperated bool
	RoomNum          int
	Except           int
}

type PutBoatMsg struct {
	Code  string
	Req   *PutBoatMsgReq
	Ans   *PutBoatMsgAns
	Error int
}

func (self *PutBoatMsgReq) New() *PutBoatMsgReq {
	self.Username = ""
	self.RoomNum = 0
	self.Except = 0
	return self
}

func (self *PutBoatMsgAns) New() *PutBoatMsgAns {
	self.Username = ""
	self.RoomNum = 0
	self.Except = 0
	self.RemindOrOperated = false
	return self
}

func (self *PutBoatMsg) New() *PutBoatMsg {
	self.Code = msg.PutBoatMsg
	self.Req = new(PutBoatMsgReq).New()
	self.Ans = new(PutBoatMsgAns).New()
	self.Error = 0
	return self
}

// DragBoatMsg

type DragBoatMsgReq struct {
	Username string
	RoomNum  int
	ShipDrag []int
	Phase    string
}

type DragBoatMsgAns struct {
	Username         string
	Phase            string
	RoomNum          int
	RemindOrOperated bool
	Ship             []int
	Dragable         []int
}

type DragBoatMsg struct {
	Code  string
	Req   *DragBoatMsgReq
	Ans   *DragBoatMsgAns
	Error int
}

func (self *DragBoatMsgReq) New() *DragBoatMsgReq {
	self.Username = ""
	self.RoomNum = 0
	self.ShipDrag = make([]int, 0)
	self.Phase = ""
	return self
}

func (self *DragBoatMsgAns) New() *DragBoatMsgAns {
	self.Username = ""
	self.RoomNum = 0
	self.RemindOrOperated = false
	self.Ship = make([]int, 0)
	self.Phase = ""
	self.Dragable = make([]int, 0)
	return self
}

func (self *DragBoatMsg) New() *DragBoatMsg {
	self.Code = msg.DragBoatMsg
	self.Req = new(DragBoatMsgReq).New()
	self.Ans = new(DragBoatMsgAns).New()
	self.Error = 0
	return self
}

// InvestMsg

type InvestMsgReq struct {
	Username string
	RoomNum  int
	Invest   string
}

type InvestMsgAns struct {
	Username         string
	RoomNum          int
	RemindOrOperated bool
	Invest           string
}

type InvestMsg struct {
	Code  string
	Req   *InvestMsgReq
	Ans   *InvestMsgAns
	Error int
}

func (self *InvestMsgReq) New() *InvestMsgReq {
	self.Username = ""
	self.RoomNum = 0
	self.Invest = ""
	return self
}

func (self *InvestMsgAns) New() *InvestMsgAns {
	self.Username = ""
	self.RoomNum = 0
	self.RemindOrOperated = false
	self.Invest = ""
	return self
}

func (self *InvestMsg) New() *InvestMsg {
	self.Code = msg.InvestMsg
	self.Req = new(InvestMsgReq).New()
	self.Ans = new(InvestMsgAns).New()
	self.Error = 0
	return self
}

// DiceMsg
type DiceMsgReq struct {
}

type DiceMsgAns struct {
	RoomNum  int
	Dice     []int
	CastTime int
}

type DiceMsg struct {
	Code  string
	Req   *DiceMsgReq
	Ans   *DiceMsgAns
	Error int
}

func (self *DiceMsgReq) New() *DiceMsgReq {
	return self
}

func (self *DiceMsgAns) New() *DiceMsgAns {
	self.RoomNum = 0
	self.Dice = make([]int, 0)
	self.CastTime = 0
	return self
}

func (self *DiceMsg) New() *DiceMsg {
	self.Code = msg.DiceMsg
	self.Req = new(DiceMsgReq).New()
	self.Ans = new(DiceMsgAns).New()
	self.Error = 0
	return self
}

// PirateMsg
type PirateMsgReq struct {
	RoomNum int
	Pirate  string
	Plunder int
}

type PirateMsgAns struct {
	RoomNum          int
	ShipVacant       []int
	CastTime         int
	Pirate           string
	RemindOrOperated bool
}

type PirateMsg struct {
	Code  string
	Req   *PirateMsgReq
	Ans   *PirateMsgAns
	Error int
}

func (self *PirateMsgReq) New() *PirateMsgReq {
	self.RoomNum = 0
	self.Pirate = ""
	self.Plunder = 0
	return self
}

func (self *PirateMsgAns) New() *PirateMsgAns {
	self.RoomNum = 0
	self.ShipVacant = make([]int, 0)
	self.CastTime = 0
	self.Pirate = ""
	self.RemindOrOperated = false
	return self
}

func (self *PirateMsg) New() *PirateMsg {
	self.Code = msg.PirateMsg
	self.Req = new(PirateMsgReq).New()
	self.Ans = new(PirateMsgAns).New()
	self.Error = 0
	return self
}
