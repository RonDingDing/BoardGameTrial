window.Global = {
    selectIndex: 1,
};
cc.Class({
    extends: cc.Component,

    properties: {
        playBtn: {
            default: null,
            type: cc.Button
        },
        plane1: {
            default: null,
            type: cc.Button
        },
        plane2: {
            default: null,
            type: cc.Button
        },
        plane3: {
            default: null,
            type: cc.Button
        }
    },
    onLoadSceneFinish() {

    },
    // LIFE-CYCLE CALLBACKS:

    onLoad() {
        this.selectIndex = 1;
        this.planeArr = [];
        this.planeArr[1] = this.plane1;
        this.planeArr[2] = this.plane2;
        this.planeArr[3] = this.plane3;
    },
    choosePlane(index) {
        if (this.selectIndex != index) {
            this.planeArr[this.selectIndex].node.setPosition(cc.v2(this.planeArr[this.selectIndex].node.getPosition().x, -60));
            this.selectIndex = index;
            this.planeArr[this.selectIndex].node.setPosition(cc.v2(this.planeArr[this.selectIndex].node.getPosition().x, 60));

        }
    },
    onselectIndex1() {
        this.choosePlane(1);
    },
    onselectIndex2() {
        this.choosePlane(2);
    },
    onselectIndex3() {
        this.choosePlane(3);
    },
    onPreparePlay() {
        Global.selectIndex = this.selectIndex
        cc.director.loadScene('db://assets/Scene/mainGame.fire', this.onLoadSceneFinish.bind(this));
    },

    // update (dt) {},
});
