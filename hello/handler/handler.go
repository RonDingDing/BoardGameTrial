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

func ClearState(ip string, connection *websocket.Conn, ormManager orm.Ormer) {
	if username, ok := global.IpUserMap[ip]; ok {
		manilaroom, loungeroom, _ := global.FindUserInManila(username)
		messageType := 1
		if loungeroom != nil {
			// delete(global.UserPlayerMap, username)
			delete(global.IpUserMap, ip)
			loungeroom.Exit(username)
			roomdetailmsg := new(pb3.RoomDetailMsg).New()
			HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, loungeroom)
			RoomObjBroadcastMessage(messageType, roomdetailmsg, loungeroom)
		} else if manilaroom != nil {
			roomdetailmsg := new(pb3.RoomDetailMsg).New()
			if manilaroom.GetStarted() == false {
				// delete(global.UserPlayerMap, username)
				delete(global.IpUserMap, ip)
				manilaroom.Exit(username)

				HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, manilaroom)
				RoomObjBroadcastMessage(messageType, roomdetailmsg, manilaroom)
			} else {
				manilaroom.GetManilaPlayers()[username].SetOnline(false)
				HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, manilaroom)
				RoomObjBroadcastMessage(messageType, roomdetailmsg, manilaroom)
			}

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

func HandleReadyMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	readymsg := new(pb3.ReadyMsg).New()
	err := json.Unmarshal(message, &readymsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := readymsg.Req.Username
	readied := readymsg.Req.Ready
	manilaRoom, _, roomNum := global.FindUserInManila(username)
	if manilaRoom != nil {
		players := manilaRoom.GetManilaPlayers()
		if p, ok := players[username]; ok {
			p.SetReady(readied)
		}
		if manilaRoom.CanStartGame() == true {
			manilaRoom.StartGame()

			// 广播开始信息
			startgamemsg := new(pb3.GameStartMsg).New()
			startgamemsg.Ans.RoomNum = roomNum
			RoomObjBroadcastMessage(messageType, startgamemsg, manilaRoom)

			// 设定起始玩家
			firstPlayer := manilaRoom.SelectRandomPlayer()
			bidmsg := new(pb3.BidMsg).New()
			manilaRoom.SetCurrentPlayer(firstPlayer)
			manilaRoom.SetHighestBidder(firstPlayer)
			bidmsg.Ans.Username = firstPlayer
			bidmsg.Ans.RoomNum = roomNum
			bidmsg.Ans.HighestBidPrice = manilaRoom.GetHighestBidPrice()
			bidmsg.Ans.HighestBidder = manilaRoom.GetHighestBidder()
			RoomObjBroadcastMessage(messageType, bidmsg, manilaRoom)

			// 为每位玩家发送其手牌具体信息
			RoomObjTellDeck(manilaRoom)
			RoomObjChangePhase(manilaRoom, manila.PhaseBidding)
		}

		// 广播房间目前信息
		roomdetailmsg := new(pb3.RoomDetailMsg).New()
		HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, manilaRoom)
		RoomObjBroadcastMessage(messageType, roomdetailmsg, manilaRoom)
	} else {
		readymsg.Error = msg.ErrUserIsNotInRoom
		SendMessage(messageType, readymsg, connection)
	}
}

func HandleBidMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	bidmsg := new(pb3.BidMsg).New()
	err := json.Unmarshal(message, &bidmsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := bidmsg.Req.Username
	bid := bidmsg.Req.Bid
	manilaRoom, _, roomNum := global.FindUserInManila(username)
	if manilaRoom != nil {
		if bid != 0 {
			manilaRoom.SetHighestBidPrice(bid)
			manilaRoom.SetHighestBidder(username)
		} else {
			manilaRoom.GetManilaPlayers()[username].SetCanBid(false)
		}
		hasBidder, bidderMap := manilaRoom.HasOtherBidder(manilaRoom.GetHighestBidder())
		if hasBidder {
			nextBidder := manilaRoom.NextBidder(username, bidderMap)
			// 广播投标信息
			manilaRoom.SetCurrentPlayer(nextBidder)
			bidmsg := bidmsg
			bidmsg.Ans.Username = nextBidder
			bidmsg.Ans.RoomNum = roomNum
			bidmsg.Ans.HighestBidPrice = manilaRoom.GetHighestBidPrice()
			bidmsg.Ans.HighestBidder = manilaRoom.GetHighestBidder()
			RoomObjBroadcastMessage(messageType, bidmsg, manilaRoom)

			// 广播房间目前信息
			roomdetailmsg := new(pb3.RoomDetailMsg).New()
			HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, manilaRoom)
			RoomObjBroadcastMessage(messageType, roomdetailmsg, manilaRoom)

			// 为每位玩家发送其手牌具体信息
			RoomObjTellDeck(manilaRoom)

		} else {
			// 没有玩家能够投标了，通知船长要买股票

			captain := manilaRoom.GetHighestBidder()
			captainObj := manilaRoom.GetManilaPlayers()[captain]
			captainPrice := manilaRoom.GetHighestBidPrice()
			captainObj.AddMoney(-captainPrice)
			manilaRoom.SetCurrentPlayer(captain)
			manilaRoom.SetHighestBidPrice(0)
			buystockmsg := new(pb3.BuyStockMsg).New()
			buystockmsg.Ans.Username = captain
			buystockmsg.Ans.RoomNum = roomNum
			buystockmsg.Ans.Bought = 0
			buystockmsg.Ans.RemindOrOperated = true
			buystockmsg.Ans.SilkDeck = manilaRoom.GetOneDeck(manila.SilkColor)
			buystockmsg.Ans.JadeDeck = manilaRoom.GetOneDeck(manila.JadeColor)
			buystockmsg.Ans.CoffeeDeck = manilaRoom.GetOneDeck(manila.CoffeeColor)
			buystockmsg.Ans.GinsengDeck = manilaRoom.GetOneDeck(manila.GinsengColor)

			RoomObjBroadcastMessage(messageType, buystockmsg, manilaRoom)
			RoomObjChangePhase(manilaRoom, manila.PhaseBuyStock)

			// 广播房间目前信息
			roomdetailmsg := new(pb3.RoomDetailMsg).New()
			HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, manilaRoom)
			RoomObjBroadcastMessage(messageType, roomdetailmsg, manilaRoom)

		}

	} else {
		bidmsg.Error = msg.ErrUserIsNotInRoom
		SendMessage(messageType, bidmsg, connection)
	}

}

func HandleBuyStockMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	buystockmsg := new(pb3.BuyStockMsg).New()
	err := json.Unmarshal(message, &buystockmsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := buystockmsg.Req.Username
	stockType := buystockmsg.Req.Stock
	manilaRoom, _, roomNum := global.FindUserInManila(username)
	if manilaRoom == nil {
		buystockmsg.Error = msg.ErrUserIsNotInRoom
		SendMessage(messageType, buystockmsg, connection)
	} else if username != manilaRoom.GetHighestBidder() {
		buystockmsg.Error = msg.ErrUserIsNotCaptain
		SendMessage(messageType, buystockmsg, connection)
	} else {
		stockBuyer := manilaRoom.GetManilaPlayers()[username]
		stockPrice := manilaRoom.GetBuyStockPrice(stockType)

		// 购买股票
		if stockType != manila.EmptyColor {
			if stockBuyer.GetMoney() < stockPrice {
				buystockmsg.Error = msg.ErrNotEnoughGameMoney
				SendMessage(messageType, buystockmsg, connection)
				return
			}
			stockBuyer.AddMoney(-stockPrice)
			stockCard, err := manilaRoom.TakeOneStock(stockType)
			if err != nil {
				buystockmsg.Error = msg.ErrNotEnoughStock
				SendMessage(messageType, buystockmsg, connection)
				return
			}
			stockBuyer.AddHand(stockCard)
		}

		buystockmsg.Ans.Bought = stockType
		buystockmsg.Ans.Username = username
		buystockmsg.Ans.RoomNum = roomNum
		buystockmsg.Ans.RemindOrOperated = false
		buystockmsg.Ans.SilkDeck = manilaRoom.GetOneDeck(manila.SilkColor)
		buystockmsg.Ans.JadeDeck = manilaRoom.GetOneDeck(manila.JadeColor)
		buystockmsg.Ans.CoffeeDeck = manilaRoom.GetOneDeck(manila.CoffeeColor)
		buystockmsg.Ans.GinsengDeck = manilaRoom.GetOneDeck(manila.GinsengColor)

		RoomObjBroadcastMessage(messageType, buystockmsg, manilaRoom)
		RoomObjChangePhase(manilaRoom, manila.PhasePutBoat)

		// 广播房间目前信息
		roomdetailmsg := new(pb3.RoomDetailMsg).New()
		HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, manilaRoom)
		RoomObjBroadcastMessage(messageType, roomdetailmsg, manilaRoom)

		// 为每位玩家发送其手牌具体信息
		RoomObjTellDeck(manilaRoom)

		// 告诉船长，要放船了
		putboatmsg := new(pb3.PutBoatMsg).New()
		putboatmsg.Ans.Username = username
		putboatmsg.Ans.RemindOrOperated = true
		putboatmsg.Ans.RoomNum = roomNum
		RoomObjBroadcastMessage(messageType, putboatmsg, manilaRoom)
	}
}

func HandlePutBoatMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	putboatmsg := new(pb3.PutBoatMsg).New()
	err := json.Unmarshal(message, &putboatmsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := putboatmsg.Req.Username
	manilaRoom, _, roomNum := global.FindUserInManila(username)
	if manilaRoom == nil {
		putboatmsg.Error = msg.ErrUserIsNotInRoom
		SendMessage(messageType, putboatmsg, connection)
	} else if username != manilaRoom.GetHighestBidder() {
		putboatmsg.Error = msg.ErrUserIsNotCaptain
		SendMessage(messageType, putboatmsg, connection)
	} else {
		for _, cargoType := range []int{manila.SilkColor, manila.JadeColor, manila.CoffeeColor, manila.GinsengColor} {
			if cargoType != putboatmsg.Req.Except {
				manilaRoom.SetMapOnboard(cargoType)
			}
		}
		putboatmsg.Ans.Username = username
		putboatmsg.Ans.RemindOrOperated = false
		putboatmsg.Ans.RoomNum = roomNum
		putboatmsg.Ans.Except = putboatmsg.Req.Except
		RoomObjBroadcastMessage(messageType, putboatmsg, manilaRoom)

		// 广播房间目前信息
		roomdetailmsg := new(pb3.RoomDetailMsg).New()
		HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, manilaRoom)
		RoomObjBroadcastMessage(messageType, roomdetailmsg, manilaRoom)

		// 为每位玩家发送其手牌具体信息
		RoomObjTellDeck(manilaRoom)
	}
}
