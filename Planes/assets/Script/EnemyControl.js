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
        type: 1
    },

    // LIFE-CYCLE CALLBACKS:

    onLoad: function () {
        this.bulletPool = new cc.NodePool();
        var initCount = 5;
        for (var i = 0; i < initCount; ++i) {
            var enemy = cc.instantiate(this.bulletPrefab);
            enemy.test = function (other, self) {
                console.log('enemy.onCollisionEnter1');
            }
            this.bulletPool.put(enemy);

        }

    },

    start() {

    },
    setControlNode: function (node, index) {
        this.nodeControl = node
        this.enmeyIndex = index
    },

    // update (dt) {},
});
