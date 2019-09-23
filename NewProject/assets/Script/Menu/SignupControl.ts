const { ccclass, property } = cc._decorator;
import { ManilaSocket, SocketEvents, SignUpMsg, signupmsg, ErrUserExit } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import EventMng from "../Fundamentals/Manager/EventMng"
import BasicControl from "./BasicControl"


@ccclass
export default class SignupControl extends BasicControl {
    @property(cc.EditBox)
    usernameEditBox: cc.EditBox = null

    @property(cc.EditBox)
    passwordEditBox: cc.EditBox = null

    @property(cc.EditBox)
    emailEditBox: cc.EditBox = null

    @property(cc.EditBox)
    mobileEditBox: cc.EditBox = null


    onLoad() {
        super.onLoad();
        var self = this;
        EventMng.on(SignUpMsg, self.onSignUpMsg, self);
    }


    onSignUpMsg(message) {
        let self = this;
        if (message.Error == ErrUserExit) {
            self.playPopup("用户名已存在！");
        } else {
            let username = message.Ans.Username;
            self.playPopup("用户名 " + username + " 创建成功！\n跳转登录页…");
            self.scheduleOnce(function () {
                cc.director.loadScene("LoginMenu");
            }, 1);
        }
    }
    pressSignUp() {
        let self = this;
        let signupmsgobj = JSON.parse(JSON.stringify(signupmsg));
        if (self.usernameEditBox.string && self.passwordEditBox.string && self.emailEditBox.string && self.mobileEditBox.string) {
            signupmsgobj.Req.Username = self.usernameEditBox.string;
            signupmsgobj.Req.Password = self.passwordEditBox.string;
            signupmsgobj.Req.Email = self.emailEditBox.string;
            signupmsgobj.Req.Mobile = self.mobileEditBox.string;
            ManilaSocket.send(signupmsgobj);
        } else {
            self.playPopup("请填写所有信息！");
        }
    }

    pressGotoLogin() {
        cc.director.loadScene("LoginMenu");
    }


   
}