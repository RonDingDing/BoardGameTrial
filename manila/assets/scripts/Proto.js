// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html


cc.Class({
    extends: cc.Component,

    properties: {
        
        protos: {
            default: null,
            type: Object,
            //     get () {
            //         return this._bar;
            //     },
            //     set (value) {
            //         this._bar = value;
            //     }
        },
    },

    // LIFE-CYCLE CALLBACKS:

    onLoad() {
        var self = this;
        var pbkiller = require("pbkiller");
        pbkiller.preload(function () {
            let pb = pbkiller.loadAll();
            self.protos = {};
            self.protos.bail = new pb.poster.Bail();
            self.protos.bail.Req = new pb.poster.Bail.REQ();

        });
      
    },

    start() {

    },


    // update (dt) {},
});






