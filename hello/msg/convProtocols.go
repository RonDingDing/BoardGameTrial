// conv_protocols.go : 通信协议(自动生成)
// !!!该文件自动生成，请勿直接编辑!!!

package msg

// 协议码
const (
	Errors            = "000" // 获取游戏版本信息
	LoginMsg          = "001"
	SignUpMsg         = "002"
	EnterRoomMsg      = "003"
	ReadyMsg          = "004"
	RoomDetailMsg     = "005"
	GameStartMsg      = "006"
	BidMsg            = "007"
	HandMsg           = "008"
	BuyStockMsg       = "009"
	ChangePhaseMsg    = "010"
	PutBoatMsg        = "011"
	DragBoatMsg       = "012"
	InvestMsg         = "013"
	DiceMsg           = "014"
	PirateMsg         = "015"
	DecideTickFailMsg = "016"
	PostDragMsg       = "017"

	NorAlreadyInRoom            = 1
	NorNewEntered               = 2
	ErrNormal                   = 0
	ErrNoHandler                = -1
	ErrUserExit                 = -2
	ErrUserNotExit              = -3
	ErrCannotEnterRoom          = -4
	ErrNoSuchPlayer             = -5
	ErrCannotExitRoom           = -6
	ErrGameStarted              = -7
	ErrUserIsNotInRoom          = -8
	ErrFailedEntering           = -9
	ErrNotEnoughGameMoney       = -10
	ErrUserIsNotCaptain         = -11
	ErrNotEnoughStock           = -12
	ErrInvalidInvestPoint       = -13
	ErrInvestPointTaken         = -14
	ErrUserIsNotSupposedDragger = -15

	LoungeNum = 0
)
