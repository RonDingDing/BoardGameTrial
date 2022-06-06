extends Node2D

onready var Signal = get_node("/root/Main/Signal")
onready var TimerGlobal = get_node("/root/Main/Timer")
enum CardMode { ENLARGE, STATIC, SELECT, PLAY }
onready var mode = CardMode.STATIC
onready var card_name = "Unknown"
onready var card_up_offset = 0
onready var face_up = false
onready var desc_trans = ""
onready var name_text = ""


func init_card(
	animation_name: String,
	up_offset: float,
	scales: Vector2,
	pos: Vector2,
	face_is_up: bool,
	modes: int
) -> void:
	card_name = animation_name
	var desc = str("DESC_", animation_name.to_upper().replace(" ", "_"))
	var csde = tr(str("DESC_", animation_name.to_upper().replace(" ", "_")))
	desc_trans = csde if desc != csde else ""
	name_text = tr(str("NAME_", animation_name.to_upper().replace(" ", "_")))
	card_up_offset = up_offset
	$Face/Description.rect_position.y = 282 - up_offset
	set_face_up(face_is_up)
	set_card_mode(modes)
	set_scale(scales)
	set_global_position(pos)


func set_face_up(face_is_up: bool) -> void:
	var temp_name
	var temp_text
	var temp_desc

	if face_is_up:
		temp_name = card_name
		temp_text = name_text
		temp_desc = desc_trans
	else:
		temp_name = "Unknown"
		temp_desc = ""
		temp_text = ""

	face_up = face_is_up
	$Face.set_animation(temp_name)
	$Face/Name.set_text(temp_text)
	$Face/Description.set_text(temp_desc)
	$Face.set_visible(face_is_up)
	$Back.set_visible(not face_is_up)


#
#func init(animation_name: String, up_offset: float) -> void:
#	card_name = animation_name
#	$Face.animation = animation_name
#	var name_trans = tr(str("NAME_", animation_name.to_upper().replace(" ", "_")))
#	$Face/Name.text = name_trans
#	var desc = str("DESC_", animation_name.to_upper().replace(" ", "_"))
#	var desc_trans = tr(str("DESC_", animation_name.to_upper().replace(" ", "_")))
#	$Face/Description.text = desc_trans if desc != desc_trans else ""
#	$Face/Description.rect_position.y = 282 - up_offset
#	scale = Vector2(0.175, 0.175)
#
#
#func init_name(animation_name: String, to_scale: Vector2, global_pos: Vector2) -> void:
#	card_name = animation_name
#	scale = to_scale
#	global_position = global_pos


func on_mouse_entered() -> void:
	if face_up and mode in [CardMode.ENLARGE, CardMode.PLAY]:
		# TimerGlobal.set_wait_time(0.05)
		# TimerGlobal.start()
		# yield(TimerGlobal, "timeout")
		Signal.emit_signal("sgin_card_focused", card_name)


func on_mouse_exited() -> void:
	if face_up and mode in [CardMode.ENLARGE, CardMode.PLAY]:
		Signal.emit_signal("sgin_card_unfocused", card_name)


func get_card_info() -> Dictionary:
	return {"card_name": card_name, "card_up_offset": card_up_offset, "position": global_position}


func set_card_mode(modes: int) -> void:
	mode = modes


func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 如卡片不灰（可点击），主视角玩家选择了某角色
	if event.is_pressed() and event is InputEventMouseButton and event.doubleclick:
		match mode:
			CardMode.SELECT:
				Signal.emit_signal("sgin_card_selected", card_name, global_position)
			CardMode.PLAY:
				Signal.emit_signal("sgin_card_played", card_name, global_position)
