import { ManilaSocket, SocketEvents, LoginMsg, Errors } from "./Global"
import EventMng from "./Manager/EventMng";

const { ccclass, property } = cc._decorator;


@ccclass
export default class GameControl extends cc.Component {
 
    onLoad() {
        var self = this;
    
        EventMng.on(SocketEvents.SOCKET_OPEN, self.sendTest, self);
        EventMng.on(SocketEvents.SOCKET_CLOSE, self.onSocketClose, self);
        EventMng.on(Errors, self.onError, self);
 
    }


    start() { }

    onError(data) {
        console.log("Error:", data);
    }

    onSocketOpen() { }

    onSocketClose() { }

    sendTest() {
        var str = { "Code": "001", "Number": 1 };
        console.log("Heartbeat: ", str)
        ManilaSocket.send(str);
    }

    // update (dt) {}
}
