import { SocketDelegate, SocketEvent } from "./Network/SocketDelegate"
export const address = "ws://echo.websocket.org/";
export var SocketEvents = SocketEvent;
export var ManilaSocket = new SocketDelegate(address);






