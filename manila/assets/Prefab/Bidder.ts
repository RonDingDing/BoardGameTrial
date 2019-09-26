import { Global } from "../Script/Fundamentals/ManilaGlobal";
import EventMng from "../Script/Fundamentals/Manager/EventMng";

const { ccclass, property } = cc._decorator;

@ccclass
export default class Bidder extends cc.Component {
    onPressBid(event, customEventData) {
        EventMng.emit("Bid", customEventData);
    }
}
