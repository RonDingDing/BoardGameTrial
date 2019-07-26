package main

import (
	"bufio"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"sort"
	"strings"
)

type Protoinfo struct {
	code      string
	name      string
	packages  string
	pkName    string
	protoName string
	route     string
	comment   string
}

func (p *Protoinfo) init(code string, name string, packages string, protofile string, comment string) {
	p.code = code
	p.name = name
	p.packages = strings.ToUpper(string(packages[0])) + packages[1:]
	p.pkName = p.packages + "." + name
	p.protoName = protofile + ".pb." + name
	p.route = protofile
	p.comment = comment
}

type ProtoSlice []*Protoinfo

func (s ProtoSlice) Len() int           { return len(s) }
func (s ProtoSlice) Swap(i, j int)      { s[i], s[j] = s[j], s[i] }
func (s ProtoSlice) Less(i, j int) bool { return s[i].code < s[j].code }

// 以上三个函数实现了sort.Sort()的接口
/////////////////////////////////////////////////////////////////

func exeSysCommand(cmdStr string) string {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("cmd", "-c", cmdStr)
	} else {
		cmd = exec.Command("sh", "-c", cmdStr)
	}
	opBytes, err := cmd.Output()
	if err != nil {
		fmt.Println(err)
		return ""
	}
	return string(opBytes)
}

func readProtoDir() ProtoSlice {
	// 读取Proto中的文件
	files, err := ioutil.ReadDir("../proto/")
	if err != nil {
		log.Fatal(err)
	}
	var protoFiles []string
	for _, file := range files {
		if !file.IsDir() && filepath.Ext(file.Name()) == ".proto" {
			protoFiles = append(protoFiles, filepath.Base(file.Name()))
		}
	}
	var protos ProtoSlice
	for _, eachFile := range protoFiles {
		f, err := os.Open(eachFile)
		if err != nil {
			log.Fatal(err)
		}

		exeSysCommand("protoc --go_out=../pb3 " + eachFile)
		fmt.Println("protoc --go_out=../pb3 " + eachFile)
		buf := bufio.NewReader(f)
		for {
			line, err := buf.ReadString('\n')
			if err == io.EOF {
				break
			} else if err != nil {
				log.Fatal(err)
			}

			if strings.HasPrefix(line, "message") {
				linef := strings.Replace(line, "  ", " ", -1)
				packages := strings.Split(eachFile, ".")[0]
				line := strings.TrimSpace(linef)
				values := strings.Split(line, " ")
				code := string(values[3])

				name := strings.TrimSpace(values[1])
				comment := strings.TrimSpace(values[4])
				protoPointer := new(Protoinfo)
				protoPointer.init(code, name, packages, eachFile, comment)
				protos = append(protos, protoPointer)
			}
		}
	}
	sort.Sort(protos)
	return protos
}

func writeGoFile(protos ProtoSlice) {

	outputGo, err := os.OpenFile("../msg/conv_protocols.go", os.O_WRONLY|os.O_TRUNC|os.O_CREATE, 0777)
	if err != nil {
		log.Fatal(err)
	}
	outputGo.Write([]byte("// conv_protocols.go : 通信协议(自动生成)\n "))
	outputGo.Write([]byte("// !!!该文件自动生成，请勿直接编辑!!!\n\n"))
	outputGo.Write([]byte("package msg\n\n"))
	outputGo.Write([]byte("import (\n    \"hello/pb3\"\n     \n)"))

	outputGo.Write([]byte("\n    // 协议码\n"))
	outputGo.Write([]byte("const (\n"))
	for _, proto := range protos {
		outputGo.Write([]byte(fmt.Sprintf("    %-32s = %s\t// %s\n", proto.name, proto.code, proto.comment)))
	}
	outputGo.Write([]byte(")\n\n\n"))

	outputGo.Write([]byte("// 协议对照\n"))
	outputGo.Write([]byte("var PROTOS map[int]interface{} = map[int]interface{} {\n"))
	for _, proto := range protos {
		outputGo.Write([]byte(fmt.Sprintf("%-4s%-28s : new(pb3.%s) ,\n", "", proto.name, proto.name)))
	}
	outputGo.Write([]byte("}\n\n"))

	outputGo.Write([]byte("// 协议名称\n"))
	outputGo.Write([]byte("var PROTONAMES map[int]string = map[int]string {\n"))

	for _, proto := range protos {
		outputGo.Write([]byte(fmt.Sprintf("%-4s%-28s :  \"%s.%s\" ,\n", "", proto.name, proto.packages, proto.name)))
	}
	outputGo.Write([]byte("}\n\n"))
	outputGo.Close()
}

func writepbFile(protos ProtoSlice) {

	for _, protoFiles := range protos {
		outputGo, err := os.OpenFile(fmt.Sprintf("../pb3/%s.pb2.go", strings.ToLower(protoFiles.name)), os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0777)
		if err != nil {
			log.Fatal(err)
		}
		outputGo.Write([]byte(fmt.Sprintf(`
package pb3
import (	
	"bytes"
	"encoding/binary"
	"encoding/json"
	"errors"

	"github.com/golang/protobuf/proto"
)
func (m *%s) New() { 
	m.Code = %s
	m.Exdata = []byte{123, 125} 	 
	m.Req = nil
	m.Ans = nil
	m.Error = 0
}
`, protoFiles.name, protoFiles.code)))

		outputGo.Write([]byte(fmt.Sprintf(`
func (m *%s) SetExdata(goObject interface{}) error {
	m.Code = %s
	exdata, err := json.Marshal(goObject)
	if err != nil {
		return err
	}
	m.Exdata = exdata
	return nil
}
`, protoFiles.name, protoFiles.code)))

		outputGo.Write([]byte(fmt.Sprintf(`
func (m *%s) ClearExdata() {	 
	m.Code = %s
	m.Exdata = []byte{123, 125} 
}
`, protoFiles.name, protoFiles.code)))

		outputGo.Write([]byte(fmt.Sprintf(`
func (m *%s) SetReq(goObject interface{}) {
	m.Code = %s
	switch goObject.(type) {
	case *%s_REQ:
		m.Req = goObject.(*%s_REQ)
	default:	 
		panic("Can't set %s Req!")
	}
}
`, protoFiles.name, protoFiles.code, protoFiles.name, protoFiles.name, protoFiles.name)))

		outputGo.Write([]byte(fmt.Sprintf(`
func (m *%s) SetAns(goObject interface{}) {
	m.Code = %s
	switch goObject.(type) {
	case *%s_ANS:
		m.Ans = goObject.(*%s_ANS)
	default:		 
		panic("Can't set %s Ans!")
	}
}
`, protoFiles.name, protoFiles.code, protoFiles.name, protoFiles.name, protoFiles.name)))

		outputGo.Write([]byte(fmt.Sprintf(`
func (m *%s) SetError(errcode int32) {
	m.Code = %s
	m.Error = errcode
}
`, protoFiles.name, protoFiles.code)))

		outputGo.Write([]byte(fmt.Sprintf(`
func (m *%s) ToByte() ([]byte, error) {
	realBytes, err := proto.Marshal(m)
	buf := bytes.NewBuffer(make([]byte, 0))
	binary.Write(buf, binary.LittleEndian, int32(m.Code))           // 以小端字节序写入Code，默认四字节（2 ^ (8*4) 取值范围够用了）
	binary.Write(buf, binary.LittleEndian, int32(len(realBytes)+8)) // 写入整个字节的长度，方便校验是否丢包
	buf.Write(realBytes)
	return buf.Bytes(), err
	// return realBytes, err 
}
`, protoFiles.name)))

		outputGo.Write([]byte(fmt.Sprintf(`
func (m *%s) FromByte(bytes []byte) error {
	code, _, msgByte, err := SplitByte(bytes)
	if err != nil {
		return err
	}
	if code != m.Code {
		return errors.New("No good bytes for %s")
	}
	return proto.Unmarshal(msgByte, m)
	// return proto.Unmarshal(bytes, m)
}
`, protoFiles.name, protoFiles.name)))
		outputGo.Close()
	}
}

func writeDispacherFile(protos ProtoSlice) {
	outputGo, err := os.OpenFile("../dispatcher/dispatch.go", os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0777)
	if err != nil {
		log.Fatal(err)
	}

	outputGo.Write([]byte(fmt.Sprintf(`package dispatcher

import (
	"errors"
	"hello/msg"

	"github.com/gorilla/websocket"
)	
	`)))
	outputGo.Write([]byte(fmt.Sprintf(`
func Dispatch(code int32, msgByte []byte, connection *websocket.Conn) error {
	answer := false
	switch code {`)))
	for _, protoFiles := range protos {
		fmt.Println(protoFiles)
		outputGo.Write([]byte(fmt.Sprintf(`
	case msg.%s:
		answer = handle%s(msgByte, connection)`, protoFiles.name, protoFiles.name)))
	}

	outputGo.Write([]byte(fmt.Sprintf(`
    }
	if answer == false {
		return errors.New("No handler for this type of message")
	}
	return nil
}
`)))

	for _, protoFiles := range protos {
		outputGo.Write([]byte(fmt.Sprintf(`
func handle%s(msgByte []byte, connection *websocket.Conn) bool {
	
	return true
}		
`, protoFiles.name)))

	}
	outputGo.Close()
}

func main() {
	protos := readProtoDir()
	writeGoFile(protos)
	writepbFile(protos)
	writeDispacherFile(protos)

}
