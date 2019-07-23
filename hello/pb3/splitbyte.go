package pb3

import (
	"bytes"
	"encoding/binary"
	"errors"
)

func SplitByte(byteWithHead []byte) (int32, int32, []byte, error) {
	codeByte := []byte(byteWithHead[:4])
	lengthByte := []byte(byteWithHead[4:8])
	msgByte := []byte(byteWithHead[8:])
	binBuf := bytes.NewBuffer(codeByte)
	// 读取code
	var code int32
	binary.Read(binBuf, binary.LittleEndian, &code)
	lenBuf := bytes.NewBuffer(lengthByte)

	// 读取长度，防止丢包
	var length int32
	binary.Read(lenBuf, binary.LittleEndian, &length)
	if int(length) != len(byteWithHead) {
		return 0, 0, nil, errors.New("Loss of packet")
	}

	return code, length, msgByte, nil
}
