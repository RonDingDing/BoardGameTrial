import { ManilaSocket, SocketEvents, SignUpMsg, signupmsg, enterroommsg, EnterRoomMsg, ErrUserExit } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import EventMng from "../Fundamentals/Manager/EventMng";
import BasicControl from "./BasicControl"
const { ccclass, property } = cc._decorator;

@ccclass
export default class ManilaControl extends BasicControl {

    @property([cc.SpriteFrame])
    sprites: [cc.SpriteFrame] = []

    @property(cc.Prefab)
    nameScript: cc.Prefab = null

    onLoad() {
        super.onLoad();
        let self = this;
        self.j();
        self.renderGlobal();

        EventMng.on(EnterRoomMsg, self.renderGlobal, self);

    }

    j() {
        Global.playerUser = "apple";
        Global.allPlayerName = ["apple", "boy", "cat", "dog", "eat"];
        Global.allPlayers = {
            "apple": { "Name": "apple", "Money": 0, "Stock": 0, "Online": true, "Seat": 1 },
            "boy": { "Name": "boy", "Money": 0, "Stock": 1, "Online": true, "Seat": 2 },
            "cat": { "Name": "cat", "Money": 100, "Stock": 2, "Online": true, "Seat": 3 },
            "dog": { "Name": "dog", "Money": 200, "Stock": 3, "Online": true, "Seat": 4 },
            "eat": { "Name": "eat", "Money": 3, "Stock": 4, "Online": true, "Seat": 5 },
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
        let allPlayers = Global.allPlayerName;
        let myName = Global.playerUser;
        let len = allPlayers.length;
        let myIndex = allPlayers.indexOf(myName);
        if (myIndex !== -1) {
            let ordered = allPlayers.splice(myIndex, len).concat(allPlayers.splice(0, len));
            console.log(ordered);

            let ystart = 500 ;
            let xstart = 270;
            let ymargin = -200;
            for (let i = 0; i < ordered.length; i++) {
                let username = ordered[i];
                let player = Global.allPlayers[username];
                console.log(player);
                let scriptPlayer = cc.instantiate(self.nameScript);
                let sprite = scriptPlayer.getChildByName("Token").getComponent(cc.Sprite);
                sprite.spriteFrame = self.sprites[i];
                let name = scriptPlayer.getChildByName("Name").getComponent(cc.Label);
                name.string = username;
                let money = scriptPlayer.getChildByName("Money").getComponent(cc.Label);
                money.string = player.Money;
                let stock = scriptPlayer.getChildByName("Stock").getComponent(cc.Label);
                stock.string = player.Stock;
                scriptPlayer.y = ystart;
                scriptPlayer.x = xstart;
                ystart += ymargin;
                self.canvas.node.addChild(scriptPlayer);

            }
        }


    }


}
