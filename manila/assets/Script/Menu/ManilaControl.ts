import { SilkColor, JadeColor, CoffeeColor, GinsengColor, ManilaSocket, RoomDetailMsg, readymsg, GameStartMsg, BidMsg, bidmsg, HandMsg, BuyStockMsg, buystockmsg, ChangePhaseMsg, PutBoatMsg, putboatmsg, DragBoatMsg, roomdetailmsg, PhaseDragBoat, dragboatmsg, InvestMsg, investmsg } from "../Fundamentals/Imports"
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
    nameScript: cc.Prefab = null

    @property(cc.Sprite)
    mapSprite: cc.Sprite = null

    @property(cc.Node)
    readyNode: cc.Node = null

    @property(cc.Prefab)
    readyPrefab: cc.Prefab = null

    @property(cc.Node)
    putNode: cc.Node = null


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

    @property(cc.Prefab)
    pawnPrefab: cc.Prefab = null

    dic: Object = { [CoffeeColor]: "Coffee", [SilkColor]: "Silk", [GinsengColor]: "Ginseng", [JadeColor]: "Jade" };

    onLoad() {
        super.onLoad();
        let self = this;

        self.j();

        self.renderGlobal(0);
        EventMng.on(RoomDetailMsg, self.onRoomDetailMsg, self);
        EventMng.on(GameStartMsg, self.onGameStartMsg, self);
        EventMng.on(BidMsg, self.onBidMsg, self);
        EventMng.on(HandMsg, self.onHandMsg, self);
        EventMng.on(BuyStockMsg, self.onBuyStockMsg, self);
        EventMng.on(ChangePhaseMsg, self.onChangePhaseMsg, self);
        EventMng.on(PutBoatMsg, self.onPutBoatMsg, self);
        EventMng.on(DragBoatMsg, self.onDragBoatMsg, self);
        EventMng.on(InvestMsg, self.onInvestMsg, self);
        EventMng.on("Ready", self.sendReadyOrNot, self);
        EventMng.on("Bid", self.sendBid, self);
        EventMng.on("BuyStock", self.sendBuyStock, self);
        EventMng.on("PutBoat", self.sendPutBoat, self);
        EventMng.on("DragBoat", self.sendDragBoat, self);
        EventMng.on("InvestOnshore", self.sendInvest, self);
        EventMng.on("InvestOnboat", self.sendInvest, self);
    }

    j() {
        // let self = this;
        // Global.started = true;
        // Global.stockprice = [0, 20, 5, 30];
        // Global.ship = [1, 1, -1, 1];

        // Global.mapp = {

        //     "1tick": { "Name": "1tick", "Taken": "", "Price": 4, "Award": 6, "Onboard": true },
        //     "2tick": { "Name": "2tick", "Taken": "", "Price": 3, "Award": 8, "Onboard": true },
        //     "3tick": { "Name": "3tick", "Taken": "", "Price": 2, "Award": 15, "Onboard": true },

        //     "1fail": { "Name": "1fail", "Taken": "", "Price": 4, "Award": 6, "Onboard": true },
        //     "2fail": { "Name": "2fail", "Taken": "", "Price": 3, "Award": 8, "Onboard": true },
        //     "3fail": { "Name": "3fail", "Taken": "", "Price": 2, "Award": 15, "Onboard": true },

        //     "1pirate": { "Name": "1pirate", "Taken": "", "Price": 5, "Award": 0, "Onboard": true },
        //     "2pirate": { "Name": "2pirate", "Taken": "", "Price": 5, "Award": 0, "Onboard": true },

        //     "1drag": { "Name": "1drag", "Taken": "", "Price": 2, "Award": 0, "Onboard": true },
        //     "2drag": { "Name": "2drag", "Taken": "", "Price": 5, "Award": 0, "Onboard": true },

        //     "repair": { "Name": "repair", "Taken": "", "Price": 0, "Award": 10, "Onboard": true },

        //     "1coffee": { "Name": "1coffee", "Taken": "a", "Price": 2, "Award": 0, "Onboard": false },
        //     "2coffee": { "Name": "2coffee", "Taken": "a", "Price": 3, "Award": 0, "Onboard": false },
        //     "3coffee": { "Name": "3coffee", "Taken": "a", "Price": 4, "Award": 0, "Onboard": false },

        //     "1silk": { "Name": "1silk", "Taken": "a", "Price": 3, "Award": 0, "Onboard": false },
        //     "2silk": { "Name": "2silk", "Taken": "b", "Price": 4, "Award": 0, "Onboard": false },
        //     "3silk": { "Name": "3silk", "Taken": "c", "Price": 5, "Award": 0, "Onboard": false },

        //     "1jade": { "Name": "1jade", "Taken": "a", "Price": 3, "Award": 0, "Onboard": false },
        //     "2jade": { "Name": "2jade", "Taken": "b", "Price": 4, "Award": 0, "Onboard": false },
        //     "3jade": { "Name": "3jade", "Taken": "c", "Price": 5, "Award": 0, "Onboard": false },
        //     "4jade": { "Name": "4jade", "Taken": "", "Price": 5, "Award": 0, "Onboard": false },

        //     "1ginseng": { "Name": "1ginseng", "Taken": "a", "Price": 1, "Award": 0, "Onboard": false },
        //     "2ginseng": { "Name": "2ginseng", "Taken": "b", "Price": 2, "Award": 0, "Onboard": false },
        //     "3ginseng": { "Name": "3ginseng", "Taken": "c", "Price": 3, "Award": 0, "Onboard": false },
        // };

        // Global.allPlayers = {
        //     "a": { "Money": 12, "Name": "a", "Online": true, "Stock": 3, "Seat": 1, "Ready": false, "Canbid": true }, "b": { "Money": 30, "Name": "b", "Online": true, "Stock": 2, "Seat": 2, "Ready": false, "Canbid": false }, "c": { "Money": 30, "Name": "c", "Online": true, "Stock": 2, "Seat": 3, "Ready": false, "Canbid": false }
        // };
    }

    renderGlobal(time: number) {
        let self = this;
        if (Global.started) {
            self.mapSprite.node.active = true;
            self.readyNode.active = false;
            self.scheduleOnce(self.renderMap, time);
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
            let readyButton = cc.instantiate(self.readyPrefab);
            self.readyNode.removeAllChildren();
            self.readyNode.addChild(readyButton);
            let readyScript = readyButton.getChildByName("ReadyButtonC").getComponent("ReadyButton");
            readyButton.getComponent(cc.Sprite).spriteFrame = Global.readied ? readyScript.readyPics[1] : readyScript.readyPics[0];

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
                let nameScripter = scriptPlayer.getChildByName("NameScripter").getComponent("NameScripter");
                let pawnChoices = nameScripter.pawnPics;
                let readyChoices = nameScripter.readyPics;


                let tokenSprite = tokenSpriteNode.getComponent(cc.Sprite);
                tokenSprite.spriteFrame = pawnChoices[player.Seat - 1];
                let name = scriptPlayer.getChildByName("Name").getComponent(cc.Label);
                name.string = username;
                let money = scriptPlayer.getChildByName("Money").getComponent(cc.Label);
                money.string = player.Money;
                let stock = scriptPlayer.getChildByName("Stock").getComponent(cc.Label);
                stock.string = player.Stock;
                let stateSpriteNode = scriptPlayer.getChildByName("State");
                if (Global.started == false) {
                    stateSpriteNode.active = player.Ready ? true : false;
                    stateSpriteNode.getComponent(cc.Sprite).spriteFrame = readyChoices[0];
                } else {
                    stateSpriteNode.active = player.Name === Global.currentPlayer ? true : false;
                    stateSpriteNode.getComponent(cc.Sprite).spriteFrame = readyChoices[2];
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

                // 展示船上投资
                let shipName = self.dic[shipType + 1].toLowerCase();
                for (let k = 1; k < 5; k++) {
                    let investPointKey = ("" + k + shipName);
                    if (Global.mapp.hasOwnProperty(investPointKey)) {
                        let taken = Global.mapp[investPointKey].Taken;
                        if (taken !== "") {
                            let seat = Global.allPlayers[taken].Seat;
                            let pawnSprite = shipUnderNode.getChildByName(investPointKey).getComponent(cc.Sprite);
                            let pawnChoices = shipUnderNode.getChildByName("BoatInvest").getComponent("BoatInvest").pawnPics;
                            pawnSprite.spriteFrame = pawnChoices[seat - 1];
                        }
                    }
                }
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
                let pawn = cc.instantiate(self.pawnPrefab);
                pawn.name = pointName;
                pawn.position = new cc.Vec2(pawnPosition[0], pawnPosition[1]);
                mapNode.addChild(pawn);
                if (Global.mapp[pointName].Taken !== "") {
                    let taken = Global.mapp[pointName].Taken;
                    let seat = Global.allPlayers[taken].Seat;
                    let pawnSprite = pawn.getChildByName("Pawn").getComponent(cc.Sprite);
                    let pawnPicChoice = pawn.getChildByName("Pawner").getComponent("Pawner").pawnPics;
                    pawnSprite.spriteFrame = pawnPicChoice[seat - 1];

                }
            }
        }

    }

    setShipPosition(shipUnderNode: cc.Node, shipsocket: number, step: number) {
        // let x = 0;
        // let y = 0;
        let point = MapCoor.shipPointOut;
        let r = 0;
        if (step < 0) {
            point = MapCoor.shipPointOut;
        } else if (step <= 19) {
            // x = MapCoor.shipXs[step][shipsocket];
            // y = MapCoor.shipYs[step][shipsocket];
            point = MapCoor.shipPoints[step][shipsocket];
            r = MapCoor.shipRs[step][shipsocket];
        }
        // shipUnderNode.x = x;
        // shipUnderNode.y = y;
        shipUnderNode.position = new cc.Vec2(point[0], point[1]);
        shipUnderNode.angle = -r;
    }

    onRoomDetailMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else {
            self.messageToGlobal(message);
            self.renderGlobal(message.Ans.RenderAfter);
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
    sendBuyStock(data: string) {
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

    playCatcher(strings: string) {
        let self = this;
        self.phaseCatcher.node.active = true;
        let action = cc.sequence(
            cc.callFunc(function () {
                let phaseString = self.phaseCatcher.node.getChildByName("PhaseString").getComponent(cc.Label);
                phaseString.string = strings;

            }),
            cc.fadeTo(1.0, 255),
            cc.fadeTo(2.0, 0),
        );
        self.phaseCatcher.node.runAction(action);
    }

    playBuyStocker(strings: string) {
        let self = this;
        self.buyStocker.node.active = true;
        let action = cc.sequence(
            cc.callFunc(function () {
                let phaseString = self.buyStocker.node.getChildByName("PhaseString").getComponent(cc.Label);
                phaseString.string = strings;

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
            let dragBoatUnderNode = cc.instantiate(self.dragBoatPrefab);
            self.dragBoatNode.addChild(dragBoatUnderNode);
            let draggerScript = dragBoatUnderNode.getChildByName("Dragger").getComponent("Dragger");
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
        } else if (!message.Ans.RemindOrOperated && message.Ans.RoomNum === Global.roomNum) {
            let ship = message.Ans.Ship;
            self.shipMove(ship);
        }
    }

    shipMove(ship: [number]) {
        let self = this;

        let shipSocket = 0;
        for (let shipType = 0; shipType < ship.length; shipType++) {
            let step = ship[shipType];
            if (step >= 0 && step <= 19) {
                let shipUnderNode = self.mapSprite.node.getChildByName("Ship" + self.dic[shipType + 1]);
                // let x = MapCoor.shipXs[step][shipSocket];
                // let y = MapCoor.shipYs[step][shipSocket];
                let position = MapCoor.shipPoints[step][shipSocket];
                let r = MapCoor.shipRs[step][shipSocket];
                let action = cc.spawn(
                    // cc.moveTo(1, new cc.Vec2(x, y)),
                    cc.moveTo(1, new cc.Vec2(position[0], position[1])),
                    cc.rotateTo(1, r)
                );

                // action.easing(cc.easeInOut(1.0));
                shipUnderNode.runAction(action);
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
            self.playPopup("请输入合适的步数！");
        }
    }

    onInvestMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else if (message.Ans.RemindOrOperated && Global.playerUser === message.Ans.Username) {
            console.log(1, message);
            Global.canInvest = true;
        } else if (!message.Ans.RemindOrOperated){
            console.log(2, message);
        }
    }


    sendInvest(invest: string) {
        let self = this;
        if (Global.canInvest) {
            let investPoint = Global.mapp[invest];
            if (!investPoint.Taken) {
                if (Global.money < investPoint.Price) {
                    self.playNotEnoughMoney();
                } else {
                    let investmsgobj = JSON.parse(JSON.stringify(investmsg));
                    investmsgobj.Req.Username = Global.playerUser;
                    investmsgobj.Req.RoomNum = Global.roomNum;
                    investmsgobj.Req.Invest = invest;
                    ManilaSocket.send(investmsgobj);
                    Global.canInvest = false;
                }
            }
        }
    }


}
