import auto_helloworld from "../../../Data/AutoUI/Scene/auto_helloworld";
import UIBase from "../UIBase";
import UIHelp from "../UIHelp";

const { ccclass, menu, property } = cc._decorator;

@ccclass
@menu("UI/Scene/UIHelloworld")
export default class UIHelloworld extends UIBase {
	ui: auto_helloworld = null;

	protected static prefabUrl = "";
	protected static className = "UIHelloworld";

	onUILoad() {
		this.ui = this.node.addComponent(auto_helloworld);
	}

	onShow() {

	}

	onHide() {

	}

	onStart() {

	}

	onClose() {
		UIHelp.CloseUI(UIHelloworld);
	}
}