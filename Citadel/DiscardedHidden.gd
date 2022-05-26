extends Node2D
onready var CharacterCard = preload("res://CharacterCard.tscn")
onready var Signal = get_node("/root/Main/Signal")
onready var TweenMove = get_node("/root/Main/Tween")
onready var Data = get_node("/root/Main/Data")
enum State { IDLE, DISCARDING, HIDING, SELECTING }
var char_pos = Vector2(0, 0)


func set_char_pos(pos: Vector2) -> void:
	char_pos = pos


func get_discarded_position() -> Vector2:
	var discarded_children_count = $Discarded.get_child_count()
	var local_pos
	match discarded_children_count:
		0:
			local_pos = Vector2(-50, -30)
		1:
			local_pos = Vector2(0, -30)
		2:
			local_pos = Vector2(50, -30)
		_:
			local_pos = Vector2(0, 0)
	return local_pos + global_position


func move_char_to_hidden(char_name: String,  from_pos: Vector2) -> void:
	move_char_to(State.HIDING, char_name,  from_pos)


func move_char_to_discarded(char_name: String,  from_pos: Vector2) -> void:
	move_char_to(State.DISCARDING, char_name,  from_pos)


func move_char_to_selected(char_name: String, from_pos: Vector2) -> void:
	move_char_to(State.SELECTING, char_name,  from_pos)


func move_char_to(mode: int, char_name: String, from_pos: Vector2) -> void:
	var init_face_up
	var face_visible_org
	var face_visible_aft
	var back_visible_org
	var back_visible_aft
	var emite
	var to_pos
	var sub_node = null
	if mode == State.HIDING:
		init_face_up = false
		face_visible_org = false
		face_visible_aft = false
		back_visible_org = true
		back_visible_aft = true
		emite = "sgin_hidden_once_finished"
		to_pos = get_discarded_position()
		sub_node = $Hidden
	elif mode == State.DISCARDING:
		init_face_up = true
		face_visible_org = false
		face_visible_aft = true
		back_visible_org = true
		back_visible_aft = false
		emite = "sgin_discarded_once_finished"
		to_pos = get_discarded_position()
		sub_node = $Discarded
	else:
		init_face_up = true
		face_visible_org = true
		face_visible_aft = true
		back_visible_org = false
		back_visible_aft = false
		emite = "sgin_selected_char_once_finished"
		to_pos = char_pos
		sub_node = $Selected
	var char_info = Data.get_char_info(char_name)
	var animation_name = char_name
	var number = char_info["char_num"]
	var up_offset = char_info["char_up_offset"]
	var incoming_char = CharacterCard.instance()
	Signal.emit_signal("sgin_char_not_ready", incoming_char)
	sub_node.add_child(incoming_char)
	sub_node.store.append(char_info)
	incoming_char.init_char(
		animation_name, number, up_offset, Vector2(0.13, 0.13), from_pos, init_face_up
	)
	TweenMove.animate(
		[
			[
				incoming_char,
				"global_position",
				from_pos,
				to_pos,
			],
			[
				incoming_char,
				"scale",
				Vector2(0.175, 0.175),
				Vector2(0.04, 0.04),
			],
			[
				incoming_char.get_node("Face"),
				"visible",
				face_visible_org,
				face_visible_aft,
			],
			[
				incoming_char.get_node("Back"),
				"visible",
				back_visible_org,
				back_visible_aft,
			]
		]
	)

	yield(TweenMove, "tween_all_completed")
	if mode == State.SELECTING:
		incoming_char.global_position = Vector2(9999,9999)
#		sub_node.store.erase(char_name)
	Signal.emit_signal(emite, char_name)
	Signal.emit_signal("sgin_char_ready", incoming_char)
