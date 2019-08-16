var Global = require('Global');

var ICON_STATE_NORMAL = 1;
var ICON_STATE_MOVE = 2;
var ICON_STATE_PRECANCEL = 3;
var ICON_STATE_PRECANCEL2 = 4;
var ICON_STATE_CANCEL = 5;
var ICON_STATE_CANCELED = 6;

cc.Class({
    extends: cc.Component,

    properties: {
        canvas: cc.Node,
        soundNode: {
            default: null,
            type: cc.Node
        },
        board: {
            default: null,
            type: cc.Node
        },
        scoreLabel: {
            default: null,
            type: cc.Label
        },
        iconPrefab: {
            default: null,
            type: cc.Prefab
        }
    },

    // LIFE-CYCLE CALLBACKS:

    onLoad() {
        var self = this;
        this.initGameData();
        // this.initGameBoard();
        // this.canvas.on(cc.Node.EventType.TOUCH_START, this.onmTouchBegan, this);
        // this.canvas.on(cc.Node.EventType.TOUCH_MOVE, this.onmTouchMove, this);
        // this.canvas.on(cc.Node.EventType.TOUCH_END, this.onmTouchEnd, this);

    },

    start() {

    },

    initGameData: function () {
        this.row = 9;
        this.col = 11;
        this.typeNum = 6;
        this.isControl = false;
        this.chooseIconPos = cc.v2(-1, -1);
        this.deltaPos = cc.v2(0, 0);
        this.score = 0;
        this.iconsDataTable = []
        for (var i = 1; i < this.row; i++) {
            this.iconsDataTable[i] = [];
            for (var j = 1; j < this.col; j++) {
                this.iconsDataTable[i][j] = { "state": ICON_STATE_NORMAL, "iconType": 1, "obj": null };
                this.iconsDataTable[i][j].iconType = this.getNewIconType(i, j);
            }

        }
    },

    getNewIconType: function (i, j) {
        var exTypeTable = [-1, -1]
        if (i > 1) {
            exTypeTable[1] = this.iconsDataTable[i - 1][j].iconType;
        }
        if (j > 1) {
            exTypeTable[2] = this.iconsDataTable[i][j - 1].iconType;
        }
        var typeTable = [];
        var max = 0;
        for (var i = 1; i < this.typeNum; i++) {
            if (i != exTypeTable[1] && i != exTypeTable[2]) {
                max = max + 1;
            }
        }
        return typeTable[Global.getRandomInt(1, max)];
    }
    // update (dt) {},
});
