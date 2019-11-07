import { SocketDelegate, SocketEvent } from "./Network/SocketDelegate"
// export const address = "ws://echo.websocket.org/";
export const address = "ws://localhost:8080/";
export var SocketEvents = SocketEvent;
export var ManilaSocket = new SocketDelegate(address);

export const CoffeeColor = 1;
export const SilkColor = 2;
export const GinsengColor = 3;
export const JadeColor = 4;

export const PhaseBidding = "Bidding"
export const PhaseBuyStock = "BuyStock"
export const PhasePutBoat = "PutBoat"
export const PhaseDragBoat = "DragBoat"
export const PhaseInvest = "Invest"
export const PhasePostDragBoat = "PostDragBoat"
export const PhaseSettle = "Settle"

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
export const ChangePhaseMsg = "010";
export const PutBoatMsg = "011";
export const DragBoatMsg = "012";
export const InvestMsg = "013";
export const DiceMsg = "014";
export const PirateMsg = "015";
export const PostDragMsg= "016";

export const NorAlreadyInRoom = 1;
export const NorNewEntered = 2;
export const ErrNormal = 0;

export const ErrNoHandler = -1;
export const ErrUserExit = -2;
export const ErrUserNotExit = -3;
export const ErrCannotEnterRoom = -4;
export const ErrNoSuchPlayer = -5;
export const ErrCannotExitRoom = -6;
export const ErrGameStarted = -7;
export const ErrUserNotInRoom = -8;
export const ErrFailedEntering = -9;
export const ErrNotEnoughGameMoney = -10;
export const ErrUserNotCaptain = -11;
export const ErrNotEnoughStock = -12;
export const ErrInvalidInvestPoint = -13;
export const ErrInvestPointTaken = -14;

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
        "Deck": [
            // 0
        ],

        "StockPrice": [
            // 0
        ],

        "Mapp": [
            // {"Name": "", "Taken": "", "Price": 0, "Award": 0, "Onboard": false}
        ],
        "PlayerName": [
            // ""
        ],
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
        "Phase": "",
        "Ship": [
            // {"ShipType": 0, "Step": 0}
        ],
        "CastTime": 0
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
        "HighestBidder": "",
        "RoomNum": 0
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
        "Stock": 0
    },
    "Ans":
    {
        "Username": "",
        "RoomNum": 0,
        "RemindOrOperated": false,
        "Bought": 0,
        "SilkDeck": 0,
        "JadeDeck": 0,
        "CoffeeDeck": 0,
        "GinsengDeck": 0
    },
    "Error": 0
}

export var changephasemsg = {
    "Code": ChangePhaseMsg,
    "Req":
    {

    },
    "Ans":
    {
        "RoomNum": 0,
        "Phase": ""
    },
    "Error": 0
}

export var putboatmsg = {
    "Code": PutBoatMsg,
    "Req":
    {
        "Username": "",
        "RoomNum": 0,
        "Except": 0
    },
    "Ans":
    {
        "Username": "",
        "RoomNum": 0,
        "Except": 0,
        "RemindOrOperated": false,
    },
    "Error": 0
}


export var dragboatmsg = {
    "Code": DragBoatMsg,
    "Req":
    {
        "Username": "",
        "RoomNum": 0,
        "ShipDrag": [
            // 0, 0, 0, 0
        ],
        "Phase": ""
    },
    "Ans":
    {
        "Username": "",
        "Phase": "",
        "RoomNum": 0,
        "RemindOrOperated": false,
        "Ship": [
            // 0, 0, 0, 0
        ],
        "Dragable": [
            // 0, 0, 0 
        ]
    },
    "Error": 0
}


export var investmsg = {
    "Code": InvestMsg,
    "Req":
    {
        "Username": "",
        "RoomNum": 0,
        "Invest": "",
    },
    "Ans":
    {
        "Username": "",
        "RoomNum": 0,
        "RemindOrOperated": false,
        "Invest": "",
    },
    "Error": 0
}

export var dicemsg = {
    "Code": DiceMsg,
    "Req":
    {
    },
    "Ans":
    {
        
        "RoomNum": 0,
        "Dice": [
            0
        ],
        "CastTime": 0
    },
    "Error": 0
}


export var piratemsg = {
    "Code": PirateMsg,
    "Req":
    {
        "RoomNum": 0,
        "Pirate": "",
        "Plunder": 0,
    },
    "Ans":
    {        
        "RoomNum": 0,
        "ShipVacant": [
            //true
        ],
        "CastTime": 0,
        "Pirate": "",
        "RemindOrOperated": false
    },
    "Error": 0
}

export var postdragmsg = {
    "Code": PostDragMsg,
    "Req":
    {
        "Username": "",
        "DragSum": 0,
        "RoomNum": 0,
        "ShipDrag": [
            // 0, 0, 0, 0
        ],
        "Phase": ""
    },
    "Ans":
    {
        "Username": "",
        "Phase": "",
        "DragSum": 0,
        "RoomNum": 0,
        "RemindOrOperated": false,
        "Ship": [
            // 0, 0, 0, 0
        ],
        "Dragable": [
            // 0, 0, 0 
        ]
    },
    "Error": 0
}