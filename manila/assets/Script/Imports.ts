import { SocketDelegate, SocketEvent } from "./Network/SocketDelegate"
// export const address = "ws://echo.websocket.org/";
export const address = "ws://localhost:8080/";
export var SocketEvents = SocketEvent;
export var ManilaSocket = new SocketDelegate(address);

export const Errors = "000";
export const LoginMsg = "001";
export const SignUpMsg = "002";
export const EnterRoomMsg = "003";

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
        "RoomNum": 0
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

export var enterroommsg = {
    "Code": EnterRoomMsg,
    "Req":
    {
        "Username": "",
        "RoomNum": 0
    },
    "Ans":
    {
        "CoffeeDeck": 0,
        "GameNum": 0,
        "GinsengDeck": 0,
        "JadeDeck": 0,
        "Mapp": [
            // {Name: "", Taken: "", Price: 0, Award: 0, Onboard: false}
        ],
        "PlayerName": [
            // ""
        ],
        "PlayerNumForStart": 0,
        "PlayerNumMax": 0,
        "Players": [
            // {"Money": 0, "Name": "", "Online": true, "Stock":  [0, 0, 0, 0], "Seat": 0}
        ],
        "RoomNum": 0,
        "Round": 0,
        "SilkDeck": 0,
        "Started": false
    },
    "Error": 0
}