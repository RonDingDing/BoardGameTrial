extends Node2D
enum Need { GOLD, CARD }
onready var Signal = get_node("/root/Main/Signal")
onready var need_gold_pos = $NeedGold.rect_position
onready var need_card_pos = $NeedCard.rect_position
onready var end_turn_pos = $EndTurn.rect_position
onready var can_end = true

func _ready() -> void:
	hide_resource()
	hide_end_turn()
	$NeedGold.rect_position = need_gold_pos
	$NeedGoldLabel.rect_position = Vector2(need_gold_pos.x + 25, need_gold_pos.y + 28)
	$NeedCard.rect_position = need_card_pos
	$NeedCardLabel.rect_position = Vector2(need_card_pos.x + 25, need_card_pos.y + 28)
	$EndTurn.rect_position = end_turn_pos
	$EndTurnLabel.rect_position = Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28)

func set_can_end(end: bool) -> void:
	can_end = end
	 
	
func show_end_turn() -> void:
	$EndTurn.show()
	$EndTurnLabel.show()


func hide_end_turn() -> void:
	$EndTurn.hide()
	$EndTurnLabel.hide()


func show_resource() -> void:
	$NeedCard.show()
	$NeedCardLabel.show()
	$NeedGold.show()
	$NeedGoldLabel.show()


func hide_resource() -> void:
	$NeedCard.hide()
	$NeedCardLabel.hide()
	$NeedGold.hide()
	$NeedGoldLabel.hide()


func on_end_turn_pressed() -> void:
	if can_end:
		Signal.emit_signal("sgin_end_turn")
		$EndTurn.rect_position = end_turn_pos
		$EndTurnLabel.rect_position = Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28)


func on_need_gold_pressed() -> void:
	Signal.emit_signal("sgin_resource_need", Need.GOLD)
	$NeedGold.rect_position = need_gold_pos
	$NeedGoldLabel.rect_position = Vector2(need_gold_pos.x + 25, need_gold_pos.y + 28)



func on_need_card_pressed() -> void:
	Signal.emit_signal("sgin_resource_need", Need.CARD)
	$NeedGold.rect_position = need_gold_pos
	$NeedGoldLabel.rect_position = Vector2(need_gold_pos.x + 25, need_gold_pos.y + 28)


func on_end_turn_mouse_entered() -> void:
	$EndTurn.set_position(Vector2(end_turn_pos.x, end_turn_pos.y - 20))
	$EndTurnLabel.set_position(Vector2(end_turn_pos.x + 25, end_turn_pos.y + 8))


func on_end_turn_mouse_exited() -> void:
	$EndTurn.set_position(end_turn_pos)
	$EndTurnLabel.set_position(Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28))


func on_need_card_mouse_entered() -> void:
	$NeedCard.set_position(Vector2(need_card_pos.x, need_card_pos.y - 20))
	$NeedCardLabel.set_position(Vector2(need_card_pos.x + 25, need_card_pos.y + 8))


func on_need_card_mouse_exited() -> void:
	$NeedCard.set_position(need_card_pos)
	$NeedCardLabel.set_position(Vector2(need_card_pos.x + 25, need_card_pos.y + 28))


func on_need_gold_mouse_entered() -> void:
	$NeedGold.set_position(Vector2(need_gold_pos.x, need_gold_pos.y - 20))
	$NeedGoldLabel.set_position(Vector2(need_gold_pos.x + 25, need_gold_pos.y + 8))


func on_need_gold_mouse_exited() -> void:
	$NeedGold.set_position(need_gold_pos)
	$NeedGoldLabel.set_position(Vector2(need_gold_pos.x + 25, need_gold_pos.y + 28))
