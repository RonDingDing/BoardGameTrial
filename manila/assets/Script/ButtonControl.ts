import { ManilaSocket, SocketEvents, LoginMsg } from "./Global"
const { ccclass, property } = cc._decorator;

@ccclass
export default class NewClass extends cc.Component {
    @property(cc.EditBox)
    usernameEditBox: cc.EditBox = null

    @property(cc.EditBox)
    passwordEditBox: cc.EditBox = null

    


    pressStart() {
        cc.director.loadScene("LoginMenu");
    }

    pressLogin() {
        var loginmsg = { "Username": this.usernameEditBox.string, "Password": this.passwordEditBox.string, "Code": LoginMsg };
        ManilaSocket.send(loginmsg);

    }
}
