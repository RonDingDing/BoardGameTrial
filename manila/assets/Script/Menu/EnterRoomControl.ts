import {
    ManilaSocket, enterroommsg, EnterRoomMsg, RoomDetailMsg,
} from "../Fundamentals/Imports"
import { Global } from "../Fundamentals/ManilaGlobal"
import EventMng from "../Fundamentals/Manager/EventMng";
import BasicControl from "./BasicControl"
import i18n = require("LanguageData");
const { ccclass, property } = cc._decorator;

@ccclass
export default class EnterRoomControl extends BasicControl {


    @property(cc.EditBox)
    roomNumEditBox: cc.EditBox = null

    onLoad() {
        super.onLoad();
        var self = this;
        i18n.init(Global.language);
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
            self.playPopup(i18n.t("Please enter an integer\ngreater than 0!"));
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
            self.messageToGlobal(message);
        }
    }


}
