import EventMng from "../Script/Fundamentals/Manager/EventMng";

const {ccclass, property} = cc._decorator;

@ccclass
export default class BoatInvest extends cc.Component {

    pressInvest(event, customEventData) {
        EventMng.emit("Invest", customEventData);
    }
}
