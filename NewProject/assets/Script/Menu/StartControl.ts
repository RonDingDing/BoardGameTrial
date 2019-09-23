const { ccclass, property } = cc._decorator;
import { ManilaSocket } from "../Fundamentals/Imports"
import BasicControl  from "./BasicControl"

@ccclass
export default class StartControl extends BasicControl{

 
   
    
    pressStart() {
        let self = this;
        if (ManilaSocket.isSocketOpened()) {
            cc.director.loadScene("LoginMenu");
        } else {
            self.playPopup("未连接网络！")
        }
    }


}
