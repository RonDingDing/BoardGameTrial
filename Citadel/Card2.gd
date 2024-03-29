extends "res://Area2D2.gd"


onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var mode = Data.CardMode.STATIC
onready var card_name = "Unknown"
onready var card_name_cal = "Unknown"
onready var card_up_offset = 0
onready var face_up = false setget set_face_up
onready var desc_trans = ""
onready var name_text = ""
 


func init_card(animation_name: String, scales: Vector2, pos: Vector2, face_is_up: bool, modes: int) -> void:
	card_name_cal = Data.rid_num(animation_name)
	card_name = animation_name
	var desc = str("DESC_", card_name_cal.to_upper().replace(" ", "_"))
	var csde = tr(str("DESC_", card_name_cal.to_upper().replace(" ", "_")))
	desc_trans = csde if desc != csde else ""
	name_text = tr(str("NAME_", card_name_cal.to_upper().replace(" ", "_")))
	var up_offset = Data.get_card_info(card_name_cal)["up_offset"]
	card_up_offset = up_offset
	$Face/Description.rect_position.y = Data.CARD_UP_OFFSET_START - up_offset
	set_face_up(face_is_up)
	set_card_mode(modes)
	set_scale(scales)
	set_global_position(pos)


func set_face_up(face_is_up: bool) -> void:
	var temp_name
	var temp_text
	var temp_desc
	if face_is_up:
		temp_name = Data.rid_num(card_name)
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
#	$Face.set_visible(face_is_up)
#	$Back.set_visible(not face_is_up)


func on_mouse_entered() -> void:
	mouse_collided = true
	var card = find_top_most_card_collide_with_mouse()
	if card != null and card.get_script() == self.get_script():
		if face_up and card.can_be_top and (not card.mode in [Data.CardMode.SELECT, Data.CardMode.STATIC]):
			Signal.emit_signal("sgin_card_focused", card.card_name)


func on_mouse_exited() -> void:
	mouse_collided = false
	var card = find_top_most_card_collide_with_mouse()
	if card != null and card.get_script() == self.get_script():
#		if face_up and card.can_be_top and (not card.mode in [Data.CardMode.SELECT, Data.CardMode.STATIC]):
#			Signal.emit_signal("sgin_card_focused", card.card_name)
		pass
	else:
		Signal.emit_signal("sgin_card_unfocused")
	


func get_card_info() -> Dictionary:
	return {"card_name": card_name, "card_up_offset": card_up_offset, "position": global_position}


func set_card_mode(modes: int) -> void:
	mode = modes
	if "Museum" in card_name and face_up and mode == Data.CardMode.BUILT_CLICKABLE:
		$MuseumNum.set_visible(true)
	else:
		$MuseumNum.set_visible(false)


func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 如卡片不灰（可点击），主视角玩家选择了某角色
	if event.is_pressed() and event is InputEventMouseButton:  #and event.doubleclick:
		var card = find_top_most_card_collide_with_mouse()
		if card == null:
			return
		match mode:
			Data.CardMode.SELECT:
				Signal.emit_signal("sgin_card_selected", card.card_name, global_position)
			Data.CardMode.PLAY:
				Signal.emit_signal("sgin_card_played", card.card_name, global_position)
			Data.CardMode.WARLORD_SELECTING:
				Signal.emit_signal("sgin_card_warlord_selected", card.card_name, global_position)
			Data.CardMode.ARMORY_SELECTING:
				Signal.emit_signal("sgin_card_armory_selected", card.card_name, global_position)
			Data.CardMode.BUILT_CLICKABLE:
				Signal.emit_signal("sgin_card_clickable_clicked", card.card_name, global_position)
			Data.CardMode.LABORATORY_SELECTING:
				Signal.emit_signal("sgin_card_laboratory_selected", card.card_name, global_position)
			Data.CardMode.NECROPOLIS_SELECTING:
				Signal.emit_signal("sgin_card_necropolis_selected", card.card_name, global_position)
			Data.CardMode.THIEVES_DEN_SELECTING:
				if not "Thieves' Den" in card_name and card.card_name == card_name:
					Signal.emit_signal("sgin_card_thieves_den_selected", card.card_name, global_position)
			Data.CardMode.MUSEUM_SELECTING:
				Signal.emit_signal("sgin_card_museum_selected", card.card_name, global_position)


func add_museum_num() -> void:
	$MuseumNum.set_text(str(int($MuseumNum.text) + 1))
	$MuseumNum.show()


func set_museum_num(num: int) -> void:
	$MuseumNum.set_text(str(num))
