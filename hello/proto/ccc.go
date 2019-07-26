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

func makeS() {
	files, err := ioutil.ReadDir("../proto/")
	if err != nil {
		log.Fatal(err)
	}
	for _, file := range files {
		if !file.IsDir() && filepath.Ext(file.Name()) == ".proto" {
			bytes, err := ioutil.ReadFile("../proto/" + file.Name())
			if err != nil {
				fmt.Println("error : %s", err)
				return
			}
			mapping(string(bytes))
		}
	}

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
	"bytes":    "[]bytes",
}

func mapping(content string) string {
	// var keys stack.Stack
	// var values stack.Stack
	// fmt.Println(content)
	lines := strings.Split(content, "\n")
	for _, line := range lines {
		noline := strings.Trim(line, " ")
		words := strings.Split(noline, " ")

	}
	return "ss"
}

func main() {
	makeS()

}
