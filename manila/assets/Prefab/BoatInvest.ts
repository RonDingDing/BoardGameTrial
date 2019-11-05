import EventMng from "../Script/Fundamentals/Manager/EventMng";

const {ccclass, property} = cc._decorator;

@ccclass
export default class BoatInvest extends cc.Component {
    @property([cc.SpriteFrame])
    pawnPics : [cc.SpriteFrame] = [new cc.SpriteFrame]
    
    investOnboat(event, customEventData) {
        EventMng.emit("InvestOnboat", customEventData);
    }
}
