import EventMng from "../Script/Fundamentals/Manager/EventMng";
import { Global } from "../Script/Fundamentals/ManilaGlobal";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ReadyButton extends cc.Component {
    pressReady() {
        let self = this;
        let ready = Global.readied
        EventMng.emit("Ready", !ready)

    }
}
