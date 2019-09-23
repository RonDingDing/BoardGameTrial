const { ccclass, property } = cc._decorator;
import { ManilaSocket, SocketEvents, loginmsg, LoginMsg, ErrUserNotExit, enterroommsg, EnterRoomMsg } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import EventMng from "../Fundamentals/Manager/EventMng";
import BasicControl from "./BasicControl"


@ccclass
export default class LoginControl extends BasicControl {
    @property(cc.EditBox)
    usernameEditBox: cc.EditBox = null

    @property(cc.EditBox)
    passwordEditBox: cc.EditBox = null



    onLoad() {
        super.onLoad();
        var self = this;
        EventMng.on(LoginMsg, self.onLoginMsg, self);
        EventMng.on(EnterRoomMsg, self.onEnterRoomMsg, self);
    }

    onLoginMsg(message) {
        let self = this;
        let username = message.Ans.Username;
        let gold = message.Ans.Gold;
        let roomnum = message.Ans.RoomNum;
        if (message.Error == ErrUserNotExit) {
            self.playPopup("用户名或密码错误！");
            self.usernameEditBox.string = "";
            self.passwordEditBox.string = "";
        } else {
            self.playPopup("用户" + username + "登录成功！");
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
            self.playPopup("用户名不能为空");
        } else if (!self.passwordEditBox.string) {
            self.playPopup("密码不能为空");
        } else if (Global.playerUser) {
            self.playPopup("已经登录，用户名为" + Global.playerUser);
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
        console.log(message);
        let self = this;
        if (message.Ans.RoomNum !== 0) {
            self.messageToGlobal(message);
            cc.director.loadScene("ManilaRoom");
        } else {
            cc.director.loadScene("SelectRoom");
        }
    }

    messageToGlobal(message) {
        let mapList = message.Ans.Mapp || [];
        let playerList = message.Ans.Players || [];
        for (let i = 0; i < mapList.length; i++) {
            Global.mapp[mapList[i].Name] = mapList[i];
        }
        for (let j = 0; j < playerList.length; j++) {
            Global.allPlayers[playerList[j].Name] = playerList[j];
        }
        
        Global.silkdeck = message.Ans.SilkDeck;
        Global.jadedeck = message.Ans.JadeDeck;
        Global.ginsengdeck = message.Ans.GinsengDeck;
        Global.coffeedeck = message.Ans.CoffeeDeck;
        Global.round = message.Ans.Round;
        Global.roomNum = message.Ans.RoomNum;
        Global.allPlayerName = message.Ans.PlayerName;
        Global.started = message.Ans.Started;
        console.log(Global.mapp);
        console.log(Global.allPlayers);
    }
}