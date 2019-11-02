
const { ccclass, property } = cc._decorator;

@ccclass
export default class NameScripter extends cc.Component {
    @property([cc.SpriteFrame])
    pawnPics: [cc.SpriteFrame] = [new cc.SpriteFrame()]

    @property([cc.SpriteFrame])
    readyPics: [cc.SpriteFrame] = [new cc.SpriteFrame()]
}
