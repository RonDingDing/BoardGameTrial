import EventMng from "../Script/Fundamentals/Manager/EventMng";
import { Global } from "../Script/Fundamentals/ManilaGlobal";
import {ColorString} from  "../Script/Fundamentals/Imports"

const { ccclass, property } = cc._decorator;

@ccclass
export default class BoatInvest extends cc.Component {
    @property([cc.SpriteFrame])
    pawnPics: [cc.SpriteFrame] = [new cc.SpriteFrame]

    investOnboat(event, customEventData) {
        let data = "";
        for (let j = 1; j < 5; j++) {
            let key = "" + j + ColorString[parseInt(customEventData)].toLowerCase();
            
            if (Global.mapp.hasOwnProperty(key) && Global.mapp[key].Taken === "") {
                data = key;
                break;
            }
        }
        if (data !== "") {
            EventMng.emit("InvestOnboat", data);
        }
    }
}
