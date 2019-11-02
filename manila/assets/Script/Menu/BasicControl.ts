const { ccclass, property } = cc._decorator;
import EventMng from "../Fundamentals/Manager/EventMng";
import {
    SocketEvents, ErrNoHandler, ErrUserExit, ErrUserNotExit, ErrCannotEnterRoom, ErrNoSuchPlayer, ErrCannotExitRoom, ErrGameStarted, ErrUserNotInRoom, ErrFailedEntering, ErrUserNotCaptain
} from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"

@ccclass
export default class BasicControl extends cc.Component {

    @property(cc.Prefab)
    popUp: cc.Prefab = null;

    @property(cc.Canvas)
    canvas: cc.Canvas = null;


    onLoad() {
        var self = this;
        EventMng.on(SocketEvents.SOCKET_OPEN, self.onSocketOpen, self);
        EventMng.on(SocketEvents.SOCKET_CLOSE, self.onSocketClose, self);
    }

    playPopup(content: string) {
        let self = this;
        let popUp = cc.instantiate(self.popUp);
        self.canvas.node.addChild(popUp);

        popUp.active = true;
        let seq = cc.sequence(
            cc.scaleTo(0.2, 1.05, 1.05),
            cc.scaleTo(0.2, 1, 1),
        )
        popUp.runAction(seq);
        let popUpNode: cc.Node = popUp.getChildByName("AlertString");
        let popUpString: cc.Label = popUpNode.getComponent(cc.Label);
        popUpString.string = content;
        self.scheduleOnce(function(){
            popUp.active = false;
        }, 2);

    }
    popUpError(message) {
        let self = this;
        switch (message.Error) {
            case ErrNoHandler:
                self.playPopup("没有对应的Code"); break
            case ErrUserExit:
                self.playPopup("用户已存在"); break
            case ErrUserNotExit:
                self.playPopup("用户不存在"); break
            case ErrCannotEnterRoom:
                self.playPopup("不能进入房间"); break
            case ErrFailedEntering:
                self.playPopup("不能进入房间！"); break
            case ErrNoSuchPlayer:
                self.playPopup("没有此用户"); break
            case ErrCannotExitRoom:
                self.playPopup("无法退出房间"); break
            case ErrGameStarted:
                self.playPopup("游戏已经开始"); break
            case ErrUserNotInRoom:
                self.playPopup("用户不在房间"); break
            case ErrUserNotCaptain:
                self.playPopup("用户不是船长"); break
        }
    }

    messageToGlobal(message) {
        if (message.Error >= 0 && message.Ans.RoomNum !== 0) {
            let mapList = message.Ans.Mapp || [];
            let playerList = message.Ans.Players || [];
            for (let i = 0; i < mapList.length; i++) {
                Global.mapp[mapList[i].Name] = mapList[i];
            }
            for (let j = 0; j < playerList.length; j++) {
                Global.allPlayers[playerList[j].Name] = playerList[j];
                if (playerList[j].Name === Global.playerUser) {
                    Global.readied = playerList[j].Ready;
                    Global.seat = playerList[j].Seat;
                    Global.money = playerList[j].Money;
                }
            }
            Global.deck = message.Ans.Deck;
            Global.stockprice = message.Ans.StockPrice;
            Global.round = message.Ans.Round;
            Global.roomNum = message.Ans.RoomNum;
            Global.allPlayerName = message.Ans.PlayerName;
            Global.started = message.Ans.Started;
            Global.highestBidder = message.Ans.HighestBidder;
            Global.highestBidPrice = message.Ans.HighestBidPrice;
            Global.currentPlayer = message.Ans.CurrentPlayer;
            Global.phase = message.Ans.Phase;
            Global.ship = message.Ans.Ship;
        }
    }

    onSocketOpen() {
        Global.online = true;
    }

    onSocketClose() {
        cc.director.loadScene("StartMenu");
        Global.playerUser = ""
        Global.online = false;
    }

    playNotEnoughMoney() {
        console.log("不够钱！是否抵押股票？");
    }
}