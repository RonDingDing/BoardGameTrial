import { SocketDelegate, SocketEvent } from "./Network/SocketDelegate"
// export const address = "ws://echo.websocket.org/";
export const address = "ws://localhost:8080/";
export var SocketEvents = SocketEvent;
export var ManilaSocket = new SocketDelegate(address);

export const Errors = "000";
export const LoginMsg = "001";
export const SignUpMsg = "002";


export const ErrNoHandler = -1
export const ErrUserExit = -2
export const ErrUserNotExit = -3



export var errors = {
    "Code": Errors,
    "Error": 0
}

export var loginmsg = {
    "Code": LoginMsg,
    "Req":
    {
        "Username": "",
        "Password": ""
    },
    "Ans":
    {
        "Username": "",
        "Gold": 0,
        "Mobile": "",
        "Email": "",
    },
    "Error": 0
}

export var signupmsg = {
    "Code": SignUpMsg,
    "Req":
    {
        "Username": "",
        "Password": "",
        "Mobile": "",
        "Email": "",

    },
    "Ans":
    {
        "Username": "",
        "Gold": 0,
        "Mobile": "",
        "Email": "",
    },
    "Error": 0
}