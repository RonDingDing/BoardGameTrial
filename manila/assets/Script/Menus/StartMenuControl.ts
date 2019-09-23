 
import { Global } from "../ManilaGlobal"
import { AlertControl  } from "../AlertControl"
import { ManilaSocket} from "../Imports"
const {ccclass, property} = cc._decorator;

@ccclass
export default class NewClass extends cc.Component {
 
 
    pressStart() {
        let self = this;
        if (ManilaSocket.isSocketOpened()) {
            cc.director.loadScene("LoginMenu");
        } else {
            self.playPopUp("未连接网络！")
        }
    }
}
