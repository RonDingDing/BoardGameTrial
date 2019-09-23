import { ManilaSocket, SocketEvents, LoginMsg, SignUpMsg, EnterRoomMsg, Errors, loginmsg, signupmsg, enterroommsg, ErrUserExit, ErrUserNotExit } from "./Imports"
import EventMng from "./Manager/EventMng";
import { Global } from "./ManilaGlobal"
const { ccclass, property } = cc._decorator;

@ccclass
export default class AlertControl extends cc.Component {


    @property(cc.Prefab)
    popPup: cc.Prefab = null

    onLoad() {
     
       
    }
    start (){
        let a = cc.instantiate(this.popPup);
        console.log(a);
    }

     // pressExit() {
    //     let self = this;
    //     self.popPup.active = false;
    // }

    playPopUp(content: string) {
        let self = this;
        let popPup = cc.instantiate(self.popPup);

        popPup.active = true;
        let seq = cc.sequence(
            cc.scaleTo(0.2, 1.05, 1.05),
            cc.scaleTo(0.2, 1, 1),
        )
        popPup.runAction(seq);
        let popPupString = popPup.getComponentInChildren("Exit");

        popPupString.string = content;
    }

}    