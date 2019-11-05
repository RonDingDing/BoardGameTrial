import EventMng from "../Script/Fundamentals/Manager/EventMng";

const { ccclass, property } = cc._decorator;

@ccclass
export default class Pawner extends cc.Component {
    @property([cc.SpriteFrame])
    pawnPics: [cc.SpriteFrame] = [new cc.SpriteFrame]

    investOnshore() {
        let self = this;
        let data = self.node.parent.name;
        EventMng.emit("InvestOnshore", data);
    }
}
