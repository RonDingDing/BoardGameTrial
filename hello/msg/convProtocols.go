// conv_protocols.go : 通信协议(自动生成)
// !!!该文件自动生成，请勿直接编辑!!!

package msg

// 协议码
const (
	Errors    = "000" // 获取游戏版本信息
	LoginMsg  = "001"
	SignUpMsg = "002"

	ErrNoHandler = -1
	ErrUserExit  = -2
)
