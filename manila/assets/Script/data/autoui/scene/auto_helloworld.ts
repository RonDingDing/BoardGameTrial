const { ccclass } = cc._decorator;

@ccclass
export default class auto_helloworld extends cc.Component {
	Canvas: cc.Node;
	background: cc.Node;
	cocos: cc.Node;
	label: cc.Node;

	public static URL:string = "db://assets/Scene/helloworld.fire"

    onLoad () {
		let parent = this.node.getParent();
		this.Canvas = parent.getChildByName("Canvas");
		this.background = this.Canvas.getChildByName("background");
		this.cocos = this.Canvas.getChildByName("cocos");
		this.label = this.Canvas.getChildByName("label");

    }
}
