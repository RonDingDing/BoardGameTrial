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
			manilaRoom.SetRound(1)
			bidmsg.Ans.Username = firstPlayer
			bidmsg.Ans.RoomNum = roomNum
			bidmsg.Ans.HighestBidPrice = manilaRoom.GetHighestBidPrice()
			bidmsg.Ans.HighestBidder = manilaRoom.GetHighestBidder()
			RoomObjBroadcastMessage(messageType, bidmsg, manilaRoom)

			// 为每位玩家发送其手牌具体信息
			RoomObjTellHand(manilaRoom)
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
			RoomObjTellRoomDetail(manilaRoom, nil)

		} else {
			// 没有玩家能够投标了，通知船长要买股票

			captain := manilaRoom.GetHighestBidder()
			captainObj := manilaRoom.GetManilaPlayers()[captain]
			captainPrice := manilaRoom.GetHighestBidPrice()
			captainObj.AddMoney(-captainPrice)
			manilaRoom.SetCurrentPlayer(captain)
			buystockmsg := new(pb3.BuyStockMsg).New()
			buystockmsg.Ans.Username = captain
			buystockmsg.Ans.RoomNum = roomNum
			buystockmsg.Ans.Bought = 0
			buystockmsg.Ans.RemindOrOperated = true
			buystockmsg.Ans.Deck = manilaRoom.GetDecks()

			RoomObjBroadcastMessage(messageType, buystockmsg, manilaRoom)
			RoomObjChangePhase(manilaRoom, manila.PhaseBuyStock)

			// 广播房间目前信息
			RoomObjTellRoomDetail(manilaRoom, nil)

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

		// 购买股票
		if stockType != manila.EmptyColor {
			stockPrice := manilaRoom.GetBuyStockPrice(stockType)
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
		buystockmsg.Ans.Deck = manilaRoom.GetDecks()

		RoomObjBroadcastMessage(messageType, buystockmsg, manilaRoom)
		RoomObjChangePhase(manilaRoom, manila.PhasePutBoat)

		// 广播房间目前信息
		RoomObjTellRoomDetail(manilaRoom, nil)

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
		for _, cargoType := range []int{manila.CoffeeColor, manila.SilkColor, manila.GinsengColor, manila.JadeColor} {
			if cargoType != putboatmsg.Req.Except {
				manilaRoom.SetMapOnboard(cargoType, 0)
			}
		}
		putboatmsg.Ans.Username = username
		putboatmsg.Ans.RemindOrOperated = false
		putboatmsg.Ans.RoomNum = roomNum
		putboatmsg.Ans.Except = putboatmsg.Req.Except
		RoomObjBroadcastMessage(messageType, putboatmsg, manilaRoom)
		RoomObjChangePhase(manilaRoom, manila.PhaseDragBoat)

		// 广播房间目前信息
		roomdetailmsg := new(pb3.RoomDetailMsg).New()
		HelperSetRoomObjPropertyRoomDetail(roomdetailmsg, manilaRoom)
		RoomObjBroadcastMessage(messageType, roomdetailmsg, manilaRoom)

		// 为每位玩家发送其手牌具体信息
		RoomObjTellHand(manilaRoom)

		// 告诉船长，要拉船了
		dragboatmsg := new(pb3.DragBoatMsg).New()
		dragboatmsg.Ans.Username = username
		dragboatmsg.Ans.RemindOrOperated = true
		dragboatmsg.Ans.RoomNum = roomNum
		dragboatmsg.Ans.Phase = manilaRoom.GetPhase()
		dragboatmsg.Ans.Ship = manilaRoom.GetShip()

		all := []int{manila.CoffeeColor, manila.SilkColor, manila.GinsengColor, manila.JadeColor}
		dragable := []int{}
		for _, v := range all {
			if v != putboatmsg.Req.Except {
				dragable = append(dragable, v)
			}
		}
		dragboatmsg.Ans.Dragable = dragable
		RoomObjBroadcastMessage(messageType, dragboatmsg, manilaRoom)
	}
}

func HandleDragBoatMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	dragboatmsg := new(pb3.DragBoatMsg).New()
	err := json.Unmarshal(message, &dragboatmsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := dragboatmsg.Req.Username
	manilaRoom, _, roomNum := global.FindUserInManila(username)
	if manilaRoom == nil {
		dragboatmsg.Error = msg.ErrUserIsNotInRoom
		SendMessage(messageType, dragboatmsg, connection)
	} else if username != manilaRoom.GetHighestBidder() {
		dragboatmsg.Error = msg.ErrUserIsNotCaptain
		SendMessage(messageType, dragboatmsg, connection)
	} else {
		shipDrag := dragboatmsg.Req.ShipDrag
		for k, v := range shipDrag {
			step := manilaRoom.GetShip()[k]
			if step >= 0 {
				manilaRoom.SetMapOnboard(k+1, v+step)
			}
		}
		dragboatmsg.Ans.Username = username
		dragboatmsg.Ans.RemindOrOperated = false
		dragboatmsg.Ans.RoomNum = roomNum
		dragboatmsg.Ans.Phase = manilaRoom.GetPhase()
		dragboatmsg.Ans.Ship = manilaRoom.GetShip()
		RoomObjBroadcastMessage(messageType, dragboatmsg, manilaRoom)
		RoomObjChangePhase(manilaRoom, manila.PhaseInvest)

		// 广播房间目前信息
		RoomObjTellRoomDetail(manilaRoom, nil)

		// 告诉船长，要投资了
		investmsg := new(pb3.InvestMsg).New()
		investmsg.Ans.Username = username
		investmsg.Ans.RemindOrOperated = true
		investmsg.Ans.RoomNum = roomNum
		RoomObjBroadcastMessage(messageType, investmsg, manilaRoom)
	}
}

func HandleInvestMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	investmsg := new(pb3.InvestMsg).New()
	err := json.Unmarshal(message, &investmsg)
	if err != nil {
		log.Println(err)
		return
	}
	username := investmsg.Req.Username
	invest := investmsg.Req.Invest
	manilaRoom, _, roomNum := global.FindUserInManila(username)
	if manilaRoom == nil {
		investmsg.Error = msg.ErrUserIsNotInRoom
		SendMessage(messageType, investmsg, connection)
		return
	} else {
		investPoint, ok := manilaRoom.GetMap()[invest]
		if !ok {
			investmsg.Error = msg.ErrInvalidInvestPoint
			SendMessage(messageType, investmsg, connection)
			return
		}
		if investPoint.GetTaken() != "" && investPoint.GetName() != "none" {
			investmsg.Error = msg.ErrInvestPointTaken
			SendMessage(messageType, investmsg, connection)
			return
		}
		if shipColor, mk := manila.StringColor[invest[1:]]; mk {
			if manilaRoom.GetShip()[shipColor-1] >= 14 && manilaRoom.GetShip()[shipColor-1] <= 16 {
				investmsg.Error = msg.ErrInvalidInvestPoint
				SendMessage(messageType, investmsg, connection)
				return
			}
		}

		player := manilaRoom.GetManilaPlayers()[username]
		price := investPoint.GetPrice()
		if price > player.GetMoney() {
			investmsg.Error = msg.ErrNotEnoughGameMoney
			SendMessage(messageType, investmsg, connection)
			return
		}

		player.AddMoney(-price)
		investPoint.SetTaken(username)
		// 比较特殊的 repair 在这里结算
		if invest == "repair" {
			award := investPoint.GetAward()
			player.AddMoney(award)
		}

		// 广播投资信息
		investmsg.Ans.Username = username
		investmsg.Ans.RemindOrOperated = false
		investmsg.Ans.RoomNum = roomNum
		investmsg.Ans.Invest = invest
		RoomObjBroadcastMessage(messageType, investmsg, manilaRoom)

		// 找下一个玩家，判定是否下一个阶段
		nextUser, nextPhase := manilaRoom.NextPlayer(username)
		manilaRoom.SetCurrentPlayer(nextUser)
		special := len(manilaRoom.GetPlayerName()) == 3 && manilaRoom.GetRound() == 1
		if (!nextPhase) || (special) {
			// 不是下一个阶段，继续投资
			log.Println(1)
			investmsg := new(pb3.InvestMsg).New()
			investmsg.Ans.Username = nextUser
			investmsg.Ans.RemindOrOperated = true
			investmsg.Ans.RoomNum = roomNum
			RoomObjBroadcastMessage(messageType, investmsg, manilaRoom)
			if special && nextPhase {
				manilaRoom.AddRound()
			}

		} else {
			// 下一个阶段，投掷骰子
			RoomObjChangePhase(manilaRoom, manila.PhaseCastDice)
			dice, casttime := manilaRoom.CastDice()
			manilaRoom.SetPiratesOrDragsHasActed("1pirate", false)
			manilaRoom.SetPiratesOrDragsHasActed("2pirate", false)
			manilaRoom.SetLastPlunderedShip(0)

			// 广播骰子信息
			dicemsg := new(pb3.DiceMsg).New()
			dicemsg.Ans.RoomNum = roomNum
			dicemsg.Ans.Dice = dice
			dicemsg.Ans.CastTime = casttime
			RoomObjBroadcastMessage(messageType, dicemsg, manilaRoom)

			// 跑船
			manilaRoom.RunShip(dice)
			// 广播房间目前信息
			RoomObjTellRoomDetail(manilaRoom, nil)
			if manilaRoom.HasBoatForPirate("1pirate") {
				log.Println(2)

				// 第一个海盗来袭
				RoomObjChangePhase(manilaRoom, manila.PhasePiratePlunder)
				pirate := manilaRoom.GetMap()["1pirate"].GetTaken()
				manilaRoom.SetTempCurrentPlayer(pirate)
				piratemsg := new(pb3.PirateMsg).New()
				piratemsg.Ans.RoomNum = roomNum
				piratemsg.Ans.CastTime = manilaRoom.GetCastTime()
				piratemsg.Ans.Pirate = pirate
				piratemsg.Ans.ShipVacant = manilaRoom.GetShipPirateVacant()
				piratemsg.Ans.LastPlunderedShip = manilaRoom.GetLastPlunderedShip()
				piratemsg.Ans.RemindOrOperated = true
				RoomObjBroadcastMessage(messageType, piratemsg, manilaRoom)
			} else if casttime == 2 || casttime == 1 {
				if manilaRoom.GetMap()["1drag"].GetTaken() != "" || manilaRoom.GetMap()["2drag"].GetTaken() != "" && casttime == 2 {
					manilaRoom.PostDrag()
					log.Println(3)
				} else {
					log.Println(4)
					manilaRoom.ThirteenToTick()
					//  下一个阶段，投资
					RoomObjChangePhase(manilaRoom, manila.PhaseInvest)
					manilaRoom.AddRound()
					investmsg := new(pb3.InvestMsg).New()
					investmsg.Ans.Username = nextUser
					investmsg.Ans.RemindOrOperated = true
					investmsg.Ans.RoomNum = roomNum
					RoomObjBroadcastMessage(messageType, investmsg, manilaRoom)
				}
			} else if casttime == 3 {
				// 结算
				log.Println(5)
				RoomObjChangePhase(manilaRoom, manila.PhaseSettle)
				manilaRoom.SettleRound()
			}
		}

		// 广播房间目前信息
		RoomObjTellRoomDetail(manilaRoom, nil)
	}
}

func HandlePirateMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	piratemsg := new(pb3.PirateMsg).New()
	err := json.Unmarshal(message, &piratemsg)
	if err != nil {
		log.Println(err)
		return
	}
	pirate := piratemsg.Req.Pirate
	manilaRoom, _, roomNum := global.FindUserInManila(pirate)
	if manilaRoom.GetMap()["1pirate"].GetTaken() == pirate {
		manilaRoom.SetPiratesOrDragsHasActed("1pirate", true)
	} else if manilaRoom.GetMap()["2pirate"].GetTaken() == pirate {
		manilaRoom.SetPiratesOrDragsHasActed("2pirate", true)
	}
	shipPlundered := piratemsg.Req.Plunder

	if manilaRoom == nil {
		piratemsg.Error = msg.ErrUserIsNotInRoom
		SendMessage(messageType, piratemsg, connection)
		return
	} else {
		switch manilaRoom.GetCastTime() {
		case 1:
		case 2:
			log.Println(6)
			manilaRoom.PirateInvest(pirate, shipPlundered, true)
		case 3:
			log.Println(7)
			manilaRoom.PirateKill(pirate, shipPlundered)
		}

		piratemsg := new(pb3.PirateMsg).New()
		piratemsg.Ans.RoomNum = roomNum
		piratemsg.Ans.CastTime = manilaRoom.GetCastTime()
		piratemsg.Ans.Pirate = pirate
		piratemsg.Ans.ShipVacant = manilaRoom.GetShipPirateVacant()
		piratemsg.Ans.LastPlunderedShip = manilaRoom.GetLastPlunderedShip()
		piratemsg.Ans.ShipPlundered = shipPlundered
		piratemsg.Ans.RemindOrOperated = false
		RoomObjBroadcastMessage(messageType, piratemsg, manilaRoom)

		castTime := manilaRoom.GetCastTime()
		if manilaRoom.HasBoatForPirate("2pirate") {
			// 第二个海盗来袭
			log.Println(8)
			RoomObjTellRoomDetail(manilaRoom, nil)
			newPirate := manilaRoom.GetMap()["2pirate"].GetTaken()
			manilaRoom.SetTempCurrentPlayer(newPirate)
			if manilaRoom.GetMap()["1pirate"].GetTaken() == "" {
				newPirate = manilaRoom.SecondPirateMoveToFirst(shipPlundered)
			}

			piratemsg := new(pb3.PirateMsg).New()
			piratemsg.Ans.RoomNum = roomNum
			piratemsg.Ans.CastTime = manilaRoom.GetCastTime()
			piratemsg.Ans.Pirate = newPirate
			piratemsg.Ans.ShipVacant = manilaRoom.GetShipPirateVacant()
			piratemsg.Ans.LastPlunderedShip = manilaRoom.GetLastPlunderedShip()
			piratemsg.Ans.RemindOrOperated = true
			RoomObjBroadcastMessage(messageType, piratemsg, manilaRoom)
		} else if castTime == 2 || castTime == 1 {

			// 投资
			log.Println(9)
			RoomObjChangePhase(manilaRoom, manila.PhaseInvest)
			RoomObjTellRoomDetail(manilaRoom, nil)
			captain := manilaRoom.GetHighestBidder()
			manilaRoom.SetCurrentPlayer(captain)
			manilaRoom.AddRound()
			investmsg := new(pb3.InvestMsg).New()
			investmsg.Ans.Username = captain
			investmsg.Ans.RemindOrOperated = true
			investmsg.Ans.RoomNum = roomNum
			RoomObjBroadcastMessage(messageType, investmsg, manilaRoom)
		} else if castTime == 3 {
			// 第三个回合决定是否靠岸

			shipToBeDecided, pirateCaptain, ok := manilaRoom.GetPirateCaptainOnShip()
			if ok {
				log.Println(10)
				RoomObjChangePhase(manilaRoom, manila.PhaseDecideTickFail)
				manilaRoom.SetTempCurrentPlayer(pirateCaptain)
				RoomObjTellRoomDetail(manilaRoom, nil)

				decidetickfailmsg := new(pb3.DecideTickFailMsg).New()
				decidetickfailmsg.Ans.Pirate = pirateCaptain
				decidetickfailmsg.Ans.RemindOrOperated = true
				decidetickfailmsg.Ans.RoomNum = roomNum
				decidetickfailmsg.Ans.ShipPlundered = shipToBeDecided
				RoomObjBroadcastMessage(messageType, decidetickfailmsg, manilaRoom)

			} else {
				log.Println(11)
				RoomObjChangePhase(manilaRoom, manila.PhaseSettle)
				manilaRoom.SettleRound()
			}

		}
		// 广播房间目前信息
		RoomObjTellRoomDetail(manilaRoom, nil)

	}
}

func HandleDecideTickFailMsg(messageType int, message []byte, connection *websocket.Conn, code string, ormManager orm.Ormer) {
	decidetickfailmsg := new(pb3.DecideTickFailMsg).New()
	err := json.Unmarshal(message, &decidetickfailmsg)
	if err != nil {
		log.Println(err)
		return
	}
	pirate := decidetickfailmsg.Req.Pirate
	manilaRoom, _, roomNum := global.FindUserInManila(pirate)
	shipPlundered := decidetickfailmsg.Req.ShipPlundered

	if manilaRoom == nil {
		decidetickfailmsg.Error = msg.ErrUserIsNotInRoom
		SendMessage(messageType, decidetickfailmsg, connection)
		return
	} else {
		if decidetickfailmsg.Req.Tick {
			manilaRoom.ShipToTick(shipPlundered)
		} else {
			manilaRoom.ShipToFail(shipPlundered)
		}
		// 第二个海盗来袭
		castTime := manilaRoom.GetCastTime()
		if manilaRoom.HasBoatForPirate("2pirate") {
			log.Println(14)
			newPirate := manilaRoom.GetMap()["2pirate"].GetTaken()
			manilaRoom.SetTempCurrentPlayer(newPirate)
			if manilaRoom.GetMap()["1pirate"].GetTaken() == "" {
				newPirate = manilaRoom.SecondPirateMoveToFirst(shipPlundered)
			}

			piratemsg := new(pb3.PirateMsg).New()
			piratemsg.Ans.RoomNum = roomNum
			piratemsg.Ans.CastTime = castTime
			piratemsg.Ans.Pirate = newPirate
			piratemsg.Ans.ShipVacant = manilaRoom.GetShipPirateVacant()
			piratemsg.Ans.LastPlunderedShip = manilaRoom.GetLastPlunderedShip()
			piratemsg.Ans.RemindOrOperated = true
			RoomObjBroadcastMessage(messageType, piratemsg, manilaRoom)
		} else if castTime == 3 {
			// 第三个回合决定是否靠岸
			shipToBeDecided, pirateCaptain, ok := manilaRoom.GetPirateCaptainOnShip()
			if ok {
				log.Println(15)
				RoomObjChangePhase(manilaRoom, manila.PhaseDecideTickFail)
				manilaRoom.SetTempCurrentPlayer(pirateCaptain)
				RoomObjTellRoomDetail(manilaRoom, nil)

				decidetickfailmsg := new(pb3.DecideTickFailMsg).New()
				decidetickfailmsg.Ans.Pirate = pirateCaptain
				decidetickfailmsg.Ans.RemindOrOperated = true
				decidetickfailmsg.Ans.RoomNum = roomNum
				decidetickfailmsg.Ans.ShipPlundered = shipToBeDecided
				RoomObjBroadcastMessage(messageType, decidetickfailmsg, manilaRoom)

			} else {
				log.Println(16)
				RoomObjChangePhase(manilaRoom, manila.PhaseSettle)
				manilaRoom.SettleRound()
			}
		}
	}
	RoomObjTellRoomDetail(manilaRoom, nil)
}
