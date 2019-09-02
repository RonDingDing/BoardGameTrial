package main

import (
	"bufio"

	"fmt"
	"hello/stack"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"runtime"
	"sort"
	"strings"
	"unicode"
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
	p.packages = strings.ToLower(packages)
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

var basePath = ".."

func exeSysCommand(cmdStr string) string {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		commands := strings.Split(cmdStr, " ")[0]
		otherCmd := strings.Split(cmdStr, " ")[1:]
		cmd = exec.Command(commands, otherCmd...)
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
	files, err := ioutil.ReadDir(basePath + "/proto/")
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
		packages := "default"
		comment := ""
		buf := bufio.NewReader(f)
		for {
			line, err := buf.ReadString('\n')
			if err == io.EOF {
				break
			} else if err != nil {
				log.Fatal(err)
			}
			if strings.HasPrefix(line, "package") {
				reg := regexp.MustCompile(` [a-zA-Z0-9_]+;`)
				packagesStr := reg.FindString(line)
				packages = strings.Trim(strings.Trim(packagesStr, " "), ";")

			} else if strings.HasPrefix(line, "message") {
				linef := strings.Replace(line, "  ", " ", -1)
				line := strings.TrimSpace(linef)
				values := strings.Split(line, " ")
				code := string(values[3])
				name := strings.TrimSpace(values[1])
				if len(values) >= 5 {
					comment = strings.TrimSpace(values[4])
				}
				protoPointer := new(Protoinfo)
				protoPointer.init(code, name, packages, eachFile, comment)
				protos = append(protos, protoPointer)
			}
		}
	}
	sort.Sort(protos)

	for _, p := range protos {
		createFolder(fmt.Sprintf(basePath+"/%s", p.packages))
		exeSysCommand("protoc --go_out=" + basePath + fmt.Sprintf("/%s ", p.packages) + p.route)
		fmt.Println("protoc --go_out=" + basePath + fmt.Sprintf("/%s ", p.packages) + p.route)
	}

	return protos
}

func writeProtocolFile(protos ProtoSlice) {

	outputGo, err := os.OpenFile(basePath+"/msg/convProtocols.go", os.O_WRONLY|os.O_TRUNC|os.O_CREATE, 0777)
	if err != nil {
		log.Fatal(err)
	}
	s := ""
	s += "// conv_protocols.go : 通信协议(自动生成)\n "
	s += "// !!!该文件自动生成，请勿直接编辑!!!\n\n"
	s += "package msg\n\n"
	for _, proto := range protos {
		s += fmt.Sprintf("import (\n    \"hello/%s\"\n     \n)", proto.packages)
	}
	s += "\n    // 协议码\n"
	s += "const (\n"
	for _, proto := range protos {
		s += fmt.Sprintf("    %-32s = %s\t// %s\n", proto.name, proto.code, proto.comment)
	}
	s += ")\n\n\n"

	s += "// 协议对照\n"
	s += "var PROTOS map[int]interface{} = map[int]interface{} {\n"
	for _, proto := range protos {
		s += fmt.Sprintf("%-4s%-28s : new(%s.%s) ,\n", "", proto.name, proto.packages, proto.name)
	}
	s += "}\n\n"

	s += "// 协议名称\n"
	s += "var PROTONAMES map[int]string = map[int]string {\n"

	for _, proto := range protos {
		s += fmt.Sprintf("%-4s%-28s :  \"%s.%s\" ,\n", "", proto.name, proto.packages, proto.name)
	}
	s += "}\n\n"
	outputGo.Write([]byte(s))
	outputGo.Close()
}

var typeMap = map[string]string{
	"double":   "float64",
	"float":    "float32",
	"int32":    "int32",
	"int64":    "int64",
	"uint32":   "uint32",
	"uint64":   "uint64",
	"sint32":   "int32",
	"sint64":   "int64",
	"fixed32":  "uint32",
	"fixed64":  "uint64",
	"sfixed32": "int32",
	"sfixed64": "int64",
	"bool":     "bool",
	"string":   "string",
	"bytes":    "[]byte",
}

func strFirstToUpper(str string) string {
	for i, v := range str {
		return string(unicode.ToUpper(v)) + str[i+1:]
	}
	return ""
}

func strFirstToLower(str string) string {
	for i, v := range str {
		return string(unicode.ToLower(v)) + str[i+1:]
	}
	return ""
}

func writePb2GoFile(funcList []function, fileName string, packaging string) {
	var defaultValue = map[string]string{
		"float64": "0",
		"float32": "0",
		"int32":   "0",
		"int64":   "0",
		"uint32":  "0",
		"uint64":  "0",
		"bool":    "false",
		"string":  "\"\"",
		"[]byte":  "[]byte{'{', '}'}",

		"[]float64": "make([]float64, 0)",
		"[]float32": "make([]float32, 0)",
		"[]int32":   "make([]int32, 0)",
		"[]int64":   "make([]int64, 0)",
		"[]uint32":  "make([]uint32, 0)",
		"[]uint64":  "make([]uint64, 0)",
		"[]bool":    "make([]bool, 0)",
		"[]string":  "make([]string, 0)",
		"[][]byte":  "make([][]byte, 0)",
	}
	outputGo, err := os.OpenFile(basePath+fmt.Sprintf("/%s/%s.pb2.go", packaging, strings.ToLower(fileName)), os.O_RDONLY|os.O_CREATE|os.O_TRUNC, 0777)
	if err != nil {
		log.Fatal(err)
	}
	s := ""
	s += fmt.Sprintf("package %s;\n", packaging)
	for _, fun := range funcList {
		// New() 方法
		funcName := fun.funcName
		paramsArray := fun.paramsArray
		s += fmt.Sprintf("\n\nfunc (self *%s) New() {\n", funcName)
		for _, p := range paramsArray {
			paramName, typing := strings.Split(p, " ")[0], strings.Split(p, " ")[1]
			paramName = strFirstToUpper(paramName)
			dValue, ok := defaultValue[typing]
			if ok {
				s += fmt.Sprintf("    self.%s = %s\n", paramName, dValue)
			} else {
				s += fmt.Sprintf("    self.%s = new(%s)\n", paramName, strings.Replace(typing, "*", "", -1))
			}
		}
		s += fmt.Sprintf("}")

		// Clear() 方法
		s += fmt.Sprintf("\n\nfunc (self *%s) Clear() {\n    self.New()\n}", funcName)

		// Set() 方法
		for _, p := range paramsArray {

			paramName, typing := strings.Split(p, " ")[0], strings.Split(p, " ")[1]
			paramName = strFirstToUpper(paramName)
			smallName := strFirstToLower(paramName)
			if smallName == "error" {
				smallName = "err"
			}
			if paramName == "error" {
				paramName = "err"
			}
			s += fmt.Sprintf("\n\nfunc (self *%s) Set%s(%s %s) {\n", funcName, paramName, smallName, typing)
			s += fmt.Sprintf("    self.%s = %s\n", paramName, smallName)
			s += fmt.Sprintf("}")
		}
	}

	outputGo.Write([]byte(s))
	outputGo.Close()
}

func writePb2JsFile(funcList []function, fileName string, packaging string) {

	// fmt.Println(funcName, ", ", paramsArray, ", ", fileName, ", ", packaging)
	var defaultValue = map[string]string{
		"float64": "0",
		"float32": "0",
		"int32":   "0",
		"int64":   "0",
		"uint32":  "0",
		"uint64":  "0",
		"bool":    "false",
		"string":  "\"\"",
		"[]byte":  "new Uint8Array([])",

		"[]float64": "[]",
		"[]float32": "[]",
		"[]int32":   "[]",
		"[]int64":   "[]",
		"[]uint32":  "[]",
		"[]uint64":  "[]",
		"[]bool":    "[]",
		"[]string":  "[]",
		"[][]byte":  "[]",
	}

	s := ""
	outputJs, err := os.OpenFile(fmt.Sprintf(basePath+"/proto/%s.js", strings.ToLower(fileName)), os.O_RDONLY|os.O_CREATE|os.O_TRUNC, 0777)
	if err != nil {
		log.Fatal(err)
	}
	for _, fun := range funcList {
		funcName := fun.funcName
		paramsArray := fun.paramsArray

		// New() 方法
		s += fmt.Sprintf("\n\nfunction New%s(){\n    var self = {};\n", funcName)
		for _, p := range paramsArray {
			paramName, typing := strings.Split(p, " ")[0], strings.Split(p, " ")[1]
			paramName = strFirstToUpper(paramName)
			dValue, ok := defaultValue[typing]

			if ok {
				s += fmt.Sprintf("    self.%s = %s;\n", paramName, dValue)
			} else {
				s += fmt.Sprintf("    self.%s = New%s();\n", paramName, strings.Replace(typing, "*", "", -1))
			}

		}
		s += fmt.Sprintf("    return self;\n}")
	}

	s += "\nmodule.exports = {\n"
	for _, fun := range funcList {
		if fun.isRoot {
			s += fmt.Sprintf("    %s : New%s(), \n", fun.funcName, fun.funcName)
		}
	}
	s += "\n}\n"
	outputJs.Write([]byte(s))
	outputJs.Close()

}

func preHandleContent(content string) []string {

	reg3 := regexp.MustCompile(` //.*\n`)
	content = reg3.ReplaceAllString(content, ` `) // 去除注释//
	reg1 := regexp.MustCompile(`#.*\n`)
	content = reg1.ReplaceAllString(content, ` `) // 去除注释#
	reg2 := regexp.MustCompile(`[\r\t\n]`)
	content = reg2.ReplaceAllString(content, ` `)      // 去除多个空格
	content = strings.Replace(content, ";", " ; ", -1) // 分号
	reg := regexp.MustCompile(`[ \t]+`)
	content = reg.ReplaceAllString(content, ` `) // 去除多个空格
	text := strings.Split(content, " ")

	return text
}

func createFolder(filepath string) {
	//递归创建文件夹
	err := os.MkdirAll(filepath, os.ModePerm)
	if err != nil {
		fmt.Println(err)
		return
	}
}

// func newPb2GoFile(fileName string, packaging string) {

// 	os.OpenFile(fmt.Sprintf(basePath+"/%s/%s.pb2.go", packaging, strings.ToLower(fileName)), os.O_TRUNC|os.O_CREATE, 0777)
// 	fileStr := fmt.Sprintf("package %s\nimport (\n    \"bytes\"\n    \"encoding/binary\"\n    \"encoding/json\"\n    \"errors\"\n    \"github.com/golang/protobuf/proto\"    \n)\n", packaging)
// 	outputGo, err := os.OpenFile(fmt.Sprintf(basePath+"/%s/%s.pb2.go", packaging, strings.ToLower(fileName)), os.O_APPEND, 0777)
// 	if err != nil {
// 		log.Fatal(err)
// 	}
// 	outputGo.Write([]byte(fileStr))
// 	outputGo.Close()

// }

// func newPb2JsFile(fileName string, packaging string) {
// 	outputJs2, err := os.OpenFile(fmt.Sprintf(basePath+"/proto/%s.js", strings.ToLower(fileName)), os.O_TRUNC|os.O_CREATE, 0777)
// 	if err != nil {
// 		log.Fatal(err)
// 	}
// 	outputJs2.Close()

// }

type function struct {
	funcName    string
	paramsArray []string
	fileName    string
	packaging   string
	isRoot      bool
}

func parseProto(text []string, fileName string) ([]function, string, string) {
	// 基于 Dijkstra 双栈求值法的递归解析
	functionNames := make(stack.Stack, 0)
	params := make(stack.Stack, 0)
	insideMain := false // 已经进入message区
	addSquare := false
	packaging := "default"
	funcList := make([]function, 0)
	for i, w := range text {
		l := i - 1
		n := i + 1
		tmpStr := ""
		subString := regexp.MustCompile(`[a-zA-Z_][a-zA-Z0-9_]+`).FindString(text[i]) // 找变量

		if w == "package" {
			packaging = strings.ToLower(text[n])

		} else if w == "message" {
			// funtionName入栈
			messageName := text[n]
			popped, err := functionNames.Top()
			if err == nil {
				messageName = popped.(string) + "_" + messageName
			}
			functionNames.Push(messageName)
			params.Push("")
			insideMain = true

		} else if w == "repeated" {
			addSquare = true
		} else if typing, ok := typeMap[w]; ok {
			// 符合基本数据类型，params 入栈
			paramName := text[n]
			if addSquare {
				tmpStr = tmpStr + paramName + " []" + typing
				addSquare = false
			} else {
				tmpStr = tmpStr + paramName + " " + typing
			}
			params.Push(tmpStr)
		} else if l > 0 && (text[l] == ";" || text[l] == "{") && insideMain && subString != "" {
			// 符合基本扩展类型，params 入栈
			popped, err := functionNames.Top()
			if err == nil {
				subString = "*" + popped.(string) + "_" + subString
			}
			paramName := text[n]
			if addSquare {
				tmpStr = tmpStr + paramName + " []" + subString
				addSquare = false
			} else {
				tmpStr = tmpStr + paramName + " " + subString
			}
			params.Push(tmpStr)
		} else if w == "}" {
			// 遇到 }，functionNames 出栈，params 出栈到分隔符 ""
			stackStr, err2 := functionNames.Pop()
			if err2 == nil {
				funcName := stackStr.(string)
				paramsArray := make([]string, 0)
				for !params.IsEmpty() {
					valueStackStr, _ := params.Pop()
					if valueStackStr.(string) != "" {
						paramsArray = append(paramsArray, valueStackStr.(string))
					} else {
						break
					}
				}
				for i, j := 0, len(paramsArray)-1; i < j; i, j = i+1, j-1 {
					paramsArray[i], paramsArray[j] = paramsArray[j], paramsArray[i]
				} // 翻转params数组
				isRoot := false
				if functionNames.IsEmpty() {
					isRoot = true
				}
				fun := function{funcName, paramsArray, fileName, packaging, isRoot}
				funcList = append(funcList, fun)

			}

		}
	}

	return funcList, fileName, packaging
}

func makeS() {
	// 入口函数
	files, err := ioutil.ReadDir(basePath + "/proto/")
	if err != nil {
		log.Fatal(err)
	}
	for _, file := range files {
		if !file.IsDir() && filepath.Ext(file.Name()) == ".proto" {
			bytes, err := ioutil.ReadFile(basePath + "/proto/" + file.Name())
			if err != nil {
				fmt.Println("error : %s", err)
				return
			}
			content := preHandleContent(string(bytes))
			funcList, fileName, packaging := parseProto(content, strings.Replace(file.Name(), ".proto", "", -1))

			writePb2GoFile(funcList, fileName, packaging)
			writePb2JsFile(funcList, fileName, packaging)
		}
	}
}

//  使用方法
//  message := new(pb3.Bail)
// 	message.New()
// 	message.Req.Username = "apple"
// 	message.Ans.Password = "apple"
// 	fmt.Println(message)

func main() {
	// a := strings.Split("protoc --go_out=../pb3 poster.proto", " ")
	// c := exec.Command(a[:]...)
	// c.Stdout = os.Stdout
	// c.Run()
	protos := readProtoDir()
	writeProtocolFile(protos)
	// // writepbFile(protos)
	// writeDispacherFile(protos)
	makeS()
}
