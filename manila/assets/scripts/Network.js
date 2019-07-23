cc.Class({
    extends: cc.Component,

    properties: {

        websocketReq: cc.Label,

        websocketResp: cc.Label,

    },

    prepareWebSocket: function () {
        var self = this;
        var websocketLabel = this.websocketReq;
        var respLabel = this.websocketResp;
        this.websocket = new WebSocket("ws://echo.websocket.org");
        this.websocket.binaryType = "arraybuffer";
        this.websocket.onopen = function (evt) {
            websocketLabel.textKey = "cases/05_scripting/11_network/NetworkCtrl.js.5";
        };

        this.websocket.onmessage = function (evt) {
            var binary = new Uint16Array(evt.data);
            var binaryStr = 'response bin msg: ';
            var str = '';
            for (var i = 0; i < binary.length; i++) {
                if (binary[i] === 0) {
                    str += "\'\\0\'";
                }
                else {
                    var hexChar = '0x' + binary[i].toString('16').toUpperCase();
                    str += String.fromCharCode(hexChar);
                }
            }

            binaryStr += str;
            respLabel.string = binaryStr;
            websocketLabel.textKey = "cases/05_scripting/11_network/NetworkCtrl.js.6";
        };

        this.websocket.onerror = function (evt) {
            websocketLabel.textKey = "cases/05_scripting/11_network/NetworkCtrl.js.7";
        };

        this.websocket.onclose = function (evt) {
            websocketLabel.textKey = "cases/05_scripting/11_network/NetworkCtrl.js.8";
            // After close, it's no longer possible to use it again, 
            // if you want to send another request, you need to create a new websocket instance
            self.websocket = null;
        };

        this.scheduleOnce(this.sendWebSocketBinary, 1);
    },

})