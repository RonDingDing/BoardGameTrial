package msg

import (
	"errors"
	"hello/pb3"

	"github.com/golang/protobuf/proto"
)

type Message struct {
	Code    int
	ExData  []byte
	Pb2Byte []byte
}

func (m *Message) Init(code int, exdata []uint8, pb2Byte []uint8) {
	m.Code = code
	m.ExData = exdata
	m.Pb2Byte = pb2Byte
}

func (m *Message) PbString() (string, error) {
	switch m.Code {
	case Mail:
		message := &pb3.Mail{}
		err := proto.Unmarshal(m.Pb2Byte, message)
		if err != nil {
			return "!", err
		}
		return message.String(), nil

	case Mails:
		message := &pb3.Mails{}
		err := proto.Unmarshal(m.Pb2Byte, message)
		if err != nil {
			return "!", err
		}
		return message.String(), nil

	default:
		return "!", errors.New("Can't convert")
	}
}
