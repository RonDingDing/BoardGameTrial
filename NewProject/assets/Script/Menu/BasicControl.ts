const { ccclass, property } = cc._decorator;
import EventMng from "../Fundamentals/Manager/EventMng";
import { SocketEvents, } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"

@ccclass
export default class BasicControl extends cc.Component {

    @property(cc.Prefab)
    popUp: cc.Prefab = null;

    @property(cc.Canvas)
    canvas: cc.Canvas = null;
 

    onLoad() {
        var self = this;
        EventMng.on(SocketEvents.SOCKET_OPEN, self.onSocketOpen, self);
        EventMng.on(SocketEvents.SOCKET_CLOSE, self.onSocketClose, self);         
    }

    playPopup(content: string) {
        let self = this;
        let popUp = cc.instantiate(self.popUp);
        self.canvas.node.addChild(popUp);

        popUp.active = true;
        let seq = cc.sequence(
            cc.scaleTo(0.2, 1.05, 1.05),
            cc.scaleTo(0.2, 1, 1),
        )
        popUp.runAction(seq);
        let popUpNode: cc.Node = popUp.getChildByName("AlertString");
        let popUpString: cc.Label = popUpNode.getComponent(cc.Label);
        popUpString.string = content;

    }
    onSocketOpen() {
        Global.online = true;
    }

    onSocketClose() {
        cc.director.loadScene("StartMenu");
        Global.playerUser = ""
        Global.online = false;
    }
}