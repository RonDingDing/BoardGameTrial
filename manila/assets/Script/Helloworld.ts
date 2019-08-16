const {ccclass, property} = cc._decorator;
import GameController from "./GameController"

@ccclass
export default class Helloworld extends cc.Component {

    @property(cc.Label)
    label: cc.Label = null;

    @property
    text: string = 'hello';

    start () {
        // init logic
        GameController.init();
        GameController.network.connect();
        this.label.string = this.text;
    }
}
