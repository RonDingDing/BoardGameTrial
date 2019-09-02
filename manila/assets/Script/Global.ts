import { SocketDelegate, SocketEvent } from "./Network/SocketDelegate"
// export const address = "ws://echo.websocket.org/";
export const address = "ws://localhost:8080/";
export var SocketEvents = SocketEvent;
export var ManilaSocket = new SocketDelegate(address);




