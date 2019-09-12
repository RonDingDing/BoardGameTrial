package handler

import (
	"encoding/json"
	"hello/baseroom"
	"hello/global"
	"hello/models"
	"hello/msg"
	"hello/pb3"
	"hello/settings"
	"log"

	"github.com/astaxie/beego/orm"

	"github.com/gorilla/websocket"
)

func HandleErrors(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	errObj := pb3.Errors{Code: code, Error: msg.ErrNoHandler}
	errStr, err := json.Marshal(errObj)
	if err != nil {
		log.Println(err)
		return
	}
	err = connection.WriteMessage(messageType, []byte(errStr))
	if err != nil {
		log.Println(err)
		return
	}
	log.Printf("%-8s: %s\n", "WrittenError", string(errStr))

}

func HandleSignUpMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	signupmsg := new(pb3.SignUpMsg).New()
	err := json.Unmarshal(message, &signupmsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := signupmsg.Req.Username
	password := signupmsg.Req.Password
	mobile := signupmsg.Req.Mobile
	email := signupmsg.Req.Email
	query := models.PlayerUser{Name: username}
	dataerr := ormManager.Read(&query, "Name")

	if dataerr == orm.ErrNoRows {
		newUser := models.PlayerUser{Name: username, Password: password, Mobile: mobile, Email: email, Gold: 1000}
		ormManager.Insert(&newUser)
		signupmsg.Req.Password = ""
		signupmsg.Ans.Username = username
		signupmsg.Ans.Mobile = mobile
		signupmsg.Ans.Email = email
		signupmsg.Ans.Gold = settings.FirstGold
	} else {
		signupmsg.Req.Password = ""
		signupmsg.Error = msg.ErrUserExit
	}

	messageReturn, err := json.Marshal(signupmsg)
	err = connection.WriteMessage(messageType, []byte(messageReturn))
	log.Printf("%-8s: %s %4s %s\n", "written", string(messageReturn), "to", connection.RemoteAddr())
	if err != nil {
		log.Println(err)
		return
	}
}

func HandleLoginMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	loginmsg := new(pb3.LoginMsg).New()
	err := json.Unmarshal(message, &loginmsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := loginmsg.Req.Username
	password := loginmsg.Req.Password
	// 查找对应的用户
	query := models.PlayerUser{Name: username, Password: password}
	dataerr := ormManager.Read(&query, "Name", "Password")

	if dataerr == orm.ErrNoRows {
		// 找不到，返回错误
		loginmsg.Req.Password = ""
		loginmsg.Error = msg.ErrUserNotExit
	} else {
		// 找到
		loginmsg.Req.Password = ""
		loginmsg.Ans.Username = username
		loginmsg.Ans.Gold = query.Gold
		loginmsg.Ans.Mobile = query.Mobile
		loginmsg.Ans.Email = query.Email

		// 创建玩家对象
		player := new(baseroom.Player).New(username, connection)
		player.SetGold(query.Gold)

		// 在马尼拉房间和大厅中寻找玩家对象
		roomNum := global.FindUserInManila(username)
		global.UserTrace[username] = roomNum

		// 将原来连接的用户挤下线
		if originPlayer, exist := global.UserPlayerMap[username]; exist {
			originPlayer.ConnectionClose()
		}
		// 记录当前用户的玩家对象
		global.UserPlayerMap[username] = *player
		loginmsg.Ans.RoomNum = roomNum
		log.Println(global.EntranceLoungeString())

	}
	messageReturn, err := json.Marshal(loginmsg)
	if err != nil {
		log.Print(err)
		return
	}
	err = connection.WriteMessage(messageType, []byte(messageReturn))
	log.Printf("%-8s: %s %4s %s\n", "written", string(messageReturn), "to", connection.RemoteAddr())
	if err != nil {
		log.Print(err)
		return
	}

}

func HandleEnterRoomMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	enterroommsg := new(pb3.EnterRoomMsg).New()
	err := json.Unmarshal(message, &enterroommsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := enterroommsg.Req.Username
	roomNum := enterroommsg.Req.RoomNum
	if player, exist := global.UserPlayerMap[username]; exist {
		if roomNum == 0 {
			// 进入大厅
			lounge := global.EntranceLounge[0]
			_, entered := lounge.Enter(&player)
			if entered == false {
				enterroommsg.Error = msg.ErrCannotEnterRoom
			}
		} else {
			// 进入其他房间

		}

	} else {
		// 极小概率，玩家字典中没有此玩家
		enterroommsg.Error = msg.ErrNoSuchPlayer
	}
	log.Println(global.EntranceLoungeString())

	messageReturn, err := json.Marshal(enterroommsg)
	if err != nil {
		log.Print(err)
		return
	}
	err = connection.WriteMessage(messageType, []byte(messageReturn))
	log.Printf("%-8s: %s %4s %s\n", "written", string(messageReturn), "to", connection.RemoteAddr())
	if err != nil {
		log.Print(err)
		return
	}

}
