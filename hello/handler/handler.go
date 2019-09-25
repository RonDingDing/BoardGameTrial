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

func ClearState(ip string, connection *websocket.Conn, ormManager orm.Ormer) {
	if username, ok := global.IpUserMap[ip]; ok {
		manilaroom, loungeroom, roomNum := global.FindUserInManila(username)
		messageType := 1
		if loungeroom != nil {
			// delete(global.UserPlayerMap, username)
			delete(global.IpUserMap, ip)
			loungeroom.Exit(username)
			roomdetailmsg := new(pb3.RoomDetailMsg).New()
			HelperSetRoomPropertyRoomDetail(roomdetailmsg, roomNum)
			RoomBroadcastMessage(messageType, roomdetailmsg, roomNum)
		} else if manilaroom != nil && manilaroom.GetStarted() == false {
			// delete(global.UserPlayerMap, username)
			delete(global.IpUserMap, ip)
			manilaroom.Exit(username)
			roomdetailmsg := new(pb3.RoomDetailMsg).New()
			HelperSetRoomPropertyRoomDetail(roomdetailmsg, roomNum)
			RoomBroadcastMessage(messageType, roomdetailmsg, roomNum)
		}
	}
}

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

	SendMessage(messageType, signupmsg, connection)
}

func HandleLoginMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	loginmsg := new(pb3.LoginMsg).New()
	err := json.Unmarshal(message, &loginmsg)
	if err != nil {
		log.Println(err)
		return
	}
	ClearState(connection.RemoteAddr().String(), connection, ormManager)
	username := loginmsg.Req.Username
	password := loginmsg.Req.Password
	// 数据库查找对应的用户
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
		_, _, roomNum := global.FindUserInManila(username)

		// 将原来连接的用户挤下线
		if originPlayer, exist := global.UserPlayerMap[username]; exist {
			originPlayer.ConnectionClose()
		}
		// 记录当前用户的玩家对象
		global.UserPlayerMap[username] = *player
		global.IpUserMap[connection.RemoteAddr().String()] = username
		loginmsg.Ans.RoomNum = roomNum

	}
	SendMessage(messageType, loginmsg, connection)

}

func HandleEnterRoomMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	enterroommsg := new(pb3.EnterRoomMsg).New()
	err := json.Unmarshal(message, &enterroommsg)
	if err != nil {
		log.Println(err)
		return
	}

	username := enterroommsg.Req.Username
	oldManilaRoom, oldLoungeRoom, oldRoomNum := global.FindUserInManila(username)
	newRoomNum := enterroommsg.Req.RoomNum

	exitState := msg.ErrCannotExitRoom

	// 出原来的房间
	if oldLoungeRoom != nil {
		oldLoungeRoom.Exit(username)
		exitState = msg.ErrNormal
	} else if oldManilaRoom != nil {
		exitState = oldManilaRoom.Exit(username)
		if oldRoomNum == newRoomNum {
			exitState = msg.ErrNormal
		}
	}

	if exitState == msg.ErrNormal {

		if player, exist := global.UserPlayerMap[username]; exist {
			enterState := msg.ErrFailedEntering
			newManila, newLounge := global.FindRoomByNum(newRoomNum)

			if newLounge != nil {
				// 进入大厅
				enterState = newLounge.Enter(&player)
				enterroommsg.Ans.GameNum = newLounge.GetGameNum()
				enterroommsg.Ans.RoomNum = newRoomNum
				enterroommsg.Error = enterState

			} else if newManila != nil {
				// 进入其他房间
				mPlayer := global.ToManilaPlayer(&player)
				enterState = newManila.Enter(mPlayer)
				enterroommsg.Ans.GameNum = newManila.GetGameNum()
				enterroommsg.Ans.RoomNum = newRoomNum
				enterroommsg.Error = enterState
			} else {
				// 无此房间号，新建房间
				room := global.NewManilaRoom(newRoomNum)
				mPlayer := global.ToManilaPlayer(&player)
				enterState = room.Enter(mPlayer)
				enterroommsg.Ans.GameNum = room.GetGameNum()
				enterroommsg.Ans.RoomNum = newRoomNum
				enterroommsg.Error = enterState
			}
			if enterState == msg.ErrFailedEntering {
				// 无法进入房间，返回原房间
				enterroommsg.Ans.RoomNum = msg.LoungeNum
			}
		} else {
			// 极小概率，玩家字典中没有此玩家
			enterroommsg.Error = msg.ErrNoSuchPlayer
		}
	} else {
		enterroommsg.Error = msg.ErrCannotExitRoom
	}
	if oldRoomNum != newRoomNum {
		roomdetailmsg := new(pb3.RoomDetailMsg).New()
		HelperSetRoomPropertyRoomDetail(roomdetailmsg, oldRoomNum)
		RoomBroadcastMessage(messageType, roomdetailmsg, oldRoomNum)
	}

	roomdetailmsg2 := new(pb3.RoomDetailMsg).New()
	HelperSetRoomPropertyRoomDetail(roomdetailmsg2, newRoomNum)
	RoomBroadcastMessage(messageType, roomdetailmsg2, newRoomNum)
	// RoomBroadcastMessage(messageType, enterroommsg, newRoomNum)

	SendMessage(messageType, enterroommsg, connection)

}

func HelperSetRoomPropertyRoomDetail(roomdetailmsg *pb3.RoomDetailMsg, roomNum int) {

	manila, base := global.FindRoomByNum(roomNum)
	if base != nil {
		room := base
		roomdetailmsg.Ans.RoomNum = 0
		roomdetailmsg.Ans.GameNum = room.GetGameNum()
		roomdetailmsg.Ans.Started = room.GetStarted()
		roomdetailmsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		roomdetailmsg.Ans.PlayerNumMax = room.GetPlayerNumMax()

		roomdetailmsg.Ans.PlayerName = room.GetPlayerName()
	} else if manila != nil {
		room := manila
		roomdetailmsg.Ans.RoomNum = room.GetRoomNum()
		roomdetailmsg.Ans.GameNum = room.GetGameNum()
		roomdetailmsg.Ans.Started = room.GetStarted()
		roomdetailmsg.Ans.PlayerNumForStart = room.GetPlayerNumForStart()
		roomdetailmsg.Ans.PlayerNumMax = room.GetPlayerNumMax()
		roomdetailmsg.Ans.PlayerName = room.GetPlayerName()
		roomdetailmsg.Ans.SilkDeck = room.GetSilkDeck()
		roomdetailmsg.Ans.CoffeeDeck = room.GetCoffeeDeck()
		roomdetailmsg.Ans.GinsengDeck = room.GetGinsengDeck()
		roomdetailmsg.Ans.JadeDeck = room.GetJadeDeck()
		roomdetailmsg.Ans.Round = room.GetRound()

		for k, v := range room.GetMap() {
			mapSpot := pb3.MappS{Name: k, Taken: v.GetTaken(),
				Price: v.GetPrice(), Award: v.GetAward(), Onboard: v.GetOnboard()}
			roomdetailmsg.Ans.Mapp = append(roomdetailmsg.Ans.Mapp, mapSpot)
		}
		for n, p := range room.GetManilaPlayers() {
			p.SetOnline(true)
			pl := pb3.PlayersS{Name: n, Stock: p.GetStockNum(),
				Money: p.GetMoney(), Online: p.GetOnline(),
				Seat: p.GetSeat(), Ready: p.GetReadyOrNot()}
			roomdetailmsg.Ans.Players = append(roomdetailmsg.Ans.Players, pl)
		}

	}
}

func HandleReadyMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	readymsg := new(pb3.ReadyMsg).New()
	err := json.Unmarshal(message, &readymsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := readymsg.Req.Username
	readied := readymsg.Req.Ready
	manila, _, roomNum := global.FindUserInManila(username)
	if manila != nil {
		players := manila.GetManilaPlayers()
		if p, ok := players[username]; ok {
			p.SetReady(readied)
		}
		if manila.CanStartGame() == true {
			manila.StartGame()
		}

		roomdetailmsg := new(pb3.RoomDetailMsg).New()
		HelperSetRoomPropertyRoomDetail(roomdetailmsg, roomNum)
		RoomBroadcastMessage(messageType, roomdetailmsg, roomNum)
	}

}
