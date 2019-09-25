import {
    ManilaSocket, enterroommsg, EnterRoomMsg, RoomDetailMsg,
} from "../Fundamentals/Imports"
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
        EventMng.on(RoomDetailMsg, self.onRoomDetailMsg, self);
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
        let self = this;
        if (message.Error < 0) {
            self.popUpError(message);
        } else {
            console.log("EnterRoomControl: ", message.Code, message);
            if (message.Ans.RoomNum !== 0) {
                // self.scheduleOnce(() => {
                cc.director.loadScene("ManilaRoom");
                // }, 2);
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
            console.log("EnterRoomControl: ", message.Code, message);          
            self.messageToGlobal(message);
            console.log("EnterRoomControl: Global:", Global);
        }
    }


}
