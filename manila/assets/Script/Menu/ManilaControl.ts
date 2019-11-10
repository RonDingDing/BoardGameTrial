import { SilkColor, JadeColor, CoffeeColor, GinsengColor, ManilaSocket, RoomDetailMsg, readymsg, GameStartMsg, BidMsg, bidmsg, HandMsg, BuyStockMsg, buystockmsg, ChangePhaseMsg, PutBoatMsg, putboatmsg, DragBoatMsg, roomdetailmsg, PhaseDragBoat, dragboatmsg, InvestMsg, investmsg, PirateMsg, piratemsg, ColorString, Colors, DecideTickFailMsg, decidetickfailmsg, StringColor, ErrInvalidInvestPoint, OneTickSpot, ThreeTickSpot } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import { MapCoor } from "../Fundamentals/ManilaMapCoordinate"
import EventMng from "../Fundamentals/Manager/EventMng";
import BasicControl from "./BasicControl"
const { ccclass, property } = cc._decorator;

function startsWith(str: string, prefix: string) {
    return str.slice(0, prefix.length) === prefix;
}

function endsWith(str: string, suffix: string) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

@ccclass
export default class ManilaControl extends BasicControl {


    @property(cc.Prefab)
    nameScriptPrefab: cc.Prefab = null

    @property(cc.Sprite)
    mapSprite: cc.Sprite = null

    @property(cc.Node)
    readyNode: cc.Node = null

    @property(cc.Prefab)
    readyPrefab: cc.Prefab = null

    @property(cc.Node)
    putNode: cc.Node = null

    @property(cc.Node)
    catchNode: cc.Node = null

    @property(cc.Prefab)
    catchPrefab: cc.Prefab = null

    @property(cc.Node)
    bidNode: cc.Node = null

    @property(cc.Prefab)
    bidPrefab: cc.Prefab = null

    @property(cc.Node)
    buyStockNode: cc.Node = null

    @property(cc.Prefab)
    buyStockPrefab: cc.Prefab = null


    @property(cc.Node)
    putBoatNode: cc.Node = null

    @property(cc.Prefab)
    putBoatPrefab: cc.Prefab = null

    @property(cc.SpriteFrame)
    stockToken: cc.SpriteFrame = null

    @property(cc.Prefab)
    allShipsPrefab: cc.Prefab = null

    @property(cc.Node)
    dragBoatNode: cc.Node = null

    @property(cc.Prefab)
    dragBoatPrefab: cc.Prefab = null

    @property(cc.Prefab)
    pawnPrefab: cc.Prefab = null

    @property(cc.Node)
    pirateNode: cc.Node = null

    @property(cc.Prefab)
    piratePrefab: cc.Prefab = null

    @property(cc.Node)
    investPassNode: cc.Node = null

    @property(cc.Prefab)
    investPassPrefab: cc.Prefab = null

    @property(cc.Node)
    decideTickFailNode: cc.Node = null

    @property(cc.Prefab)
    decideTickFailPrefab: cc.Prefab = null



    onLoad() {
        super.onLoad();
        let self = this;

        // self.j();

        self.renderGlobal();
        EventMng.on(RoomDetailMsg, self.onRoomDetailMsg, self);
        EventMng.on(GameStartMsg, self.onGameStartMsg, self);
        EventMng.on(BidMsg, self.onBidMsg, self);
        EventMng.on(HandMsg, self.onHandMsg, self);
        EventMng.on(BuyStockMsg, self.onBuyStockMsg, self);
        EventMng.on(ChangePhaseMsg, self.onChangePhaseMsg, self);
        EventMng.on(PutBoatMsg, self.onPutBoatMsg, self);
        EventMng.on(DragBoatMsg, self.onDragBoatMsg, self);
        EventMng.on(InvestMsg, self.onInvestMsg, self);
        EventMng.on(PirateMsg, self.onPirateMsg, self);
        EventMng.on(DecideTickFailMsg, self.onDecideTickFailMsg, self);
        EventMng.on("Ready", self.sendReadyOrNot, self);
        EventMng.on("Bid", self.sendBid, self);
        EventMng.on("BuyStock", self.sendBuyStock, self);
        EventMng.on("PutBoat", self.sendPutBoat, self);
        EventMng.on("DragBoat", self.sendDragBoat, self);
        EventMng.on("InvestOnshore", self.sendInvest, self);
        EventMng.on("InvestOnboat", self.sendInvest, self);
        EventMng.on("PiratePlunder", self.sendPirate, self);
        EventMng.on("DecideTickFail", self.sendDecideTickFail, self);
    }

    j() {
        let self = this;

        Global.started = true;
        Global.stockprice = [0, 20, 5, 30];
        Global.ship = [1, 1, -1, 1];

        Global.mapp = {

            "1tick": { "Name": "1tick", "Taken": "", "Price": 4, "Award": 6, "Onboard": true },
            "2tick": { "Name": "2tick", "Taken": "", "Price": 3, "Award": 8, "Onboard": true },
            "3tick": { "Name": "3tick", "Taken": "", "Price": 2, "Award": 15, "Onboard": true },

            "1fail": { "Name": "1fail", "Taken": "", "Price": 4, "Award": 6, "Onboard": true },
            "2fail": { "Name": "2fail", "Taken": "", "Price": 3, "Award": 8, "Onboard": true },
            "3fail": { "Name": "3fail", "Taken": "", "Price": 2, "Award": 15, "Onboard": true },

            "1pirate": { "Name": "1pirate", "Taken": "", "Price": 5, "Award": 0, "Onboard": true },
            "2pirate": { "Name": "2pirate", "Taken": "", "Price": 5, "Award": 0, "Onboard": true },

            "1drag": { "Name": "1drag", "Taken": "", "Price": 2, "Award": 0, "Onboard": true },
            "2drag": { "Name": "2drag", "Taken": "", "Price": 5, "Award": 0, "Onboard": true },

            "repair": { "Name": "repair", "Taken": "", "Price": 0, "Award": 10, "Onboard": true },

            "1coffee": { "Name": "1coffee", "Taken": "a", "Price": 2, "Award": 0, "Onboard": false },
            "2coffee": { "Name": "2coffee", "Taken": "a", "Price": 3, "Award": 0, "Onboard": false },
            "3coffee": { "Name": "3coffee", "Taken": "a", "Price": 4, "Award": 0, "Onboard": false },

            "1silk": { "Name": "1silk", "Taken": "a", "Price": 3, "Award": 0, "Onboard": false },
            "2silk": { "Name": "2silk", "Taken": "b", "Price": 4, "Award": 0, "Onboard": false },
            "3silk": { "Name": "3silk", "Taken": "c", "Price": 5, "Award": 0, "Onboard": false },

            "1jade": { "Name": "1jade", "Taken": "a", "Price": 3, "Award": 0, "Onboard": false },
            "2jade": { "Name": "2jade", "Taken": "b", "Price": 4, "Award": 0, "Onboard": false },
            "3jade": { "Name": "3jade", "Taken": "c", "Price": 5, "Award": 0, "Onboard": false },
            "4jade": { "Name": "4jade", "Taken": "", "Price": 5, "Award": 0, "Onboard": false },

            "1ginseng": { "Name": "1ginseng", "Taken": "a", "Price": 1, "Award": 0, "Onboard": false },
            "2ginseng": { "Name": "2ginseng", "Taken": "b", "Price": 2, "Award": 0, "Onboard": false },
            "3ginseng": { "Name": "3ginseng", "Taken": "c", "Price": 3, "Award": 0, "Onboard": false },
        };

        Global.allPlayers = {
            "a": { "Money": 12, "Name": "a", "Online": true, "Stock": 3, "Seat": 1, "Ready": false, "Canbid": true }, "b": { "Money": 30, "Name": "b", "Online": true, "Stock": 2, "Seat": 2, "Ready": false, "Canbid": false }, "c": { "Money": 30, "Name": "c", "Online": true, "Stock": 2, "Seat": 3, "Ready": false, "Canbid": false }
        };
    }

    renderGlobal() {
        let self = this;
        if (Global.started) {
            self.mapSprite.node.active = true;
            self.readyNode.active = false;
            self.renderMap();
        } else {
            self.mapSprite.node.active = false;
            self.readyNode.active = true;
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
            let readyInstance = cc.instantiate(self.readyPrefab);
            self.readyNode.removeAllChildren();
            self.readyNode.addChild(readyInstance);
            let readyScript = readyInstance.getChildByName("ReadyButtonC").getComponent("ReadyButton");
            readyInstance.getComponent(cc.Sprite).spriteFrame = Global.readied ? readyScript.readyPics[1] : readyScript.readyPics[0];

            let ystart = MapCoor.playerYstart;
            let xstart = MapCoor.playerXstart;
            let ymargin = MapCoor.playerYmargin;
            self.putNode.removeAllChildren();

            for (let i = 0; i < ordered.length; i++) {

                let username = ordered[i];
                let player = Global.allPlayers[username];
                let nameScriptInstance = cc.instantiate(self.nameScriptPrefab);

                // 设置玩家属性
                let tokenSpriteNode = nameScriptInstance.getChildByName("Token");
                let nameScripter = nameScriptInstance.getChildByName("NameScripter").getComponent("NameScripter");
                let pawnChoices = nameScripter.pawnPics;
                let readyChoices = nameScripter.readyPics;


                let tokenSprite = tokenSpriteNode.getComponent(cc.Sprite);
                tokenSprite.spriteFrame = pawnChoices[player.Seat - 1];
                let name = nameScriptInstance.getChildByName("Name").getComponent(cc.Label);
                name.string = username;
                let money = nameScriptInstance.getChildByName("Money").getComponent(cc.Label);
                money.string = player.Money;
                let stock = nameScriptInstance.getChildByName("Stock").getComponent(cc.Label);
                stock.string = player.Stock;
                let stateSpriteNode = nameScriptInstance.getChildByName("State");
                if (Global.started == false) {
                    stateSpriteNode.active = player.Ready ? true : false;
                    stateSpriteNode.getComponent(cc.Sprite).spriteFrame = readyChoices[0];
                } else {
                    stateSpriteNode.active = player.Name === Global.currentPlayer ? true : false;
                    stateSpriteNode.getComponent(cc.Sprite).spriteFrame = readyChoices[2];
                }
                let offlineNode = nameScriptInstance.getChildByName("Offline");
                offlineNode.active = player.Online ? false : true;

                // 设定玩家展示节点位置
                nameScriptInstance.y = ystart;
                nameScriptInstance.x = xstart;
                ystart += ymargin;
                self.putNode.addChild(nameScriptInstance);

                // 动画
                let action = cc.sequence(
                    cc.scaleTo(0.2, 1.5, 1.5),
                    cc.scaleTo(0.2, 1, 1),
                );
                tokenSpriteNode.runAction(action);

            }
        }
    }

    renderShipInvest(allShipNode: cc.Node, oneShipNode: cc.Node, shipColor: number, scriptName: string) {
        let self = this;
        let pawnChoices = allShipNode.getChildByName(scriptName).getComponent(scriptName).pawnPics;
        let shipName = ColorString[shipColor].toLowerCase();
        for (let k in ColorString) {
            let investPointKey = ("" + k + shipName);
            if (Global.mapp.hasOwnProperty(investPointKey)) {
                let taken = Global.mapp[investPointKey].Taken;
                if (taken !== "") {
                    let seat = Global.allPlayers[taken].Seat;
                    let pawnSprite = oneShipNode.getChildByName(investPointKey).getComponent(cc.Sprite);
                    pawnSprite.spriteFrame = pawnChoices[seat - 1];
                }
            }
        }
    }

    renderMap() {
        let self = this;
        let mapNode = self.mapSprite.node;
        mapNode.removeAllChildren();

        // 股票价格展示
        let prices = Global.stockprice;
        for (let i = 0; i < 4; i++) {
            let priceUnderNode = new cc.Node;
            let priceSprite = priceUnderNode.addComponent(cc.Sprite);
            priceSprite.spriteFrame = self.stockToken;
            mapNode.addChild(priceUnderNode);
            let eachPrice = prices[i];
            let coor = MapCoor.stockPriceGap[eachPrice];
            let point = MapCoor.stockPoints[coor][i];
            priceUnderNode.position = new cc.Vec2(point[0], point[1]);
        }

        // 船展示
        let allShipInstance = cc.instantiate(self.allShipsPrefab);
        self.mapSprite.node.addChild(allShipInstance);
        let shipSocket = 0;
        for (let shipType = 0; shipType < Colors.length; shipType++) {
            let step = Global.ship[shipType];
            if (step >= 0 && step <= 19) {
                let shipColor = Colors[shipType];
                let shipNameCapital = "Ship" + ColorString[shipColor];
                let oneShipNode = allShipInstance.getChildByName(shipNameCapital);
                self.setShipPosition(oneShipNode, shipSocket, step);

                shipSocket += 1;
                if (shipSocket > 3) {
                    break;
                }

                // 展示船上投资
                self.renderShipInvest(allShipInstance, oneShipNode, shipColor, "BoatInvest");
                // let pawnChoices = allShipNode.getChildByName("BoatInvest").getComponent("BoatInvest").pawnPics;
                // let shipName = ColorString[shipType + 1].toLowerCase();
                // for (let k = 1; k < 5; k++) {
                //     let investPointKey = ("" + k + shipName);
                //     if (Global.mapp.hasOwnProperty(investPointKey)) {
                //         let taken = Global.mapp[investPointKey].Taken;
                //         if (taken !== "") {
                //             let seat = Global.allPlayers[taken].Seat;
                //             let pawnSprite = oneShipNode.getChildByName(investPointKey).getComponent(cc.Sprite);
                //             pawnSprite.spriteFrame = pawnChoices[seat - 1];
                //         }
                //     }
                // }
            }
        }

        // 展示岸上投资
        for (let pointName in Global.mapp) {

            if (!endsWith(pointName, "coffee")
                && !endsWith(pointName, "silk")
                && !endsWith(pointName, "ginseng")
                && !endsWith(pointName, "jade")
            ) {

                let pawnPosition = MapCoor.investOnshore[pointName];
                let pawnInstance = cc.instantiate(self.pawnPrefab);
                pawnInstance.name = pointName;
                pawnInstance.position = new cc.Vec2(pawnPosition[0], pawnPosition[1]);
                mapNode.addChild(pawnInstance);
                if (Global.mapp[pointName].Taken !== "") {
                    let taken = Global.mapp[pointName].Taken;
                    let seat = Global.allPlayers[taken].Seat;
                    let pawnSprite = pawnInstance.getChildByName("Pawn").getComponent(cc.Sprite);
                    let pawnPicChoice = pawnInstance.getChildByName("Pawner").getComponent("Pawner").pawnPics;
                    pawnSprite.spriteFrame = pawnPicChoice[seat - 1];

                }
            }
        }

    }

    setShipPosition(shipUnderNode: cc.Node, shipsocket: number, step: number) {
        let point = MapCoor.shipPointOut;
        let r = 0;
        if (step >= 0 && step <= 19) {
            point = MapCoor.shipPoints[step][shipsocket];
            r = MapCoor.shipRs[step][shipsocket];
        }
        shipUnderNode.position = new cc.Vec2(point[0], point[1]);
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
            let bidInstance = cc.instantiate(self.bidPrefab);
            let bidBackground = bidInstance.getChildByName("BidBackground");

            let bidButtons = bidInstance.getChildByName("BidButtons");
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
            self.bidNode.addChild(bidInstance);
        }
    }

    sendBid(data: string) {
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
            let buyStockInstance = cc.instantiate(self.buyStockPrefab);
            let silkNode = buyStockInstance.getChildByName("SilkDeck");
            let jadeNode = buyStockInstance.getChildByName("JadeDeck");
            let coffeeNode = buyStockInstance.getChildByName("CoffeeDeck");
            let ginsengNode = buyStockInstance.getChildByName("GinsengDeck");

            let silkString = silkNode.getComponent(cc.Label);
            silkString.string = message.Ans.Deck[SilkColor - 1];

            let jadeString = jadeNode.getComponent(cc.Label);
            jadeString.string = message.Ans.Deck[JadeColor - 1];

            let coffeeString = coffeeNode.getComponent(cc.Label);
            coffeeString.string = message.Ans.Deck[CoffeeColor - 1];

            let ginsengString = ginsengNode.getComponent(cc.Label);
            ginsengString.string = message.Ans.Deck[GinsengColor - 1];

            self.buyStockNode.addChild(buyStockInstance);

        }
        // else if (!message.Ans.RemindOrOperated && message.Ans.RoomNum === Global.roomNum) {
        //     let username = message.Ans.Username;
        //     let bought = message.Ans.Bought;
        //     let stockName = "";
        //     if (bought > 0) {
        //         stockName = "1 stock.";
        //     }
        //     else {
        //         stockName = "0 stock.";
        //     }

        //     self.playCatcher(username + " bought " + stockName, 350);
        // }

    }
    sendBuyStock(data: string) {
        let self = this;
        if (Global.currentPlayer === Global.playerUser) {
            let stock = parseInt(data);
            let buystockmsgobj = JSON.parse(JSON.stringify(buystockmsg));
            let stockprice;
            switch (stock) {
                case SilkColor:
                    stockprice = Global.stockprice[SilkColor - 1] >= 0 ? Global.stockprice[SilkColor - 1] : 5; break;
                case JadeColor:
                    stockprice = Global.stockprice[JadeColor - 1] >= 0 ? Global.stockprice[JadeColor - 1] : 5; break;
                case CoffeeColor:
                    stockprice = Global.stockprice[CoffeeColor - 1] >= 0 ? Global.stockprice[CoffeeColor - 1] : 5; break;
                case GinsengColor:
                    stockprice = Global.stockprice[GinsengColor] >= 0 ? Global.stockprice[GinsengColor] : 5; break;
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

    // playCatcher(strings: string) {
    //     let self = this;
    //     // self.phaseCatcher.node.active = true;
    //     // let action = cc.sequence(
    //     //     cc.callFunc(function () {
    //     //         let phaseString = self.phaseCatcher.node.getChildByName("PhaseString").getComponent(cc.Label);
    //     //         phaseString.string = strings;

    //     //     }),
    //     //     cc.fadeTo(1.0, 255),
    //     //     cc.fadeTo(2.0, 0),
    //     // );
    //     // self.phaseCatcher.node.runAction(action);
    //     self.playBuyStocker(strings);
    // }

    playCatcher(strings: string, start: number = 580) {
        let self = this;
        self.catchNode.active = true;
        let catchInstance = cc.instantiate(self.catchPrefab);
        catchInstance.opacity = 0;
        catchInstance.position = new cc.Vec2(-500, start);
        let phaseString = catchInstance.getChildByName("PhaseString").getComponent(cc.Label);
        phaseString.string = strings;
        self.catchNode.addChild(catchInstance);
        let action = cc.spawn(
            cc.sequence(cc.fadeIn(3), cc.fadeOut(3)),

            cc.moveTo(6.0, new cc.Vec2(500, start))
        );
        catchInstance.runAction(action);
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
            let putBoatInstance = cc.instantiate(self.putBoatPrefab);
            self.putBoatNode.addChild(putBoatInstance);
        }
    }

    sendPutBoat(except: number, ok: boolean) {
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
            let dragBoatInstance = cc.instantiate(self.dragBoatPrefab);
            self.dragBoatNode.addChild(dragBoatInstance);
            let draggerScript = dragBoatInstance.getChildByName("Dragger").getComponent("Dragger");
            let pics = draggerScript.shipPics;
            draggerScript.phase = message.Ans.Phase;
            draggerScript.dragable = message.Ans.Dragable;

            let dragable = message.Ans.Dragable;
            if (dragable.length < 3) {
                for (let i = 0; i < 3 - dragable.length; i++) {
                    dragable.push(0);
                }
            }
            for (let i = 0; i < dragable.length; i++) {
                let spriteNode = dragBoatInstance.getChildByName('Stock' + (i + 1));
                let sprite = spriteNode.getComponent(cc.Sprite);
                let dragShipType = dragable[i];
                if (dragShipType === 0) {
                    dragBoatInstance.getChildByName('Stock' + (i + 1)).active = false;
                    dragBoatInstance.getChildByName('MinusStock' + (i + 1)).active = false;
                    dragBoatInstance.getChildByName('PlusStock' + (i + 1)).active = false;
                    dragBoatInstance.getChildByName('DragStock' + (i + 1)).active = false;
                } else {
                    sprite.spriteFrame = pics[dragShipType - 1];
                }
            }
        }
    }

    shipMove(ship: [number]) {
        let self = this;

        let shipSocket = 0;
        for (let shipType = 0; shipType < ship.length; shipType++) {
            let step = ship[shipType];
            if (step >= 0 && step <= 19) {
                let shipUnderNode = self.mapSprite.node.getChildByName("Ship" + ColorString[shipType + 1]);
                let position = MapCoor.shipPoints[step][shipSocket];
                let r = MapCoor.shipRs[step][shipSocket];
                let action = cc.spawn(
                    cc.moveTo(1, new cc.Vec2(position[0], position[1])),
                    cc.rotateTo(1, r)
                );

                // action.easing(cc.easeInOut(1.0));
                if (shipUnderNode) {
                    shipUnderNode.runAction(action);
                }
                shipSocket += 1;
                if (shipSocket > 3) {
                    break;
                }
            }
        }
    }

    sendDragBoat(dragable: [number], sum: [number], ok: boolean) {
        let self = this;
        if (ok) {
            let shipDrag = [0, 0, 0, 0];
            for (let i = 0; i < dragable.length; i++) {
                shipDrag[dragable[i] - 1] = sum[i];
            }
            let dragboatmsgobj = JSON.parse(JSON.stringify(dragboatmsg));
            dragboatmsgobj.Req.Username = Global.playerUser;
            dragboatmsgobj.Req.RoomNum = Global.roomNum;
            dragboatmsgobj.Req.Phase = Global.phase;
            dragboatmsgobj.Req.ShipDrag = shipDrag;
            ManilaSocket.send(dragboatmsgobj);
            self.dragBoatNode.active = false;
        } else {
            self.playPopup("三种船加起来应该是9步！");
        }
    }

    onInvestMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else if (message.Ans.RemindOrOperated && Global.playerUser === message.Ans.Username) {
            // self.playCatcher("Your turn to invest", 350);
            Global.canInvest = true;
            self.investPassNode.active = true;
            self.investPassNode.removeAllChildren();
            let investPassInstance = cc.instantiate(self.investPassPrefab);
            self.investPassNode.addChild(investPassInstance);

        } else if (!message.Ans.RemindOrOperated) {
            let invest = message.Ans.Invest;

            // TODO
            // self.playCatcher(message.Ans.Username + " invested " + invest);
        }
    }


    sendInvest(invest: string) {
        let self = this;
        if (Global.canInvest) {
            let investPoint = Global.mapp[invest];
            let shipPoint = invest.slice(1).toLowerCase();
            if (!investPoint) {
                self.playPopup("无效的投资点4");
                return;
            } else if (investPoint.Taken && invest != "none") {
                self.playPopup("投资点已被占据");
                return;
            } else {
                if (Global.money < investPoint.Price) {
                    self.playNotEnoughMoney();
                } else {
                    if (shipPoint == "coffee" || shipPoint == "silk" || shipPoint == "ginseng" || shipPoint == "jade") {
                        let color = StringColor[shipPoint[0].toUpperCase() + shipPoint.slice(1)];
                        console.log(color);
                        let shipType = color - 1;
                        if (Global.ship[shipType] >= OneTickSpot && Global.ship[shipType] <= ThreeTickSpot) {
                            self.playPopup("无效的投资点3");
                            return;
                        }
                    }

                    let investmsgobj = JSON.parse(JSON.stringify(investmsg));
                    investmsgobj.Req.Username = Global.playerUser;
                    investmsgobj.Req.RoomNum = Global.roomNum;
                    investmsgobj.Req.Invest = invest;
                    ManilaSocket.send(investmsgobj);
                    Global.canInvest = false;
                    self.investPassNode.active = false;
                }
            }
        }
    }

    onPirateMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else if (message.Ans.RemindOrOperated && message.Ans.Pirate === Global.playerUser) {

            Global.lastPlunderedShip = message.Ans.LastPlunderedShip
            self.pirateNode.active = true;
            self.pirateNode.removeAllChildren();
            let pirateInstance = cc.instantiate(self.piratePrefab);
            let allShipsNode = pirateInstance.getChildByName("AllShips");
            for (let shipType = 0; shipType < Colors.length; shipType++) {
                let color = Colors[shipType];
                let pirateShipName = "Ship" + ColorString[color];

                let pirateShip = allShipsNode.getChildByName(pirateShipName);
                if (Global.castTime === 2) {
                    let vacant = message.Ans.ShipVacant[shipType];
                    pirateShip.active = vacant > 0 ? true : false
                } else if (Global.castTime === 3) {
                    let vacant = message.Ans.ShipVacant[shipType];
                    pirateShip.active = vacant >= 0 ? true : false
                }
                self.renderShipInvest(allShipsNode, pirateShip, color, "Pirater");
            }
            if (Global.castTime == 3) {
                let passButtonNode = pirateInstance.getChildByName("PassButton");
                passButtonNode.active = false;
            }
            self.pirateNode.addChild(pirateInstance);


        }
    }

    sendPirate(data: string) {
        let self = this;
        let piratemsgobj = JSON.parse(JSON.stringify(piratemsg));
        piratemsgobj.Req.Pirate = Global.playerUser;
        piratemsgobj.Req.RoomNum = Global.roomNum;
        piratemsgobj.Req.Plunder = parseInt(data);
        ManilaSocket.send(piratemsgobj);
        self.pirateNode.active = false;
    }



    onDecideTickFailMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else if (message.Ans.RemindOrOperated && message.Ans.Pirate === Global.playerUser) {
            Global.lastPlunderedShip = message.Ans.ShipPlundered;
            let shipPlundered = message.Ans.ShipPlundered;
            self.decideTickFailNode.active = true;
            self.decideTickFailNode.removeAllChildren();
            let decideTickFailInstance = cc.instantiate(self.decideTickFailPrefab);
            let shipName = ColorString[shipPlundered];
            for (let key in ColorString) {
                let eachShipName = ColorString[key];
                let oneShipNode = decideTickFailInstance.getChildByName("Ship" + eachShipName);
                if (ColorString[key] == shipName) {
                    oneShipNode.active = true;
                    self.renderShipInvest(decideTickFailInstance, oneShipNode, shipPlundered, "DecideTickFailer")

                } else {
                    oneShipNode.active = false;
                }
            }
            self.decideTickFailNode.addChild(decideTickFailInstance);
        }

    }

    sendDecideTickFail(tick: string) {
        let self = this;
        let tickBoolean = tick === "true" ? true : false;
        let decidetickfailmsgobj = JSON.parse(JSON.stringify(decidetickfailmsg));
        decidetickfailmsgobj.Req.Pirate = Global.playerUser;
        decidetickfailmsgobj.Req.RoomNum = Global.roomNum;
        decidetickfailmsgobj.Req.ShipPlundered = Global.lastPlunderedShip;
        decidetickfailmsgobj.Req.Tick = tickBoolean;
        console.log("发送决定靠岸", decidetickfailmsgobj);
        ManilaSocket.send(decidetickfailmsgobj);
        self.decideTickFailNode.active = false;
    }
}
