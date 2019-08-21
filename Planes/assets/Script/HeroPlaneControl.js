cc.Class({
    extends: cc.Component,

    properties: {
        bulletPrefab: {
            default: null,
            type: cc.Prefab
        },
        explodePrefab: {
            default: null,
            type: cc.Prefab
        },
        com1: {
            default: null,
            type: cc.Node
        },
        com2: {
            default: null,
            type: cc.Node
        }
    },



    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start() {

    },

    setControlNode: function (node) {
        this.nodeControl = node;
    },

    // update (dt) {},
});
