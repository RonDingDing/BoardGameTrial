var GlobalHandle = require("Global");
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

    enemyDes: function(index, enemy) {
        this.enemyPools[index].put(enemy);
    },
    createEnemyLogic: function () {
        this.enemyPools = [];
        for (var i = 1; i <= 5; ++i) {
            this.enemyPools[i] = new cc.NodePool();
            for (var j = 1; j <= 5; ++j) {
                var enemy = cc.instantiate(this["enemyPrefabs" + i]);
                enemy.getComponent("EnemyControl").setControlNode(this.canvas, i);
                this.enemyPools[i].put(enemy);
            }
        }
        var EnemyLogic = cc.callFunc(function (target) {
            var enemyType = GlobalHandle.getRandomInt(1, 5);
            var enemyPool = this.enemyPools[enemyType];
            var enemy;
            if (enemyPool.size() > 0) {
                enemy = enemyPool.get();
            } else {
                enemy = cc.instantiate(this["enemyPrefabs" + enemyType]);
                enemy.getComponent("EnemyControl").setControlNode(self.canvas);
            }
            enemy.parent = this.enemyLayer;

            var enemyPosX = GlobalHandle.getRandomInt(-300, 300);
            var pos = cc.v2(enemyPosX, 700);
            enemy.setPosition(pos);
            var finished = cc.callFunc(function (target) {
                enemyPool.put(enemy);
            }, this);

            if (enemyType == 1) {
                enemy.runAction(
                    cc.sequence(cc.moveTo(4, -pos.x, -600), finished)
                );
            } else if (enemyType == 2) {
                enemy.runAction(cc.sequence(cc.moveTo(5, pos.x, -600), finished)
                );
            } else if (enemyType == 3) {
                enemy.runAction(
                    cc.sequence(cc.moveTo(4, -pos.x, -600), finished)
                );
            } else if (enemyType == 4) {
                enemy.runAction(cc.sequence(cc.moveTo(4, pos.x, -600), finished));
            } else if (enemyType == 5) {
                enemy.runAction(
                    cc.sequence(
                        cc.moveTo(3, -pos.x, 0),
                        cc.moveTo(3, -pos.x, -600),
                        finished
                    )
                );
            }
            this.node.runAction(cc.sequence(cc.delayTime(5), EnemyLogic));
        }, this);
        this.node.runAction(cc.sequence(cc.delayTime(1), EnemyLogic));
    },
    onLoad() {
        var self = this;
        cc.loader.loadRes("Prefabs/Hero" + Global.selectIndex + ".prefab", function (err, prefab) {
            self.heroPlane = cc.instantiate(prefab);
            self.heroPlane.getComponent("HeroPlaneControl").setControlNode(self.canvas);
            self.heroPlane.setPosition(cc.v2(0, -400));
            self.heroLayer.addChild(self.heroPlane);
            self.registerMoveEvent();
        })
        this.moveBg11(this.bg1);
        this.moveBg21(this.bg2);
        this.createEnemyLogic();

        var manager = cc.director.getCollisionManager();
        manager.enabled = true;
    },

    start() {

    },
    onLoadSceneFinish: function () { },

    onBack: function () {
        cc.director.loadScene(
            "db://assets/startMenu.fire",
            this.onLoadSceneFinish.bind(this)
        );
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

    setGameOver: function () {
        this.gameOver.active = true;
    },

    updateHeroPos: function (dt) {
        if (!this.isMoving) {
            return;
        }
        var oldPos = this.heroPlane.position;
        var direction = this.moveToPos.sub(oldPos).normalize();
        this.heroPlane.setPosition(oldPos.add(direction.mul(1000 * dt)));
    },

    update(dt) {
        this.updateHeroPos(dt);
    },
});
