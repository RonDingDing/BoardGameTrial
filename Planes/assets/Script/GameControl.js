cc.Class({
    extends: cc.Component,

    properties: {
        canvas: cc.Node,
        soundNode: {
            default: null,
            type: cc.Node
        },
        heroLayer: {
            default: null,
            type: cc.Node
        },
        enemyLayer: {
            default: null,
            type: cc.Node
        },
        gameOver: {
            default: null,
            type: cc.Node
        },
        bg1: {
            default: null,
            type: cc.Node
        },
        bg2: {
            default: null,
            type: cc.Node
        },
        enemyPrefabs1: {
            default: null,
            type: cc.Prefab
        },
        enemyPrefabs2: {
            default: null,
            type: cc.Prefab
        },
        enemyPrefabs3: {
            default: null,
            type: cc.Prefab
        },
        enemyPrefabs4: {
            default: null,
            type: cc.Prefab
        },
        enemyPrefabs5: {
            default: null,
            type: cc.Prefab
        },
    },

    // LIFE-CYCLE CALLBACKS:

    registerMoveEvent: function () {
        var self = this;
        self.moveToPos = cc.v2(0, 0);
        self.isMoving = false;
        self.canvas.on(cc.Node.EventType.TOUCH_START, function (event) {
            var touches = event.getTouches();
            var touchLoc = touches[0].getLocation();
            self.isMoving = true;
            self.moveToPos = self.heroPlane.parent.convertToNodeSpaceAR(touchLoc);
        }, self.node);
        self.canvas.on(cc.Node.EventType.TOUCH_MOVE, function (event) {
            var touches = event.getTouches();
            var touchLoc = touches[0].getLocation();
            self.moveToPos = self.heroPlane.parent.convertToNodeSpaceAR(touchLoc);
        }, self.node);
        self.canvas.on(cc.Node.EventType.TOUCH_END, function (event) {
            self.isMoving = false;
        }, self.node);
    },

    onLoad() {
        var self = this;
        console.log("Prefabs/Hero" + Global.selectIndex + ".prefab");
        cc.loader.loadRes("Prefabs/Hero" + Global.selectIndex + ".prefab", function (err, prefab) {
            self.heroPlane = cc.instantiate(prefab);
            self.heroPlane.getComponent("HeroPlaneControl").setControlNode(self.canvas);
            self.heroPlane.setPosition(cc.v2(0, -400));
            self.heroLayer.addChild(self.heroPlane);
            self.registerMoveEvent();
        })
        this.moveBg11(this.bg1);
        this.moveBg21(this.bg2);
        // this.createEnemyLogic();

        var manager = cc.director.getCollisionManager();
        manager.enabled = true;
    },

    start() {

    },
    moveBg11: function (node) {
        node.setPosition(cc.v2(0, -480));
        var finished = cc.callFunc(function (target) {
            this.moveBg12(node);
        }, this);
        node.runAction(cc.sequence(cc.moveTo(1, 0, -960), finished));
    },
    moveBg12: function (node) {
        node.setPosition(cc.v2(0, 960));
        var finished = cc.callFunc(function (target) {
            this.moveBg12(node);
        }, this);
        node.runAction(cc.sequence(cc.moveTo(4, 0, -960), finished));
    },
    moveBg21: function (node) {
        node.setPosition(cc.v2(0, 480));
        var finished = cc.callFunc(function (target) {
            this.moveBg12(node);
        }, this);
        node.runAction(cc.sequence(cc.moveTo(3, 0, -960), finished));
    },

    updateHeroPos: function (dt) {
        if (!this.isMoving) {
            return;
        }
        var oldPos = this.heroPlane.position;
        var direction = this.moveToPos.sub(oldPos).normalize();
        this.heroPlane.setPosition(oldPos.add(direction.mul(300 * dt)));
    },

    update(dt) {
        this.updateHeroPos(dt);
    },
});
