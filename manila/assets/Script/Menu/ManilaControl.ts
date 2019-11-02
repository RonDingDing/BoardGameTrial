import { SilkColor, JadeColor, CoffeeColor, GinsengColor, ManilaSocket, RoomDetailMsg, readymsg, GameStartMsg, BidMsg, bidmsg, HandMsg, BuyStockMsg, buystockmsg, ChangePhaseMsg, PutBoatMsg, putboatmsg, DragBoatMsg, roomdetailmsg, PhaseDragBoat } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import { MapCoor } from "../Fundamentals/ManilaMapCoordinate"
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
    readyChoices: [cc.SpriteFrame, cc.SpriteFrame, cc.SpriteFrame] = [new cc.SpriteFrame(), new cc.SpriteFrame(), new cc.SpriteFrame()]

    @property(cc.Sprite)
    phaseCatcher: cc.Sprite = null

    @property(cc.Node)
    bidNode: cc.Node = null

    @property(cc.Prefab)
    bidPrefab: cc.Prefab = null

    @property(cc.Node)
    buyStockNode: cc.Node = null

    @property(cc.Prefab)
    buyStockPrefab: cc.Prefab = null

    @property(cc.Sprite)
    buyStocker: cc.Sprite = null

    @property(cc.Node)
    putBoatNode: cc.Node = null

    @property(cc.Prefab)
    putBoatPrefab: cc.Prefab = null

    @property(cc.SpriteFrame)
    stockToken: cc.SpriteFrame = null

    @property([cc.Prefab])
    shipPrefab: [cc.Prefab] = [new cc.Prefab()]

    @property(cc.Node)
    dragBoatNode: cc.Node = null

    @property(cc.Prefab)
    dragBoatPrefab: cc.Prefab = null

    onLoad() {
        super.onLoad();
        let self = this;

        self.j();

        self.renderGlobal();
        EventMng.on(RoomDetailMsg, self.onRoomDetailMsg, self);
        EventMng.on(GameStartMsg, self.onGameStartMsg, self);
        EventMng.on(BidMsg, self.onBidMsg, self);
        EventMng.on(HandMsg, self.onHandMsg, self);
        EventMng.on(BuyStockMsg, self.onBuyStockMsg, self);
        EventMng.on(ChangePhaseMsg, self.onChangePhaseMsg, self);
        EventMng.on(PutBoatMsg, self.onPutBoatMsg, self);
        EventMng.on(DragBoatMsg, self.onDragBoatMsg, self);
        EventMng.on("Ready", self.sendReadyOrNot, self);
        EventMng.on("Bid", self.sendBid, self);
        EventMng.on("BuyStock", self.sendBuyStock, self);
        EventMng.on("PutBoat", self.sendPutBoat, self);
    }

    j() {
        // let self = this;
        // Global.started = true;
        // Global.ship = [
        //     { ShipType: 1, Step: -1 },
        //     { ShipType: 2, Step: 14 },
        //     { ShipType: 3, Step: 15},
        //     { ShipType: 4, Step: 19 }
        // ]

    }

    renderGlobal() {
        let self = this;
        if (Global.started) {
            self.mapSprite.node.active = true;
            self.readySprite.node.active = false;
            self.renderMap();
        } else {
            self.mapSprite.node.active = false;
            self.readySprite.node.active = true;
        }

        let allPlayers = Global.allPlayerName;
        let myName = Global.playerUser;
        let len = allPlayers.length;
        let myIndex = allPlayers.indexOf(myName);
        if (myIndex !== -1) {
            // 设定玩家显示顺序
            let orderedO = []
            for (let i = 0; i < allPlayers.length; i++) {
                if (allPlayers[i] !== "") {
                    orderedO.push(allPlayers[i]);
                }
            }

            let ordered = orderedO.splice(myIndex, len).concat(orderedO.splice(0, len));

            // 设定大的准备按钮状态
            self.readySprite.getComponent(cc.Sprite).spriteFrame = Global.readied ? self.readyChoices[1] : self.readyChoices[0];

            let ystart = MapCoor.playerYstart;
            let xstart = MapCoor.playerXstart;
            let ymargin = MapCoor.playerYmargin;
            self.putNode.removeAllChildren();

            for (let i = 0; i < ordered.length; i++) {

                let username = ordered[i];
                let player = Global.allPlayers[username];
                let scriptPlayer = cc.instantiate(self.nameScript);

                // 设置玩家属性
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

                // 设定玩家展示节点位置
                scriptPlayer.y = ystart;
                scriptPlayer.x = xstart;
                ystart += ymargin;
                self.putNode.addChild(scriptPlayer);

                // 动画
                let action = cc.sequence(
                    cc.scaleTo(0.2, 1.5, 1.5),
                    cc.scaleTo(0.2, 1, 1),
                );
                tokenSpriteNode.runAction(action);

            }
        }
    }

    renderMap() {
        let self = this;
        let mapNode = self.mapSprite.node;
        mapNode.removeAllChildren();

        // 股票价格展示
        let y = MapCoor.stockYstart;
        let x = MapCoor.stockXstart;

        let prices = Global.stockprice;
        for (let i = 0; i < 4; i++) {
            let priceUnderNode = new cc.Node;
            let priceSprite = priceUnderNode.addComponent(cc.Sprite);
            priceSprite.spriteFrame = self.stockToken;
            mapNode.addChild(priceUnderNode);
            y = MapCoor.stockYstart + MapCoor.stockPriceGap[prices[i]] * MapCoor.stockYmargin;
            x += MapCoor.stockXmargin;
            priceUnderNode.x = x;
            priceUnderNode.y = y;
        }

        // 船展示 TODO
        let shipSocket = 0;
        for (let shipType = 0; shipType < Global.ship.length; shipType++) {
            let step = Global.ship[shipType];
            if (step >= 0 && step <= 19) {
                let shipUnderNode = cc.instantiate(self.shipPrefab[shipType]);
                self.mapSprite.node.addChild(shipUnderNode);
                self.setShipPosition(shipUnderNode, shipSocket, step);
                shipSocket += 1;
                if (shipSocket > 3) {
                    break;
                }
            }
        }

    }

    setShipPosition(shipUnderNode, shipsocket, step) {
        let x = 0;
        let y = 0;
        let r = 0;
        if (step < 0) {
            x = MapCoor.shipXout;
            y = MapCoor.shipYout;
        } else if (step <= 19) {
            x = MapCoor.shipXs[step][shipsocket];
            y = MapCoor.shipYs[step][shipsocket];
            r = MapCoor.shipRs[step][shipsocket];
        }
        shipUnderNode.x = x;
        shipUnderNode.y = y;
        shipUnderNode.angle = -r;
    }

    onRoomDetailMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else {
            self.messageToGlobal(message);
            self.renderGlobal();
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


            let act = cc.repeat(
                cc.sequence(
                    cc.scaleTo(0.2, 1.5, 1.5),
                    cc.scaleTo(0.2, 1, 1),
                ), 1);
            self.mapSprite.node.runAction(act);
        }
    }

    onBidMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else {
            self.bidNode.active = true;
            let bidUnderNode = cc.instantiate(self.bidPrefab);
            let bidBackground = bidUnderNode.getChildByName("BidBackground");

            let bidButtons = bidUnderNode.getChildByName("BidButtons");
            let bidString = bidBackground.getChildByName("HighestBid").getComponent(cc.Label);
            bidString.string = "Bid " + message.Ans.HighestBidPrice + " from " + message.Ans.HighestBidder;
            if (Global.playerUser === message.Ans.Username) {
                bidButtons.active = true;
            } else {
                bidButtons.active = false;
                self.scheduleOnce(function () {
                    bidBackground.active = false;
                }, 5);
            }
            self.bidNode.addChild(bidUnderNode);
        }
    }

    sendBid(data) {
        let self = this;
        if (Global.currentPlayer === Global.playerUser) {
            let dp = parseInt(data);
            let price = Global.highestBidPrice;
            let bidPrice = dp === 0 ? (dp) : (price + dp);
            if (bidPrice > Global.money) {
                self.playNotEnoughMoney();
                return
            }
            let bidmsgobj = JSON.parse(JSON.stringify(bidmsg));
            bidmsgobj.Req.Username = Global.playerUser;
            bidmsgobj.Req.Bid = bidPrice;
            ManilaSocket.send(bidmsgobj);
        }
        self.bidNode.active = false;
    }

    onHandMsg(message) {
        if (Global.playerUser === message.Ans.Username) {
            Global.hand = message.Ans.Hand;
        }
    }

    onBuyStockMsg(message) {
        let self = this;
        self.bidNode.active = false;
        if (message.Error < 0) {
            self.popUpError(message);
        } else if (message.Ans.RemindOrOperated && Global.playerUser === message.Ans.Username) {

            self.buyStockNode.active = true;
            let buyStockUnderNode = cc.instantiate(self.buyStockPrefab);
            let silkNode = buyStockUnderNode.getChildByName("SilkDeck");
            let jadeNode = buyStockUnderNode.getChildByName("JadeDeck");
            let coffeeNode = buyStockUnderNode.getChildByName("CoffeeDeck");
            let ginsengNode = buyStockUnderNode.getChildByName("GinsengDeck");

            let silkString = silkNode.getComponent(cc.Label);
            silkString.string = message.Ans.Deck[SilkColor - 1];

            let jadeString = jadeNode.getComponent(cc.Label);
            jadeString.string = message.Ans.Deck[JadeColor - 1];

            let coffeeString = coffeeNode.getComponent(cc.Label);
            coffeeString.string = message.Ans.Deck[CoffeeColor - 1];

            let ginsengString = ginsengNode.getComponent(cc.Label);
            ginsengString.string = message.Ans.Deck[GinsengColor - 1];

            self.buyStockNode.addChild(buyStockUnderNode);

        } else if (!message.Ans.RemindOrOperated && message.Ans.RoomNum === Global.roomNum) {
            let username = message.Ans.Username;
            let bought = message.Ans.Bought;
            let stockName = "";
            if (bought > 0) {
                stockName = "1 stock.";
            }
            else {
                stockName = "0 stock.";
            }

            self.playBuyStocker(username + " bought " + stockName);
        }

    }
    sendBuyStock(data) {
        let self = this;
        if (Global.currentPlayer === Global.playerUser) {
            let stock = parseInt(data);
            let buystockmsgobj = JSON.parse(JSON.stringify(buystockmsg));
            let stockprice;
            switch (stock) {
                case SilkColor:
                    stockprice = Global.stockprice[SilkColor - 1] || 5; break;
                case JadeColor:
                    stockprice = Global.stockprice[JadeColor - 1] || 5; break;
                case CoffeeColor:
                    stockprice = Global.stockprice[CoffeeColor - 1] || 5; break;
                case GinsengColor:
                    stockprice = Global.stockprice[GinsengColor] || 5; break;
                default:
                    stockprice = 0;
            }
            if (stockprice > Global.money) {
                self.playNotEnoughMoney();
                return
            }
            if (Global.deck[stock - 1] === 0) {
                self.playPopup("没有足够的股票可买")
                return
            }
            buystockmsgobj.Req.Username = Global.playerUser;
            buystockmsgobj.Req.Stock = stock;
            ManilaSocket.send(buystockmsgobj);
            self.buyStockNode.active = false;
        }
    }

    playCatcher(string) {
        let self = this;
        self.phaseCatcher.node.active = true;
        let action = cc.sequence(
            cc.callFunc(function () {
                let phaseString = self.phaseCatcher.node.getChildByName("PhaseString").getComponent(cc.Label);
                phaseString.string = string;

            }),
            cc.fadeTo(1.0, 255),
            cc.fadeTo(2.0, 0),
        );
        self.phaseCatcher.node.runAction(action);
    }

    playBuyStocker(string) {
        let self = this;
        self.buyStocker.node.active = true;
        let action = cc.sequence(
            cc.callFunc(function () {
                let phaseString = self.buyStocker.node.getChildByName("PhaseString").getComponent(cc.Label);
                phaseString.string = string;

            }),
            cc.fadeTo(1.0, 255),
            cc.fadeTo(2.0, 0),
        );
        self.buyStocker.node.runAction(action);
    }

    onChangePhaseMsg(message) {
        let self = this;
        if (Global.roomNum === message.Ans.RoomNum) {
            self.playCatcher(message.Ans.Phase);
        }
    }

    onPutBoatMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else if (message.Ans.RemindOrOperated && Global.playerUser === message.Ans.Username) {
            self.putBoatNode.active = true;
            self.putBoatNode.removeAllChildren();
            let putBoatUnderNode = cc.instantiate(self.putBoatPrefab);
            self.putBoatNode.addChild(putBoatUnderNode);
        }
    }

    sendPutBoat(except, ok) {
        let self = this;
        if (ok) {
            let putboatmsgobj = JSON.parse(JSON.stringify(putboatmsg));
            putboatmsgobj.Req.Username = Global.playerUser;
            putboatmsgobj.Req.RoomNum = Global.roomNum;
            putboatmsgobj.Req.Except = except;
            ManilaSocket.send(putboatmsgobj);
            self.putBoatNode.active = false;
        } else {
            self.playPopup("请选择三种货物");
        }
    }

    onDragBoatMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else if (message.Ans.RemindOrOperated && Global.playerUser === message.Ans.Username) {
            self.dragBoatNode.active = true;
            self.dragBoatNode.removeAllChildren();
            let dragBoatUnderNode = cc.instantiate(self.dragBoatPrefab);
            self.dragBoatNode.addChild(dragBoatUnderNode);
            let draggerScript = dragBoatUnderNode.getChildByName("Dragger").getComponent("Dragger");
            let pics = draggerScript.shipPics;
            draggerScript.phase = message.Ans.Phase;

            let dragable = message.Ans.Dragable;
            if (dragable.length < 3) {
                for (let i = 0; i < 3 - dragable.length; i++) {
                    dragable.push(0);
                }
            }
            for (let i = 0; i < dragable.length; i++) {
                let spriteNode = dragBoatUnderNode.getChildByName('Stock' + (i + 1));
                let sprite = spriteNode.getComponent(cc.Sprite);
                let dragShipType = dragable[i];
                if (dragShipType === 0) {
                    dragBoatUnderNode.getChildByName('Stock' + (i + 1)).active = false;
                    dragBoatUnderNode.getChildByName('MinusStock' + (i + 1)).active = false;
                    dragBoatUnderNode.getChildByName('PlusStock' + (i + 1)).active = false;
                    dragBoatUnderNode.getChildByName('DragStock' + (i + 1)).active = false;
                } else {
                    sprite.spriteFrame = pics[dragShipType - 1];
                }

            }

        }

    }
}
