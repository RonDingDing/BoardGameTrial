import EventMng from "../Script/Fundamentals/Manager/EventMng";


const { ccclass, property } = cc._decorator;

@ccclass
export default class PutBoater extends cc.Component {
    @property
    selected: [number, number, number, number, number,] = [0, 0, 0, 0, 0]

    @property
    selectedLength = 0;

    pressSelect(event, num) {
        const CoffeeColor = "1";
        const SilkColor = "2";
        const GinsengColor = "3";
        const JadeColor = "4";

        let self = this;
        let originValue = self.selected[num];
        self.selected[num] = originValue === 0 ? 1 : 0;
        self.selectedLength = originValue === 0 ? self.selectedLength + 1 : self.selectedLength - 1;
        let name = "";
        switch (num) {
            case SilkColor:
                name = "SilkShip"; break;
            case JadeColor:
                name = "JadeShip"; break;
            case CoffeeColor:
                name = "CoffeeShip"; break;
            case GinsengColor:
                name = "GinsengShip"; break;
        }
        let spriteNode = self.node.parent.getChildByName(name);
        spriteNode.opacity = spriteNode.opacity == 255 ? 127 : 255;
    }

    pressOk() {
        let self = this;
        let except = 0;
        for (let i = 1; i < self.selected.length; i++) {
            if (self.selected[i] === 0) {
                except = i;
                break;
            }
        }
        EventMng.emit("PutBoat", except, self.selectedLength === 3);
    }

}
