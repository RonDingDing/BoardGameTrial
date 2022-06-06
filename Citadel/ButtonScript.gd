extends Node2D
enum Need { GOLD, CARD }
enum MagicianSwitch { DECK, PLAYER }
enum ScriptMode { RESOURCE, MAGICIAN }
onready var Signal = get_node("/root/Main/Signal")
onready var TweenMove = get_node("/root/Main/Tween")
onready var script1_pos = $Script1.rect_position
onready var script2_pos = $Script2.rect_position
onready var end_turn_pos = $EndTurn.rect_position
onready var can_end = true
onready var script_mode = ScriptMode.RESOURCE


func set_script_mode(mode: int) -> void:
	script_mode = mode
	if mode == ScriptMode.RESOURCE:
		$Script1Label.text = "NOTE_NEED_GOLD"
		$Script2Label.text = "NOTE_NEED_CARD"
	elif mode == ScriptMode.MAGICIAN:
		$Script1Label.text = "NOTE_FROM_DECK"
		$Script2Label.text = "NOTE_FROM_PLAYER"


func _ready() -> void:
	hide_scripts()
	hide_end_turn()
	hide_kill_steal_info()
	$Script1.rect_position = script1_pos
	$Script1Label.rect_position = Vector2(script1_pos.x + 25, script1_pos.y + 28)
	$Script2.rect_position = script2_pos
	$Script2Label.rect_position = Vector2(script2_pos.x + 25, script2_pos.y + 28)
	$EndTurn.rect_position = end_turn_pos
	$EndTurnLabel.rect_position = Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28)


func set_assassinated(char_name: String) -> void:
	$KillStealInfo/KillChar/Pic.animation = char_name
	$KillStealInfo.show()
	$KillStealInfo/KillChar.show()
	$KillStealInfo/KillSword.show()


func set_stolen(char_name: String) -> void:
	$KillStealInfo/StealChar/Pic.animation = char_name
	$KillStealInfo.show()
	$KillStealInfo/StealChar.show()
	$KillStealInfo/StealPocket.show()


func set_can_end(end: bool) -> void:
	can_end = end
	var color = Color(1, 0, 0) if end else Color(0.76171875, 0.76171875, 0.76171875)  #gray
	$EndTurnLabel.set("custom_colors/font_color", color)


func set_reminder_text(string: String) -> void:
	$ReminderLabel.text = string


func hide_kill_steal_info() -> void:
	$KillStealInfo.hide()
	$KillStealInfo/StealChar.hide()
	$KillStealInfo/StealPocket.hide()


func show_reminder() -> void:
	$ReminderBackground.show()
	$ReminderLabel.show()


func hide_reminder() -> void:
	$ReminderBackground.hide()
	$ReminderLabel.hide()


func show_end_turn() -> void:
	$EndTurn.show()
	$EndTurnLabel.show()


func hide_end_turn() -> void:
	$EndTurn.hide()
	$EndTurnLabel.hide()


func show_scripts() -> void:
	$Script2.show()
	$Script2Label.show()
	$Script1.show()
	$Script1Label.show()


func hide_scripts() -> void:
	$Script1.hide()
	$Script1Label.hide()
	$Script2.hide()
	$Script2Label.hide()


func on_end_turn_pressed() -> void:
	if can_end:
		Signal.emit_signal("sgin_end_turn")
		$EndTurn.rect_position = end_turn_pos
		$EndTurnLabel.rect_position = Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28)


func on_script1_pressed() -> void:
	if script_mode == ScriptMode.RESOURCE:
		Signal.emit_signal("sgin_resource_need", Need.GOLD)
	elif script_mode == ScriptMode.MAGICIAN:
		Signal.emit_signal("sgin_magician_switch", MagicianSwitch.DECK)
	$Script1.rect_position = script1_pos
	$Script1Label.rect_position = Vector2(script1_pos.x + 25, script1_pos.y + 28)


func on_script2_pressed() -> void:
	if script_mode == ScriptMode.RESOURCE:
		Signal.emit_signal("sgin_resource_need", Need.CARD)
	elif script_mode == ScriptMode.MAGICIAN:
		Signal.emit_signal("sgin_magician_switch", MagicianSwitch.PLAYER)
	$Script2.rect_position = script2_pos
	$Script2Label.rect_position = Vector2(script2_pos.x + 25, script2_pos.y + 28)


func on_end_turn_mouse_entered() -> void:
	if can_end:
		$EndTurn.set_position(Vector2(end_turn_pos.x, end_turn_pos.y - 20))
		$EndTurnLabel.set_position(Vector2(end_turn_pos.x + 25, end_turn_pos.y + 8))


func on_end_turn_mouse_exited() -> void:
	if can_end:
		$EndTurn.set_position(end_turn_pos)
		$EndTurnLabel.set_position(Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28))


func on_script2_mouse_entered() -> void:
	$Script2.set_position(Vector2(script2_pos.x, script2_pos.y - 20))
	$Script2Label.set_position(Vector2(script2_pos.x + 25, script2_pos.y + 8))


func on_script2_mouse_exited() -> void:
	$Script2.set_position(script2_pos)
	$Script2Label.set_position(Vector2(script2_pos.x + 25, script2_pos.y + 28))


func on_script1_mouse_entered() -> void:
	$Script1.set_position(Vector2(script1_pos.x, script1_pos.y - 20))
	$Script1Label.set_position(Vector2(script1_pos.x + 25, script1_pos.y + 8))


func on_script1_mouse_exited() -> void:
	$Script1.set_position(script1_pos)
	$Script1Label.set_position(Vector2(script1_pos.x + 25, script1_pos.y + 28))


func wait_magician() -> void:
	set_can_end(false)
	set_script_mode(ScriptMode.MAGICIAN)
	Signal.emit_signal("sgin_set_reminder", "NOTE_MAGICIAN")
	show_scripts()
