import EventMng from "../Script/Fundamentals/Manager/EventMng";
import { Global } from "../Script/Fundamentals/ManilaGlobal";

const { ccclass, property } = cc._decorator;

@ccclass
export default class Pawner extends cc.Component {
    @property([cc.SpriteFrame])
    pawnPics: [cc.SpriteFrame] = [new cc.SpriteFrame]

    investOnshore() {
        let self = this;
        let data = self.node.parent.name;
        if (data == "2pirate" && Global.mapp["1pirate"].Taken === ""){
            data = "1pirate"
        }
        EventMng.emit("InvestOnshore", data);
    }
}
