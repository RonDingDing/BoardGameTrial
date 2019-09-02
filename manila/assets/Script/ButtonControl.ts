
const {ccclass, property} = cc._decorator;

@ccclass
export default class NewClass extends cc.Component {
 
  
    pressStart(){
        cc.director.loadScene("LoginMenu");
    }
}
