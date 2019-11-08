import EventMng from "../Script/Fundamentals/Manager/EventMng";


const { ccclass, property } = cc._decorator;

@ccclass
export default class NewClass extends cc.Component {
    @property([cc.SpriteFrame])
    pawnPics: [cc.SpriteFrame] = [new cc.SpriteFrame()]
    
    pressPlunder(event, data) {
        EventMng.emit("Pirate", data);
    }
}
