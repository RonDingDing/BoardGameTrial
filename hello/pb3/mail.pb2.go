
package pb3
import (	
	"bytes"
	"encoding/binary"
	"encoding/json"
	"errors"

	"github.com/golang/protobuf/proto"
)
func (m *Mail) New() { 
	m.Code = 100
	m.Exdata = []byte{123, 125} 	 
	m.Req = nil
	m.Ans = nil
	m.Error = 0
}

func (m *Mail) SetExdata(goObject interface{}) error {
	m.Code = 100
	exdata, err := json.Marshal(goObject)
	if err != nil {
		return err
	}
	m.Exdata = exdata
	return nil
}

func (m *Mail) ClearExdata() {	 
	m.Code = 100
	m.Exdata = []byte{123, 125} 
}

func (m *Mail) SetReq(goObject interface{}) {
	m.Code = 100
	switch goObject.(type) {
	case *Mail_REQ:
		m.Req = goObject.(*Mail_REQ)
	default:	 
		panic("Can't set Mail Req!")
	}
}

func (m *Mail) SetAns(goObject interface{}) {
	m.Code = 100
	switch goObject.(type) {
	case *Mail_ANS:
		m.Ans = goObject.(*Mail_ANS)
	default:		 
		panic("Can't set Mail Ans!")
	}
}

func (m *Mail) SetError(errcode int32) {
	m.Code = 100
	m.Error = errcode
}

func (m *Mail) ToByte() ([]byte, error) {
	realBytes, err := proto.Marshal(m)
	buf := bytes.NewBuffer(make([]byte, 0))
	binary.Write(buf, binary.LittleEndian, int32(m.Code))           // 以小端字节序写入Code，默认四字节（2 ^ (8*4) 取值范围够用了）
	binary.Write(buf, binary.LittleEndian, int32(len(realBytes)+8)) // 写入整个字节的长度，方便校验是否丢包
	buf.Write(realBytes)
	return buf.Bytes(), err 
}

func (m *Mail) FromByte(bytes []byte) error {
	code, _, msgByte, err := SplitByte(bytes)
	if err != nil {
		return err
	}
	if code != m.Code {
		return errors.New("No good bytes for Mail")
	}
	return proto.Unmarshal(msgByte, m)
}
