import EventMng from "../Script/Fundamentals/Manager/EventMng";
import { PhaseDragBoat, PhasePostDragBoat } from "../Script/Fundamentals/Imports"
const { ccclass, property } = cc._decorator;

@ccclass
export default class PostDragger extends cc.Component {
    sum: [number, number, number] = [0, 0, 0]
    dragable: [number] = [0]
    dragger: string

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
        let limit = self.dragger === "1drag" ? 1 : 2

        if (operation === "+" && dragNumber + 1 <= limit) {
            if (dragNumber + 1 > 0) {
                label.string = "+" + (dragNumber + 1);
            } else {
                label.string = "" + (dragNumber + 1);
            }
            self.sum[index - 1] = dragNumber + 1;
        } else if (operation === "-" && dragNumber - 1 >= -limit) {
            if (dragNumber - 1 > 0) {
                label.string = "+" + (dragNumber - 1);
            } else {
                label.string = "" + (dragNumber - 1);
            }
            self.sum[index - 1] = dragNumber - 1;
        }
    }

    pressOK(event, data) {
        let self = this;
        let limit = self.dragger === "1drag" ? 1 : 2;
        let realSum = 0;

        for (let i = 0; i < self.sum.length; i++) {
            realSum += self.sum[i] > 0 ? self.sum[i] : -self.sum[i];

        }
        if (realSum === limit) {
            EventMng.emit("PostDrag", self.dragable, self.sum, self.dragger, true);
            self.sum = [0, 0, 0];

        } else {
            EventMng.emit("PostDrag", self.dragable, self.sum, self.dragger, false);
        }

    }
}
