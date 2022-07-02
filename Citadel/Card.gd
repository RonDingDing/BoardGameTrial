extends Node2D

onready var Signal = get_node("/root/Main/Signal")
onready var TimerGlobal = get_node("/root/Main/Timer")
enum CardMode {
	ENLARGE,
	STATIC,
	SELECT,
	PLAY,
	WARLORD_SELECTING,
	BUILT_CLICKABLE,
	ARMORY_SELECTING
}
onready var mode = CardMode.STATIC
onready var card_name = "Unknown"
onready var card_up_offset = 0
onready var face_up = false
onready var desc_trans = ""
onready var name_text = ""


func rid_num(name: String) -> String:
	var regex = RegEx.new()
	regex.compile("[0-9]")
	var result = regex.search(name)
	var new_name = name
	if result != null:
		new_name = name.replace(result.get_string(0), "")
	return new_name


func init_card(
	animation_name: String,
	up_offset: float,
	scales: Vector2,
	pos: Vector2,
	face_is_up: bool,
	modes: int
) -> void:
	card_name = animation_name
	var new_name = rid_num(animation_name)
	var desc = str("DESC_", new_name.to_upper().replace(" ", "_"))
	var csde = tr(str("DESC_", new_name.to_upper().replace(" ", "_")))
	desc_trans = csde if desc != csde else ""
	name_text = tr(str("NAME_", new_name.to_upper().replace(" ", "_")))
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
		temp_name = rid_num(card_name)
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


func on_mouse_entered() -> void:
	if (
		face_up
		and (
			mode
			in [
				CardMode.ENLARGE,
				CardMode.PLAY,
				CardMode.WARLORD_SELECTING,
				CardMode.BUILT_CLICKABLE,
				CardMode.ARMORY_SELECTING
			]
		)
	):
		Signal.emit_signal("sgin_card_focused", card_name)


func on_mouse_exited() -> void:
	if (
		face_up
		and (
			mode
			in [
				CardMode.ENLARGE,
				CardMode.PLAY,
				CardMode.WARLORD_SELECTING,
				CardMode.BUILT_CLICKABLE,
				CardMode.ARMORY_SELECTING
			]
		)
	):
		Signal.emit_signal("sgin_card_unfocused", card_name)


func get_card_info() -> Dictionary:
	return {"card_name": card_name, "card_up_offset": card_up_offset, "position": global_position}


func set_card_mode(modes: int) -> void:
	mode = modes


func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 如卡片不灰（可点击），主视角玩家选择了某角色
	if event.is_pressed() and event is InputEventMouseButton:  #and event.doubleclick:
		match mode:
			CardMode.SELECT:
				Signal.emit_signal("sgin_card_selected", card_name, global_position)
			CardMode.PLAY:
				Signal.emit_signal("sgin_card_played", card_name, global_position)
			CardMode.WARLORD_SELECTING:
				Signal.emit_signal("sgin_card_warlord_selected", card_name, global_position)
			CardMode.ARMORY_SELECTING:
				Signal.emit_signal("sgin_card_armory_selected", card_name, global_position)
			CardMode.BUILT_CLICKABLE:
				Signal.emit_signal("sgin_card_clickable_clicked", card_name, global_position)
