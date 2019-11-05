
const {ccclass, property} = cc._decorator;

@ccclass
export default class Pawner extends cc.Component {
    @property([cc.SpriteFrame])
    pawnPics : [cc.SpriteFrame] = [new cc.SpriteFrame]
}
