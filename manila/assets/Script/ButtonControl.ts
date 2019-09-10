import { ManilaSocket, loginmsg, signupmsg } from "./Global"
const { ccclass, property } = cc._decorator;

@ccclass
export default class NewClass extends cc.Component {
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


    pressStart() {
        cc.director.loadScene("LoginMenu");
    }

    pressLogin() {
        var self = this;
        var loginmsgobj = JSON.parse(JSON.stringify(loginmsg));
        loginmsgobj.Req.Username = self.usernameEditBox.string;
        loginmsgobj.Req.Password = self.passwordEditBox.string;
        ManilaSocket.send(loginmsgobj);

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
            self.popPup.active = true;
            var seq = cc.sequence(

                cc.scaleTo(0.2, 1.05, 1.05),
                cc.scaleTo(0.2, 1, 1),
            )
            self.popPup.runAction(seq);
            let labelNode = self.popPup.getChildByName("AlertString");
            let label = labelNode.getComponent(cc.Label);
            label.string = "请填写所有信息！"

        }
    }
    pressExit() {
        var self = this;
        self.popPup.active = false;
    }
}
