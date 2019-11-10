import EventMng from "../Script/Fundamentals/Manager/EventMng";

 

const {ccclass, property} = cc._decorator;

@ccclass
export default class InvestPasser extends cc.Component {

    onPressInvestPass(){
        var self = this;
        EventMng.emit("InvestOnshore", "none")
        self.node.parent.active = false;
    }
 
}
