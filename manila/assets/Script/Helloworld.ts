import { ManilaSocket, SocketEvents } from "./Global"
import EventMng from "./Manager/EventMng";

const { ccclass, property } = cc._decorator;

@ccclass
export default class GameControl extends cc.Component {

    @property(cc.Label)
    label: cc.Label = null;

    @property
    text: string = 'hello';

    // LIFE-CYCLE CALLBACKS:

    onLoad() {
        EventMng.on(SocketEvents.SOCKET_OPEN, this.sendM, this);
        EventMng.on(SocketEvents.SOCKET_CLOSE, function () {
            console.log('Socket close');
        }, this);
        EventMng.on("Good", function (data) {
            console.log("L:", data);
        }, this);

    }


    start() {

    }

    sendM() {
        var str =  { "messageName": "Good", "number": 1 };

        ManilaSocket.send(str);
    }

    // update (dt) {}
}
