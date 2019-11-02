import EventMng from "../Script/Fundamentals/Manager/EventMng";
import { PhaseDragBoat } from "../Script/Fundamentals/Imports"
const { ccclass, property } = cc._decorator;

@ccclass
export default class Dragger extends cc.Component {
    sum: [number, number, number] = [0, 0, 0]
    dragable: [number] = [0]
    phase: string

    @property([cc.SpriteFrame])
    shipPics: [cc.SpriteFrame] = [new cc.SpriteFrame()]

    pressDrag(event, data) {
        let self = this;
        let num = data[0];
        let index = parseInt(num);
        let operation = data[1];
        let dragStockNode = self.node.parent.getChildByName("DragStock" + num);
        let label = dragStockNode.getComponent(cc.Label)
        let string = label.string;
        let dragNumber = parseInt(string);

        if (operation === "+" && dragNumber + 1 <= 5) {
            label.string = "" + (dragNumber + 1);
            self.sum[index - 1] = dragNumber + 1;
        } else if (operation === "-" && dragNumber - 1 >= 0) {
            label.string = "" + (dragNumber - 1);
            self.sum[index - 1] = dragNumber - 1;
        }
    }

    pressOK(event, data) {
        let self = this;
        let realSum = 0;
        for (let i = 0; i < self.sum.length; i++) {
            realSum += self.sum[i];
        }
        if (realSum === 9 && self.phase === PhaseDragBoat) {
            EventMng.emit("DragBoat", self.dragable, self.sum, true);
            self.sum = [0, 0, 0];
            self.phase = "";
        } else {
            EventMng.emit("DragBoat", self.dragable, self.sum, false);
        }

    }
}
