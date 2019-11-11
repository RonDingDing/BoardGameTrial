const { ccclass, property } = cc._decorator;
import { ManilaSocket, SocketEvents, loginmsg, LoginMsg, ErrUserNotExit, enterroommsg, EnterRoomMsg, roomdetailmsg, RoomDetailMsg } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import EventMng from "../Fundamentals/Manager/EventMng";
import BasicControl from "./BasicControl"
import i18n = require("LanguageData");


@ccclass
export default class LoginControl extends BasicControl {
    @property(cc.EditBox)
    usernameEditBox: cc.EditBox = null

    @property(cc.EditBox)
    passwordEditBox: cc.EditBox = null

    onLoad() {
        super.onLoad();
        var self = this;
        i18n.init(Global.language);
        EventMng.on(LoginMsg, self.onLoginMsg, self);
        EventMng.on(EnterRoomMsg, self.onEnterRoomMsg, self);
        EventMng.on(RoomDetailMsg, self.onRoomDetailMsg, self);
    }

    onLoginMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
            self.usernameEditBox.string = "";
            self.passwordEditBox.string = "";
        } else {
            let username = message.Ans.Username;
            let gold = message.Ans.Gold;
            let roomnum = message.Ans.RoomNum;
            self.playPopup(i18n.t("User ") + username + i18n.t(" logged in!"));
            Global.playerUser = username;
            Global.playerGold = gold;
            Global.online = true;
            let enterroommsgobj = JSON.parse(JSON.stringify(enterroommsg));
            enterroommsgobj.Req.Username = username;
            enterroommsgobj.Req.RoomNum = roomnum;
            ManilaSocket.send(enterroommsgobj);
        }
    }

    pressLogin() {
        let self = this;
        let loginmsgobj = JSON.parse(JSON.stringify(loginmsg));

        if (!self.usernameEditBox.string) {
            self.playPopup(i18n.t("Invalid username!"));
        } else if (!self.passwordEditBox.string) {
            self.playPopup(i18n.t("Invalid password!"));
        } else if (Global.playerUser) {
            self.playPopup(i18n.t("Logged in! Username is ")  + Global.playerUser);
        } else {
            loginmsgobj.Req.Username = self.usernameEditBox.string;
            loginmsgobj.Req.Password = self.passwordEditBox.string;
            // Global.password = self.passwordEditBox.string;
            ManilaSocket.send(loginmsgobj);
        }
    }

    pressGoToSignUp() {
        cc.director.loadScene("SignUpMenu");
    }

    onEnterRoomMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        }
        else {
            if (message.Ans.RoomNum !== 0) {
                self.scheduleOnce(() => {
                    cc.director.loadScene("ManilaRoom");
                }, 2);

            } else {
                // self.scheduleOnce(() => {
                cc.director.loadScene("SelectRoom");
                // }, 2);
            }
        }
    }

    onRoomDetailMsg(message) {
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else {
            self.messageToGlobal(message);
        }
    }
}