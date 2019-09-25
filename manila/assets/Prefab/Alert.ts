 

const {ccclass, property} = cc._decorator;

@ccclass
export default class Alert extends cc.Component {

    onPressExit(){
        var self = this;
        self.node.parent.active = false;
    }
 
}
