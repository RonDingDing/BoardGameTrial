import EventMng from "../Script/Fundamentals/Manager/EventMng";


const {ccclass, property} = cc._decorator;

@ccclass
export default class NewClass extends cc.Component {
    pressPlunder(event, data) {
        EventMng.emit("Pirate", data);
    }
}
