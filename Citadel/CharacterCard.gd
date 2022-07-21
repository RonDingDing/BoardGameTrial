extends  "res://Area2D2.gd"


onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var TimerGlobal = get_node("/root/Main/Timer")
onready var char_name = "Unchosen"
onready var desc_trans = ""
onready var name_text = ""
onready var char_num = 0
onready var char_up_offset = 0
onready var face_up = false
onready var char_mode = Data.CharMode.ENLARGE

func get_char_info() -> Dictionary:
	return {
		"char_name": char_name,
		"char_num": char_num,
		"char_up_offset": char_up_offset,
		"position": global_position
	}

func set_char_mode(mode: int) -> void:
	char_mode = mode

func init_char(
	animation_name: String,
	number: int,
	up_offset: float,
	scales: Vector2,
	pos: Vector2,
	face_is_up: bool
) -> void:
	char_name = animation_name
	char_num = number
	desc_trans = tr(str("CHAR_", animation_name.to_upper().replace(" ", "_")))
	name_text = tr(str("NAME_", animation_name.to_upper().replace(" ", "_")))
	char_up_offset = up_offset
	$Face/Description.rect_position.y = 420 - up_offset
	set_face_up(face_is_up)
	set_scale(scales)  #Vector2(0.13, 0.13)
	set_position(pos)
	set_char_mode(Data.CharMode.ENLARGE)


func set_face_up(face_is_up: bool) -> void:
	var temp_name
	var temp_text
	var temp_desc

	if face_is_up:
		temp_name = char_name
		temp_text = name_text
		temp_desc = desc_trans
	else:
		temp_name = "Unchosen"
		temp_desc = ""
		temp_text = ""

	face_up = face_is_up
	$Face.set_animation(temp_name)
	$Face/Name.set_text(temp_text)
	$Face/Description.set_text(temp_desc)

	$Face.set_visible(face_is_up)
	$Back.set_visible(not face_is_up)


func on_mouse_entered() -> void:
	mouse_collided = true
	var card = find_top_most_card_collide_with_mouse()
	if card == null:
		return
	if face_up and char_mode != Data.CharMode.STATIC:
		Signal.emit_signal("sgin_char_focused", card.char_name)


func on_mouse_exited() -> void:
	if face_up and char_mode != Data.CharMode.STATIC:
		Signal.emit_signal("sgin_char_unfocused", char_name)


func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 如卡片不灰（可点击），主视角玩家选择了某角色
	if event.is_pressed() and event is InputEventMouseButton and char_mode == Data.CharMode.CLICKABLE:  # and event.doubleclick:
		var card = find_top_most_card_collide_with_mouse()
		if card == null:
			return
		
		Signal.emit_signal("sgin_char_selected", card.char_num)


 
