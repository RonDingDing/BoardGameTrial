import { ManilaSocket, SocketEvents, SignUpMsg, signupmsg, enterroommsg, EnterRoomMsg, ErrUserExit } from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import EventMng from "../Fundamentals/Manager/EventMng";
import BasicControl from "./BasicControl"
const { ccclass, property } = cc._decorator;

@ccclass
export default class EnterRoomControl extends BasicControl {


    @property(cc.EditBox)
    roomNumEditBox: cc.EditBox = null

    onLoad() {
        super.onLoad();
        var self = this;        
        EventMng.on(EnterRoomMsg, self.onEnterRoomMsg, self);
    }


    pressEnterRoom() {
        let self = this;
        if (Global.playerUser === "") {
            ManilaSocket.closeConnect();
            cc.director.loadScene("StartMenu");
            return;
        }
        let roomnum = parseInt(self.roomNumEditBox.string);
        if (isNaN(roomnum)) {
            self.playPopup("请输入大于0的整数！");
            self.roomNumEditBox.string = "";
            return;
        }

        let enterroommsgobj = JSON.parse(JSON.stringify(enterroommsg));
        enterroommsgobj.Req.Username = Global.playerUser;
        enterroommsgobj.Req.RoomNum = roomnum;  
        ManilaSocket.send(enterroommsgobj);
 


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
