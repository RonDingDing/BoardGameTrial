package pb3
import (
    "bytes"
    "encoding/binary"
    "encoding/json"
    "errors"
    "github.com/golang/protobuf/proto"    
)


func (self *Bail_REQ) New() {
    self.Username = ""
    self.Password = ""
    self.Able = make([]int32, 10)
}

func (self *Bail_REQ) Clear() {
    self.New()
}

func (self *Bail_REQ) SetUsername(username string) {
    self.Username = username
}

func (self *Bail_REQ) SetPassword(password string) {
    self.Password = password
}

func (self *Bail_REQ) SetAble(able []int32) {
    self.Able = able
}

func (self *Bail_ANS) New() {
    self.Password = ""
}

func (self *Bail_ANS) Clear() {
    self.New()
}

func (self *Bail_ANS) SetPassword(password string) {
    self.Password = password
}

func (self *Bail) New() {
    self.Code = 0
    self.Exdata = []byte{'{', '}'}
    self.Req = new(Bail_REQ)
    self.Ans = new(Bail_ANS)
    self.Error = 0
}

func (self *Bail) Clear() {
    self.New()
}

func (self *Bail) SetCode(code int32) {
    self.Code = code
}

func (self *Bail) SetExdata(exdata []byte) {
    self.Exdata = exdata
}

func (self *Bail) SetReq(req *Bail_REQ) {
    self.Req = req
}

func (self *Bail) SetAns(ans *Bail_ANS) {
    self.Ans = ans
}

func (self *Bail) SetError(err int32) {
    self.Error = err
}