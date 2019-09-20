import { ManilaSocket, SocketEvents, LoginMsg, SignUpMsg, EnterRoomMsg, Errors, loginmsg, signupmsg, enterroommsg, ErrUserExit, ErrUserNotExit } from "./Imports"
import EventMng from "./Manager/EventMng";
import { Global } from "./ManilaGlobal"
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


    @property(cc.EditBox)
    roomNumEditBox: cc.EditBox = null

    @property(cc.Node)
    popPup: cc.Node = null

    @property(cc.Label)
    popPupString: cc.Label = null




    onLoad() {
        let self = this;
        EventMng.on(SocketEvents.SOCKET_OPEN, self.onSocketOpen, self);
        EventMng.on(SocketEvents.SOCKET_CLOSE, self.onSocketClose, self);
        EventMng.on(Errors, self.onError, self);
        EventMng.on(SignUpMsg, self.onSignUpMsg, self);
        EventMng.on(LoginMsg, self.onLoginMsg, self);
        EventMng.on(EnterRoomMsg, self.onEnterRoomMsg, self);

    }


    start() { }

    onError(data) {
        console.log("Error:", data);
    }

    onSocketOpen() {
        Global.online = true;
        // if (Global.password && Global.playerUser) {
        //     let self = this;
        //     console.log("Password: ", Global.password);
        //     let loginmsgobj = JSON.parse(JSON.stringify(loginmsg));
        //     loginmsgobj.Req.Username = Global.playerUser
        //     loginmsgobj.Req.Password = Global.password;
        //     ManilaSocket.send(loginmsgobj);
        //     self.scheduleOnce(function () {
        //         cc.director.loadScene("ManilaRoom");
        //     }, 2);
        // }
    }

    onSocketClose() {
        cc.director.loadScene("StartMenu");
        Global.playerUser = ""
        Global.online = false;
    }

    onLoginMsg(message) {
        let self = this;
        let username = message.Ans.Username;
        let gold = message.Ans.Gold;
        let roomnum = message.Ans.RoomNum;
        if (message.Error == ErrUserNotExit) {
            self.playPopUp("用户名或密码错误！");
            self.usernameEditBox.string = "";
            self.passwordEditBox.string = "";
        } else {
            self.playPopUp("用户" + username + "登录成功！");
            Global.playerUser = username;
            Global.playerGold = gold;
            Global.online = true;
            let enterroommsgobj = JSON.parse(JSON.stringify(enterroommsg));
            enterroommsgobj.Req.Username = username;
            enterroommsgobj.Req.RoomNum = roomnum;
            ManilaSocket.send(enterroommsgobj)
            if (roomnum != 0) {        
                cc.director.loadScene("ManilaRoom");
            } else {
                cc.director.loadScene("SelectRoom");
            }
        }
    }



    onSignUpMsg(message) {
        let self = this;
        if (message.Error == ErrUserExit) {
            self.playPopUp("用户名已存在！");
        } else {
            let username = message.Ans.Username;
            self.playPopUp("用户名 " + username + " 创建成功！\n跳转登录页…");
            self.scheduleOnce(function () {
                cc.director.loadScene("LoginMenu");
            }, 1);
        }
    }

    onEnterRoomMsg(message) {
        console.log(message)
    }

    pressStart() {
        let self = this;
        if (ManilaSocket.isSocketOpened()) {
            cc.director.loadScene("LoginMenu");
        } else {
            self.playPopUp("未连接网络！")
        }
    }

    pressGoToSignUp() {
        cc.director.loadScene("SignUpMenu");
    }

    pressLogin() {
        let self = this;
        let loginmsgobj = JSON.parse(JSON.stringify(loginmsg));

        if (!self.usernameEditBox.string) {
            self.playPopUp("用户名不能为空");
        } else if (!self.passwordEditBox.string) {
            self.playPopUp("密码不能为空");
        } else if (Global.playerUser) {
            self.playPopUp("已经登录，用户名为" + Global.playerUser);
        } else {
            loginmsgobj.Req.Username = self.usernameEditBox.string;
            loginmsgobj.Req.Password = self.passwordEditBox.string;
            // Global.password = self.passwordEditBox.string;
            ManilaSocket.send(loginmsgobj);
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
            self.playPopUp("请填写所有信息！");
        }
    }

    pressEnterRoom() {
        let self = this;
        if (Global.playerUser === "") {
            ManilaSocket.closeConnect();
            return;
        }
        let roomnum = parseInt(self.roomNumEditBox.string);
        console.log(roomnum);
        if (isNaN(roomnum)) {
            self.playPopUp("请输入大于0的整数！");
            self.roomNumEditBox.string = "";
            return;
        }

        let enterroommsgobj = JSON.parse(JSON.stringify(enterroommsg));
        enterroommsgobj.Req.Username = Global.playerUser;
        enterroommsgobj.Req.RoomNum = roomnum;
        console.log(enterroommsg);
        ManilaSocket.send(enterroommsgobj)

        if (roomnum != 0) {
            self.scheduleOnce(function () {
                cc.director.loadScene("ManilaRoom");
            }, 1);
        }

    }
    pressExit() {
        let self = this;
        self.popPup.active = false;
    }

    playPopUp(content: string) {
        let self = this;
        self.popPup.active = true;
        let seq = cc.sequence(
            cc.scaleTo(0.2, 1.05, 1.05),
            cc.scaleTo(0.2, 1, 1),
        )
        self.popPup.runAction(seq);

        self.popPupString.string = content;
    }
}
