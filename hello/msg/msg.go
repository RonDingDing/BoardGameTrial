package msg

type Message interface {
	Reset()
	New()
	String() string
	ProtoMessage()
	SetExdata(interface{})
	SetAns(interface{})
	ClearExdata()
	SetReq(interface{})
	SetError(int32)
	ToByte() ([]byte, error)
	FromByte(bytes []byte) error
}
