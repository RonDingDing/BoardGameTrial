package handler

import (
	"encoding/json"
	"hello/baseroom"
	"hello/global"
	"hello/manila"
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

	// messageReturn, err := json.Marshal(signupmsg)
	// err = connection.WriteMessage(messageType, []byte(messageReturn))
	// log.Printf("%-8s: %s %4s %s\n", "written", string(messageReturn), "to", connection.RemoteAddr())
	// if err != nil {
	// 	log.Println(err)
	// 	return
	// }
	SendMessage(messageType, signupmsg, connection)
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
		player := new(baseroom.Player).New(username, connection, query.Gold)

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

	}
	SendMessage(messageType, loginmsg, connection)
	// messageReturn, err := json.Marshal(loginmsg)
	// if err != nil {
	// 	log.Print(err)
	// 	return
	// }
	// err = connection.WriteMessage(messageType, []byte(messageReturn))
	// log.Printf("%-8s: %s %4s %s\n", "written", string(messageReturn), "to", connection.RemoteAddr())
	// if err != nil {
	// 	log.Print(err)
	// 	return
	// }

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
		enterState := baseroom.FailedEntering
		if roomNum == baseroom.LoungeNum {
			// 进入大厅
			loungeO := global.EntranceLounge[baseroom.LoungeNum]
			room := &loungeO
			enterState = room.Enter(&player)
			HelperSetRoomPropertyEnterRoom(enterroommsg, room)

		} else if roomO, ok := global.ManilaLounge[roomNum]; ok {
			// 进入其他房间
			mPlayer := global.ToManilaPlayer(&player)
			room := &roomO
			enterState = room.Enter(mPlayer)
			HelperSetRoomPropertyEnterRoom(enterroommsg, room)

		} else {
			// 无此房间号，新建房间
			room := global.NewManilaRoom(roomNum)
			mPlayer := global.ToManilaPlayer(&player)
			enterState = room.Enter(mPlayer)
			HelperSetRoomPropertyEnterRoom(enterroommsg, room)
		}
		if enterState == baseroom.FailedEntering {
			enterroommsg.Error = msg.ErrCannotEnterRoom
			enterroommsg.Ans.RoomNum = 0
		}
	} else {
		// 极小概率，玩家字典中没有此玩家
		enterroommsg.Error = msg.ErrNoSuchPlayer
	}
	SendMessage(messageType, enterroommsg, connection)
	// messageReturn, err := json.Marshal(enterroommsg)
	// if err != nil {
	// 	log.Print(err)
	// 	return
	// }
	// err = connection.WriteMessage(messageType, []byte(messageReturn))
	// log.Printf("%-8s: %s %4s %s\n", "written", string(messageReturn), "to", connection.RemoteAddr())
	// if err != nil {
	// 	log.Print(err)
	// 	return
	// }

}

func HelperSetRoomPropertyEnterRoom(enterroommsg *pb3.EnterRoomMsg, room interface{}) {

	switch room := room.(type) {
	case *baseroom.Room:
		enterroommsg.Ans.RoomNum = 0
		enterroommsg.Ans.GameNum = room.GetGameNum()
		enterroommsg.Ans.Started = room.GetStarted()
		enterroommsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		enterroommsg.Ans.PlayerNumMax = room.GetPlayerNumMax()
		enterroommsg.Ans.PlayerName = room.GetPlayerName()
	case *manila.ManilaRoom:
		enterroommsg.Ans.RoomNum = room.GetRoomNum()
		enterroommsg.Ans.GameNum = room.GetGameNum()
		enterroommsg.Ans.Started = room.GetStarted()
		enterroommsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		enterroommsg.Ans.PlayerNumMax = room.GetPlayerNumMax()
		enterroommsg.Ans.PlayerName = room.GetPlayerName()
		enterroommsg.Ans.SilkDeck = room.GetSilkDeck()
		enterroommsg.Ans.CoffeeDeck = room.GetCoffeeDeck()
		enterroommsg.Ans.GinsengDeck = room.GetGinsengDeck()
		enterroommsg.Ans.JadeDeck = room.GetJadeDeck()
		enterroommsg.Ans.Round = room.GetRound()
		for k, v := range room.GetMap() {
			mapSpot := pb3.MappS{Name: k, Taken: v.GetTaken(),
				Price: v.GetPrice(), Award: v.GetAward(), Onboard: v.GetOnboard()}
			enterroommsg.Ans.Mapp = append(enterroommsg.Ans.Mapp, mapSpot)
		}
		for n, p := range room.GetOtherProps() {
			p.SetOnline(true)
			pl := pb3.PlayersS{Name: n, Stock: p.GetStocks(), Money: p.GetMoney(), Online: p.GetOnline(), Seat: p.GetSeat()}
			enterroommsg.Ans.Players = append(enterroommsg.Ans.Players, pl)
		}
	}
}
