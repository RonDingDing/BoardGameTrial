const { ccclass, property } = cc._decorator;
import EventMng from "../Fundamentals/Manager/EventMng";
import {
    SocketEvents, ErrNoHandler, ErrUserExit, ErrUserNotExit, ErrCannotEnterRoom, ErrNoSuchPlayer, ErrCannotExitRoom, ErrGameStarted, ErrUserNotInRoom, ErrFailedEntering, ErrUserNotCaptain, ErrNotEnoughStock, ErrInvalidInvestPoint, ErrInvestPointTaken
} from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import i18n = require("LanguageData");

@ccclass
export default class BasicControl extends cc.Component {

    @property(cc.Prefab)
    popUp: cc.Prefab = null;

    @property(cc.Canvas)
    canvas: cc.Canvas = null;


    onLoad() {
        var self = this;
        i18n.init(Global.language);
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
        self.scheduleOnce(function () {
            popUp.active = false;
        }, 2);

    }
    popUpError(message) {
        let self = this;
        switch (message.Error) {
            case ErrNoHandler:
                self.playPopup(i18n.t("No respective code!")); break
            case ErrUserExit:
                self.playPopup(i18n.t("User already exists!")); break
            case ErrUserNotExit:
                self.playPopup(i18n.t("User does not exist!")); break
            case ErrCannotEnterRoom:
                self.playPopup(i18n.t("You cannot enter the room!")); break
            case ErrFailedEntering:
                self.playPopup(i18n.t("You cannot enter the room!")); break
            case ErrNoSuchPlayer:
                self.playPopup(i18n.t("No such user!")); break
            case ErrCannotExitRoom:
                self.playPopup(i18n.t("Cannot quit the room!")); break
            case ErrGameStarted:
                self.playPopup(i18n.t("Game has started!")); break
            case ErrUserNotInRoom:
                self.playPopup(i18n.t("User is not in room!")); break
            case ErrUserNotCaptain:
                self.playPopup(i18n.t("Player is not captain!")); break
            case ErrNotEnoughStock:
                self.playPopup(i18n.t("Not enough stocks to buy!")); break
            case ErrInvalidInvestPoint:
                self.playPopup(i18n.t("Invalid investment point!")); break
            case ErrInvestPointTaken:
                self.playPopup(i18n.t("Investment point is taken!")); break
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
            Global.castTime = message.Ans.CastTime;
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