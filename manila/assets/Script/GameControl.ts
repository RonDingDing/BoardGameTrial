import { ManilaSocket, SocketEvents, LoginMsg, SignUpMsg, Errors, loginmsg, signupmsg, ErrNoHandler, ErrUserExit, ErrUserNotExit} from "./Global"
import EventMng from "./Manager/EventMng";
const { ccclass, property } = cc._decorator;

@ccclass
export default class GameControl extends cc.Component {
    @property(cc.EditBox)
    usernameEditBox: cc.EditBox = null

    @property(cc.EditBox)
    passwordEditBox: cc.EditBox = null

    @property(cc.EditBox)
    mobileEditBox: cc.EditBox = null

    @property(cc.EditBox)
    emailEditBox: cc.EditBox = null

    @property(cc.Node)
    popPup: cc.Node = null


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

    onLoginMsg(message) {
        var self = this;
        if (message.Error == ErrUserNotExit) {
            self.playPopUp("用户名或密码错误！");
        } else {
            self.playPopUp("用户" + message.Ans.Username + "登录成功！");
        }
    }

    onSignUpMsg(message) {
        var self = this;
        if (message.Error == ErrUserExit) {
            self.playPopUp("用户名已存在！");
        } else {
            var username = message.Ans.Username;
            self.playPopUp("用户名 " + username + " 创建成功！\n跳转登录页…");
            self.scheduleOnce(function() {               
                cc.director.loadScene("LoginMenu");
            }, 2);
        }
    }

    pressStart() {
        cc.director.loadScene("LoginMenu");
    }

    pressGoToSignUp() {
        cc.director.loadScene("SignUpMenu");
    }

    pressLogin() {
        var self = this;
        var loginmsgobj = JSON.parse(JSON.stringify(loginmsg));

        if (!self.usernameEditBox.string) {
            self.playPopUp("用户名不能为空");
        } else if (!self.passwordEditBox.string) {
            self.playPopUp("密码不能为空");
        } else {
            loginmsgobj.Req.Username = self.usernameEditBox.string;
            loginmsgobj.Req.Password = self.passwordEditBox.string;
            ManilaSocket.send(loginmsgobj);
        }

    }

    pressSignUp() {
        var self = this;
        var signupmsgobj = JSON.parse(JSON.stringify(signupmsg));
        if (self.usernameEditBox.string && self.passwordEditBox.string && self.emailEditBox.string && self.mobileEditBox.string) {
            signupmsgobj.Req.Username = self.usernameEditBox.string;
            signupmsgobj.Req.Password = self.passwordEditBox.string;
            signupmsgobj.Req.Email = self.emailEditBox.string;
            signupmsgobj.Req.Mobile = self.mobileEditBox.string;
            ManilaSocket.send(signupmsgobj);
        } else {
            self.playPopUp("请填写所有信息！");

        }
    }
    pressExit() {
        var self = this;
        self.popPup.active = false;
    }

    playPopUp(content: string) {
        var self = this;
        self.popPup.active = true;
        var seq = cc.sequence(
            cc.scaleTo(0.2, 1.05, 1.05),
            cc.scaleTo(0.2, 1, 1),
        )
        self.popPup.runAction(seq);
        let labelNode = self.popPup.getChildByName("AlertString");
        let label = labelNode.getComponent(cc.Label);
        label.string = content;
    }
}
