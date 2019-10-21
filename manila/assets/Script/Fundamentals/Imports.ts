import { SocketDelegate, SocketEvent } from "./Network/SocketDelegate"
// export const address = "ws://echo.websocket.org/";
export const address = "ws://localhost:8080/";
export var SocketEvents = SocketEvent;
export var ManilaSocket = new SocketDelegate(address);
 
export const SilkColor    = 1;
export const JadeColor    = 2;
export const CoffeeColor  = 3;
export const GinsengColor = 4;

export const Errors = "000";
export const LoginMsg = "001";
export const SignUpMsg = "002";
export const EnterRoomMsg = "003";
export const ReadyMsg = "004";
export const RoomDetailMsg = "005";
export const GameStartMsg = "006";
export const BidMsg = "007";
export const HandMsg = "008";
export const BuyStockMsg = "009";

export const NorAlreadyInRoom   = 1
export const NorNewEntered      = 2
export const ErrNormal          = 0

export const ErrNoHandler = -1
export const ErrUserExit = -2
export const ErrUserNotExit = -3
export const ErrCannotEnterRoom = -4
export const ErrNoSuchPlayer = -5
export const ErrCannotExitRoom = -6 
export const ErrGameStarted     = -7
export const ErrUserNotInRoom   = -8
export const ErrFailedEntering  = -9




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


export var roomdetailmsg = {
    "Code": RoomDetailMsg,
    "Req":
    {
        "Username": "",
        "RoomNum": 0
    },
    "Ans":
    {
        "GameNum": 0,
        "CoffeeDeck": 0,
        "SilkDeck": 0,
        "GinsengDeck": 0,
        "JadeDeck": 0,
        "CoffeeStockPrice": 0,
        "SilkStockPrice": 0,
        "GinsengStockPrice": 0,
        "JadeStockPrice": 0,
        "Mapp": [
            // {"Name": "", "Taken": "", "Price": 0, "Award": 0, "Onboard": false}
        ],
        "PlayerName": [],
        "PlayerNumForStart": 0,
        "PlayerNumMax": 0,
        "Players": [
            // {"Money": 0, "Name": "", "Online": true, "Stock": 0, "Seat": 0, "Ready": false, "Canbid": true}
        ],
        "RoomNum": 0,
        "Round": 0,    
        "Started": false,
        "HighestBidder": "",
        "CurrentPlayer": "",
        "Phase": ""
    },
    "Error": 0
}


export var readymsg = {
    "Code": ReadyMsg,
    "Req":
    {
        "Username": "",
        "Ready": false
    },
    "Ans":
    {
        "Username": "",
        "Ready": false,
        "RoomNum": 0
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
        "GameNum": 0,
        "RoomNum": 0,      
        
    },
    "Error": 0
}

export var gamestartmsg = {
    "Code": GameStartMsg,
    "Req":
    {
       
    },
    "Ans":
    {        
        "RoomNum": 0              
    },
    "Error": 0
}

export var bidmsg = {
    "Code": BidMsg,
    "Req":
    {
       "Username": "", 
       "Bid": 0,
    },
    "Ans":
    {        
        "Username": "",
        "HighestBidPrice": 0,
        "HighestBidder": ""
    },
    "Error": 0
}


export var handmsg = {
    "Code": HandMsg,
    "Req":
    {
       "Username": "",         
    },
    "Ans":
    {        
        "Username": "",
        "Hand": [
            // 0, 0, 0, 0
        ]
    },
    "Error": 0
}

export var buystockmsg = {
    "Code": BuyStockMsg,
    "Req":
    {
       "Username": "",  
       "Stock" : 0      
    },
    "Ans":
    {        
        "Username": "",
        "RemindOrOperated": false, 
        "Bought": 0,
        "SilkDeck": 0,
        "JadeDeck": 0,
        "CoffeeDeck": 0,
        "GinsengDeck": 0
    },
    "Error": 0
}