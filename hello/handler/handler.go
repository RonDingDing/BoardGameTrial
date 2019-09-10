package handler

import (
	"encoding/json"
	"hello/models"
	"hello/msg"
	"hello/pb3"
	"log"

	"github.com/astaxie/beego/orm"

	"github.com/gorilla/websocket"
)

func HandleErrors(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	errObj := pb3.Errors{Code: code, Error: msg.ErrNoHandler}
	errStr, err := json.Marshal(errObj)
	if err != nil {
		log.Print(err)
		return
	}
	err = connection.WriteMessage(messageType, []byte(errStr))
	log.Printf("%-8s: %s\n", "WrittenError", string(errStr))

}

func HandleLoginMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	loginmsg := pb3.LoginMsg{}
	loginmsg.New()
	err := json.Unmarshal(message, &loginmsg)
	if err != nil {
		log.Print(err)
		return
	}
	log.Print(loginmsg)

	// err = connection.WriteMessage(messageType, message)
	// log.Printf("%-8s: %s %4s %s\n", "written", string(loginmsg), "to", connection.RemoteAddr())

}

func HandleSignUpMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	signupmsg := pb3.SignUpMsg{}
	signupmsg.New()
	err := json.Unmarshal(message, &signupmsg)
	if err != nil {
		log.Print(err)
		return
	}
	username := signupmsg.Req.Username
	password := signupmsg.Req.Password
	mobile := signupmsg.Req.Mobile
	email := signupmsg.Req.Email
	query := &models.PlayerUser{Name: username}
	err = ormManager.Read(query)
	if err == orm.ErrNoRows {
		newUser := models.PlayerUser{Name: username, Password: password, Mobile: mobile, Email: email, Gold: 1000}
		ormManager.Insert(&newUser)
		signupmsg.Req.Password = ""
		signupmsg.Ans.Username = username
		signupmsg.Ans.Mobile = mobile
		signupmsg.Ans.Email = email
		signupmsg.Ans.Gold = 1000

	} else {
		signupmsg.Error = msg.ErrUserExit
	}

	messageReturn, err := json.Marshal(signupmsg)
	err = connection.WriteMessage(messageType, []byte(messageReturn))
	log.Printf("%-8s: %s %4s %s\n", "written", string(messageReturn), "to", connection.RemoteAddr())
	if err != nil {
		log.Print(err)
		return
	}

}
