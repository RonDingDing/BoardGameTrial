extends Node2D
enum Need { GOLD, CARD }
onready var Signal = get_node("/root/Main/Signal")


func _ready() -> void:
	hide()


func on_need_gold_pressed():
	Signal.emit_signal("sgin_resource_need", Need.GOLD)


func on_need_card_pressed():
	Signal.emit_signal("sgin_resource_need", Need.CARD)


func on_need_card_mouse_entered():
	var pos = $NeedCard.rect_position
	var pos2 = $NeedCardLabel.rect_position
	$NeedCard.set_position(Vector2(pos.x, pos.y - 20))
	$NeedCardLabel.set_position(Vector2(pos2.x, pos2.y - 20))


func on_need_card_mouse_exited():
	var pos = $NeedCard.rect_position
	var pos2 = $NeedCardLabel.rect_position
	$NeedCard.set_position(Vector2(pos.x, pos.y + 20))
	$NeedCardLabel.set_position(Vector2(pos2.x, pos2.y + 20))


func on_need_gold_mouse_entered():
	var pos = $NeedGold.rect_position
	var pos2 = $NeedGoldLabel.rect_position
	$NeedGold.set_position(Vector2(pos.x, pos.y - 20))
	$NeedGoldLabel.set_position(Vector2(pos2.x, pos2.y - 20))


func on_need_gold_mouse_exited():
	var pos = $NeedGold.rect_position
	var pos2 = $NeedGoldLabel.rect_position
	$NeedGold.set_position(Vector2(pos.x, pos.y + 20))
	$NeedGoldLabel.set_position(Vector2(pos2.x, pos2.y + 20))
