import { ManilaSocket, RoomDetailMsg, readymsg, GameStartMsg, gamestartmsg } from "../Fundamentals/Imports"
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

    onLoad() {
        super.onLoad();
        let self = this;
        // // self.j();
        self.phaseCatcher.node.active = false
        self.renderGlobal();
        EventMng.on(RoomDetailMsg, self.onRoomDetailMsg, self);
        EventMng.on(GameStartMsg, self.onGameStartMsg, self);
        EventMng.on("Ready", self.sendReadyOrNot, self);



    }

    j() {
        Global.started = false;
        Global.playerUser = "apple";
        Global.allPlayerName = ["apple", "boy", "cat", "dog",];
        Global.allPlayers = {
            "apple": { "Name": "apple", "Money": 0, "Stock": 0, "Online": true, "Seat": 1 },
            "boy": { "Name": "boy", "Money": 0, "Stock": 1, "Online": true, "Seat": 2 },
            "cat": { "Name": "cat", "Money": 100, "Stock": 2, "Online": true, "Seat": 3 },
            "dog": { "Name": "dog", "Money": 200, "Stock": 3, "Online": true, "Seat": 4 },
            // "eat": { "Name": "eat", "Money": 3, "Stock": 4, "Online": true, "Seat": 5 },
        }
        Global.jadedeck = Global.ginsengdeck = Global.coffeedeck = Global.silkdeck = 5;
        Global.mapp = {
            "1tick": { "Name": "1tick", "Taken": "", "Price": 4, "Award": 6, "Onboard": true },
            "2tick": { "Name": "2tick", "Taken": "", "Price": 3, "Award": 8, "Onboard": true },
            "3tick": { "Name": "3tick", "Taken": "", "Price": 2, "Award": 15, "Onboard": true },

            "1fail": { "Name": "1fail", "Taken": "", "Price": 4, "Award": 6, "Onboard": true },
            "2fail": { "Name": "2fail", "Taken": "", "Price": 3, "Award": 8, "Onboard": true },
            "3fail": { "Name": "3fail", "Taken": "", "Price": 2, "Award": 15, "Onboard": true },


            "1drag": { "Name": "1drag", "Taken": "", "Price": 2, "Award": 0, "Onboard": true },
            "2drag": { "Name": "2drag", "Taken": "", "Price": 5, "Award": 0, "Onboard": true },

            "1jade": { "Name": "1jade", "Taken": "", "Price": 3, "Award": 0, "Onboard": false },
            "2jade": { "Name": "2jade", "Taken": "", "Price": 4, "Award": 0, "Onboard": false },
            "3jade": { "Name": "3jade", "Taken": "", "Price": 5, "Award": 0, "Onboard": false },
            "4jade": { "Name": "4jade", "Taken": "", "Price": 5, "Award": 0, "Onboard": false },

            "1ginseng": { "Name": "1ginseng", "Taken": "", "Price": 1, "Award": 0, "Onboard": false },
            "2ginseng": { "Name": "2ginseng", "Taken": "", "Price": 2, "Award": 0, "Onboard": false },
            "3ginseng": { "Name": "3ginseng", "Taken": "", "Price": 3, "Award": 0, "Onboard": false },

            "1coffee": { "Name": "1coffee", "Taken": "", "Price": 2, "Award": 0, "Onboard": false },
            "2coffee": { "Name": "2coffee", "Taken": "", "Price": 3, "Award": 0, "Onboard": false },
            "3coffee": { "Name": "3coffee", "Taken": "", "Price": 4, "Award": 0, "Onboard": false },


            "1silk": { "Name": "1silk", "Taken": "", "Price": 3, "Award": 0, "Onboard": false },
            "2silk": { "Name": "2silk", "Taken": "", "Price": 4, "Award": 0, "Onboard": false },
            "3silk": { "Name": "3silk", "Taken": "", "Price": 5, "Award": 0, "Onboard": false },

            "1pirate": { "Name": "1pirate", "Taken": "", "Price": 5, "Award": 0, "Onboard": true },
            "2pirate": { "Name": "2pirate", "Taken": "", "Price": 5, "Award": 0, "Onboard": true },


            "repair": { "Name": "repair", "Taken": "", "Price": 0, "Award": 10, "Onboard": true },

        }


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
            let myPlayer = ordered[myIndex];
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
                let readySpriteNode = scriptPlayer.getChildByName("Ready");
                readySpriteNode.active = player.Ready ? true : false;

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
            let phaseString = self.phaseCatcher.node.getChildByName(  "PhaseString").getComponent(cc.Label);
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
}
