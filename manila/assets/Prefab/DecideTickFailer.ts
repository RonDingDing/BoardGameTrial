import EventMng from "../Script/Fundamentals/Manager/EventMng";

const { ccclass, property } = cc._decorator;

@ccclass
export default class DecideTickFailer extends cc.Component {
    @property([cc.SpriteFrame])
    pawnPics: [cc.SpriteFrame] = [new cc.SpriteFrame()]

    pressDecideTickFail(event, data) {
        EventMng.emit("DecideTickFail", data);
    }
}
