import { ManilaSocket, SocketEvents } from "./Global"
import EventMng from "./Manager/EventMng";

const { ccclass, property } = cc._decorator;
const Bail = "500";
const HeartBeat = "0001"


@ccclass
export default class GameControl extends cc.Component {

    onLoad() {
        EventMng.on(SocketEvents.SOCKET_OPEN, this.sendHeartBeat, this);
        EventMng.on(SocketEvents.SOCKET_CLOSE, function () {
            console.log('Socket close');
        }, this);
        EventMng.on(Bail, function (data) {
            console.log("L:", data);
        }, this);

    }


    start() {

    }

    sendHeartBeat() {
        var str = { "Code": Bail, "Number": 1 };
        console.log("Heartbeat: ", str)
        ManilaSocket.send(str);
    }

    // update (dt) {}
}
