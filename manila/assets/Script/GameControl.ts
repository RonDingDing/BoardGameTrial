import { ManilaSocket, SocketEvents, LoginMsg, SignUpMsg, Errors } from "./Global"
import EventMng from "./Manager/EventMng";

const { ccclass, property } = cc._decorator;


@ccclass
export default class GameControl extends cc.Component {

    onLoad() {
        var self = this;

        EventMng.on(SocketEvents.SOCKET_OPEN, self.onSocketOpen, self);
        EventMng.on(SocketEvents.SOCKET_CLOSE, self.onSocketClose, self);
        EventMng.on(Errors, self.onError, self);
        EventMng.on(LoginMsg, self.onLoginMsg, self);
        EventMng.on(SignUpMsg, self.onSignUpMsg, self);

    }


    start() { }

    onError(data) {
        console.log("Error:", data);
    }

    onSocketOpen() { }

    onSocketClose() { }

    onLoginMsg(loginbin) {
        console.log(loginbin);
    }

    onSignUpMsg(loginbin) {
        console.log(loginbin);
    }
    // sendTest() {
    //     var str = { "Code": "001", "Number": 1 };
    //     console.log("Heartbeat: ", str)
    //     ManilaSocket.send(str);
    // }

    // update (dt) {}
}
