const { ccclass, property } = cc._decorator;
import { ManilaSocket, SocketEvents, SignUpMsg, signupmsg, ErrUserExit } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import EventMng from "../Fundamentals/Manager/EventMng"
import BasicControl from "./BasicControl"
import i18n = require("LanguageData");


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
        i18n.init(Global.language);
        EventMng.on(SignUpMsg, self.onSignUpMsg, self);
    }


    onSignUpMsg(message) {
        let self = this;
        if (message.Error == ErrUserExit) {
            self.playPopup(i18n.t("User already exists!"));
        } else {
            let username = message.Ans.Username;
            self.playPopup(i18n.t("User ") + username + " created!\nSwitch to login page...");
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
            self.playPopup(i18n.t("Please fill in all information!"));
        }
    }

    pressGotoLogin() {
        cc.director.loadScene("LoginMenu");
    }



}