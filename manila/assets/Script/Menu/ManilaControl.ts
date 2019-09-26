import { ManilaSocket, RoomDetailMsg, readymsg, GameStartMsg, BidMsg, bidmsg } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import EventMng from "../Fundamentals/Manager/EventMng";
import BasicControl from "./BasicControl"
const { ccclass, property } = cc._decorator;

@ccclass
export default class ManilaControl extends BasicControl {

    @property([cc.SpriteFrame])
    pawnChoice: [cc.SpriteFrame] = [new cc.SpriteFrame()]

    @property(cc.Prefab)
    nameScript: cc.Prefab = null

    @property(cc.Sprite)
    mapSprite: cc.Sprite = null

    @property(cc.Sprite)
    readySprite: cc.Sprite = null

    @property(cc.Node)
    putNode: cc.Node = null

    @property([cc.SpriteFrame])
    readyChoices: [cc.SpriteFrame] = [new cc.SpriteFrame()]

    @property(cc.Sprite)
    phaseCatcher: cc.Sprite = null

    @property(cc.Node)
    bidNode: cc.Node = null

    onLoad() {
        super.onLoad();
        let self = this;
        // // self.j();
        self.renderGlobal();
        EventMng.on(RoomDetailMsg, self.onRoomDetailMsg, self);
        EventMng.on(GameStartMsg, self.onGameStartMsg, self);
        EventMng.on(BidMsg, self.onBidMsg, self);
        EventMng.on("Ready", self.sendReadyOrNot, self);
        EventMng.on("Bid", self.sendBid, self);
    }


    renderGlobal() {
        let self = this;

        if (Global.started === false) {
            self.mapSprite.node.active = false;
            self.readySprite.node.active = true;

        } else {
            self.mapSprite.node.active = true;
            self.readySprite.node.active = false;
            let action = cc.repeat(
                cc.sequence(
                    cc.scaleTo(0.2, 1.5, 1.5),
                    cc.scaleTo(0.2, 1, 1),
                ), 1);
            self.mapSprite.node.runAction(action);
        }

        let allPlayers = Global.allPlayerName;
        let myName = Global.playerUser;
        let len = allPlayers.length;
        let myIndex = allPlayers.indexOf(myName);
        if (myIndex !== -1) {
            // 设定显示顺序
            let orderedO = []
            for (let i = 0; i < allPlayers.length; i++) {
                if (allPlayers[i] !== "") {
                    orderedO.push(allPlayers[i]);
                }
            }

            let ordered = orderedO.splice(myIndex, len).concat(orderedO.splice(0, len));

            // 设定准备按钮状态
            self.readySprite.getComponent(cc.Sprite).spriteFrame = Global.readied ? self.readyChoices[1] : self.readyChoices[0];

            let ystart = 500;
            let xstart = 270;
            let ymargin = -200;
            self.putNode.removeAllChildren();

            for (let i = 0; i < ordered.length; i++) {

                let username = ordered[i];
                let player = Global.allPlayers[username];
                let scriptPlayer = cc.instantiate(self.nameScript);

                // 设置属性
                let tokenSpriteNode = scriptPlayer.getChildByName("Token")
                let tokenSprite = tokenSpriteNode.getComponent(cc.Sprite);
                tokenSprite.spriteFrame = self.pawnChoice[player.Seat - 1];
                let name = scriptPlayer.getChildByName("Name").getComponent(cc.Label);
                name.string = username;
                let money = scriptPlayer.getChildByName("Money").getComponent(cc.Label);
                money.string = player.Money;
                let stock = scriptPlayer.getChildByName("Stock").getComponent(cc.Label);
                stock.string = player.Stock;
                let stateSpriteNode = scriptPlayer.getChildByName("State");
                if (Global.started == false) {
                    stateSpriteNode.active = player.Ready ? true : false;
                    stateSpriteNode.getComponent(cc.Sprite).spriteFrame = self.readyChoices[0];
                } else {
                    stateSpriteNode.active = player.Name === Global.currentPlayer ? true : false;
                    stateSpriteNode.getComponent(cc.Sprite).spriteFrame = self.readyChoices[2];
                }
                let offlineNode = scriptPlayer.getChildByName("Offline");
                offlineNode.active = player.Online ? false : true;

                // 设定位置
                scriptPlayer.y = ystart;
                scriptPlayer.x = xstart;
                ystart += ymargin;
                self.putNode.addChild(scriptPlayer);

                // 动画
                let action = cc.repeat(
                    cc.sequence(
                        cc.scaleTo(0.2, 1.5, 1.5),
                        cc.scaleTo(0.2, 1, 1),
                    ), len);
                tokenSpriteNode.runAction(action);

            }
        }
    }




    onRoomDetailMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else {
            self.messageToGlobal(message);
            self.renderGlobal();
            console.log("ManilaControl: ", message.Code, message);
        }
    }

    sendReadyOrNot(readied: boolean) {
        let readymsgobj = JSON.parse(JSON.stringify(readymsg));
        readymsgobj.Req.Username = Global.playerUser
        readymsgobj.Req.Ready = readied;
        ManilaSocket.send(readymsgobj);
    }

    onGameStartMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else {
            console.log("ManilaControl: ", message.Code, message);
            self.phaseCatcher.node.active = true;
            let phaseString = self.phaseCatcher.node.getChildByName("PhaseString").getComponent(cc.Label);
            phaseString.string = "Bidding";

            // 动画
            let action = cc.sequence(
                cc.callFunc(function () {
                    self.phaseCatcher.node.active = true;
                }),
                cc.fadeTo(0, 0),
                cc.fadeTo(2.0, 255),
                cc.fadeTo(2.0, 0),
                cc.callFunc(function () {
                    self.phaseCatcher.node.active = false;
                })
            );
            self.phaseCatcher.node.runAction(action);
        }
    }

    onBidMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else {
            console.log(message);
            if (Global.playerUser === message.Ans.Username) {
                self.bidNode.active = true
                let bidString = self.bidNode.getChildByName("CurrentBidPrice").getComponent(cc.Label);
                bidString.string = message.Ans.CurrentBidPrice
            }
        }
    }

    sendBid(data) {
        console.log(data);
        let self = this;
        let dp = parseInt(data);
        let price = Global.highestBidPrice;
        let bidPrice = dp === 0 ? dp : (price + dp);
        let bidmsgobj = JSON.parse(JSON.stringify(bidmsg));
        bidmsgobj.Req.Username = Global.playerUser;
        bidmsgobj.Req.Bid = bidPrice;
        ManilaSocket.send(bidmsgobj);
        self.bidNode.active = false;
    }

}
