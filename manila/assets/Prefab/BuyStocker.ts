import EventMng from "../Script/Fundamentals/Manager/EventMng";

const {ccclass, property} = cc._decorator;

@ccclass
export default class BuyStocker extends cc.Component {
    pressBuyStock(event, data){
        EventMng.emit("BuyStock", data);
    }
}
