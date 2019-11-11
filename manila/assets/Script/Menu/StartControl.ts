const { ccclass, property } = cc._decorator;
import { ManilaSocket } from "../Fundamentals/Imports"
import BasicControl from "./BasicControl"
import { Global } from "../Fundamentals/ManilaGlobal";
import i18n = require("LanguageData");

@ccclass
export default class StartControl extends BasicControl {

    onLoad() {
        i18n.init(Global.language);
    }


    pressStart() {
        let self = this;
        if (ManilaSocket.isSocketOpened()) {
            cc.director.loadScene("LoginMenu");
        } else {
            self.playPopup(i18n.t("Not connected to server!"));
        }
    }


}
