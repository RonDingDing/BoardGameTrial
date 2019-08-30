import { ISocket, SocketState, WbSocket } from "./Socket";
import EventMng from "../Manager/EventMng"

export class SocketEvent {
    public static readonly SOCKET_OPEN = 'SOCKET_OPEN';
    public static readonly SOCKET_CLOSE = 'SOCKET_CLOSE';
}

const DATA_TOTAL_LEN = 4;	//数据总长度
const PROTOCOLTYPE_LEN = 4;	//协议号长度

export interface ISocketDelegate {
    onSocketOpen();
    onSocketMessage(data: string | ArrayBuffer);
    onSocketError(errMsg);
    onSocketClosed(msg: string);
}

/**
 * 实现socket各个回调接口
 */
export class SocketDelegate implements ISocketDelegate {
    private _socket: ISocket;

    constructor(address: string) {
        this.connect(address);

    }

    isSocketOpened() {
        return (this._socket && this._socket.getState() == SocketState.OPEN);
    }

    isSocketClosed() {
        return this._socket == null;
    }

    connect(url: string) {
        this._socket = new WbSocket(url, this);
        this._socket.connect();
    }

    closeConnect() {
        if (this._socket) {
            this._socket.close();
        }
    }

    onSocketOpen() {
        EventMng.emit(SocketEvent.SOCKET_OPEN);
    }

    onSocketError(errMsg) {
        errMsg && console.error('socket error, msg = ' + errMsg);

    }

    onSocketClosed(msg: string) {
        this._socket.close();
        this._socket = null;
        EventMng.emit(SocketEvent.SOCKET_CLOSE);
    }

    onSocketMessage(data: string | ArrayBuffer) {
        if (this.isSocketClosed()) {
            console.error('onMessage call but socket had closed')
            return;
        }
        let msg = this.bufferToMsg(data);
        EventMng.emit(msg.messageName, msg);
    }

    bufferToMsg(data) {
        return JSON.parse(data);
    }

    msgToBuffer(obj:object){
        return JSON.stringify(obj);
    }
    send(obj) {
        let msg = this.msgToBuffer(obj);
        this._socket.send(msg);
    }


}