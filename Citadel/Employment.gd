extends Node2D

onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var CharacterCard = preload("res://CharacterCard.tscn")
# onready var TweenMove = get_node("/root/Main/Tween")
onready var TweenMotion = get_node("/root/Main/TweenMotion")
onready var available_characters = {1: "Assassin", 2: "Thief", 3: "Magician", 4: "King", 5: "Bishop", 6: "Merchant", 7: "Architect", 8: "Warlord", 9: "Queen"}
onready var nine_chars = true
onready var full_num = 10 if nine_chars else 9
onready var available = available_characters.keys()
onready var discarded = []
onready var hidden = []

onready var state = Data.EmploymentState.IDLE
onready var discarded_hidden_position = Data.FAR_AWAY
onready var char_pos = Data.FAR_AWAY


func _ready():
	$DiscardedHidden.hide()


func find_by_num(employee_num: int) -> String:
	if employee_num in available_characters:
		return available_characters[employee_num]
	return "Unchosen"


func hide_discard_hidden() -> void:
	$DiscardedHidden.hide()


func set_char_pos(pos: Vector2) -> void:
	char_pos = pos


func get_discarded_position() -> Vector2:
	var discarded_children_count = $DiscardedHidden/Discarded.get_child_count()
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
	return local_pos + $DiscardedHidden/Dock.global_position


func character_to_hidden(char_name: String, from_pos: Vector2) -> void:
	character_to(Data.EmploymentState.HIDING, char_name, from_pos)


func character_to_discarded(char_name: String, from_pos: Vector2) -> void:
	character_to(Data.EmploymentState.DISCARDING, char_name, from_pos)


func character_to_selected(char_name: String, from_pos: Vector2) -> void:
	character_to(Data.EmploymentState.SELECTING, char_name, from_pos)


func character_to(mode: int, char_name: String, from_pos: Vector2) -> void:
	var init_face_up
	var face_visible_org
	var face_visible_aft
	var back_visible_org
	var back_visible_aft
	var emite
	var to_pos
	var sub_node = null
	if mode == Data.EmploymentState.HIDING:
		init_face_up = false
		face_visible_org = false
		face_visible_aft = false
		back_visible_org = true
		back_visible_aft = true
		emite = "sgin_hidden_once_finished"
		to_pos = get_discarded_position()
		sub_node = $DiscardedHidden/Hidden
		$DiscardedHidden.show()
	elif mode == Data.EmploymentState.DISCARDING:
		init_face_up = true
		face_visible_org = false
		face_visible_aft = true
		back_visible_org = true
		back_visible_aft = false
		emite = "sgin_discarded_once_finished"
		to_pos = get_discarded_position()
		sub_node = $DiscardedHidden/Discarded
		$DiscardedHidden.show()
	else:
		init_face_up = true
		face_visible_org = true
		face_visible_aft = true
		back_visible_org = false
		back_visible_aft = false
		emite = "sgin_selected_char_once_finished"
		to_pos = char_pos
		sub_node = $DiscardedHidden/Selected
	var char_info = Data.get_char_info(char_name)
	var animation_name = char_name
	var number = char_info["char_num"]
	var up_offset = char_info["char_up_offset"]
	var incoming_char = CharacterCard.instance()
	Signal.emit_signal("sgin_char_not_ready", incoming_char)
	sub_node.add_child(incoming_char)
	sub_node.store.append(char_info)
	incoming_char.init_char(animation_name, number, up_offset, Data.CHAR_BANNED, from_pos, init_face_up, Data.CharMode.STATIC)
	# TweenMove.animate(
	# 	[
	# 		[
	# 			incoming_char,
	# 			"global_position",
	# 			from_pos,
	# 			to_pos,
	# 		],
	# 		[
	# 			incoming_char,
	# 			"scale",
	# 			Data.CARD_SIZE_MEDIUM,
	# 			Data.CHAR_SIZE_SMALL,
	# 		],
	# 		[
	# 			incoming_char.get_node("Face"),
	# 			"visible",
	# 			face_visible_org,
	# 			face_visible_aft,
	# 		],
	# 		[
	# 			incoming_char.get_node("Back"),
	# 			"visible",
	# 			back_visible_org,
	# 			back_visible_aft,
	# 		]
	# 	]
	# )

	# yield(TweenMove, "tween_all_completed")
	TweenMotion.ani_flip_move(incoming_char, to_pos, Data.CHAR_SIZE_SMALL, true, face_visible_aft) 
	yield(Signal, "all_ani_completed")
	if mode == Data.EmploymentState.SELECTING:
		incoming_char.global_position = Data.FAR_AWAY
#	incoming_char.set_char_mode(Data.CharMode.ENLARGE)
	Signal.emit_signal(emite, number, char_name)
	Signal.emit_signal("sgin_char_ready", incoming_char)


func reset_available() -> void:
	available = available_characters.keys()


func add_employee(char_num: int) -> void:
	available.append(char_num)


func set_discarded_hidden_position(pos: Vector2) -> void:
	discarded_hidden_position = pos


func get_selectable_characters(include_4: bool) -> Array:
	var char_array = []
	for num in range(1, full_num):
		if num in available:
			if num == 4 and (not include_4):
				continue
			char_array.append(num)
	return char_array


func init_face_up_ordered(char_array: Array) -> void:
	put_char_num(char_array, true, 2)


func init_face_down_shuffled(char_array: Array) -> void:
	randomize()
	char_array.shuffle()
	put_char_num(char_array, false, 2)


func get_card_positions(array: Array) -> Array:
	var positions = []
	var start = -550
	var end = -start
	var num = array.size()

	for i in range(num):
		var pos = start + (end - start) / (num + 1) * (i + 1)
		positions.append(Vector2(pos, 0))
	return positions 


func put_char_num(char_array: Array, face_up: bool, char_mode: int) -> void:
	for i in range(1, full_num):
		var node_name = str("Characters/CharacterCard", i)
		var node = get_node(node_name)
		node.position = Data.FAR_AWAY

	var array_len = char_array.size()
	var positions = get_card_positions(char_array)
	for n in range(array_len):
		var char_num = char_array[n]
		var node_name = str("Characters/CharacterCard", char_num)
		var node = get_node(node_name)
		node.show()
		var animation_name = available_characters[char_num]
		var up_offset = Data.get_up_offset_char(animation_name)
		node.init_char(animation_name, char_num, up_offset, Data.CHAR_BANNED, positions[n] + $Characters.global_position, face_up, char_mode)


func wait(mode: int, remove: int, info: Array = []) -> void:
	var note
	var once
	var alls
	var char_array
	match mode:
		Data.EmploymentState.HIDING:
			note = "NOTE_HIDE"
			once = "sgin_hidden_once_finished"
			alls = "sgin_hidden_all_finished"
		Data.EmploymentState.DISCARDING:
			note = "NOTE_DISCARD"
			once = "sgin_discarded_once_finished"
			alls = "sgin_discarded_all_finished"
		Data.EmploymentState.SELECTING:
			note = "NOTE_SELECT"
			once = "sgin_selected_char_once_finished"
			alls = "sgin_selected_char_all_finished"
		Data.EmploymentState.ASSASSINATING:
			note = "NOTE_ASSASSIN"
			once = "sgin_assassin_once_finished"
			alls = "sgin_assassin_all_finished"
		Data.EmploymentState.STEALING:
			note = "NOTE_THIEF"
			once = "sgin_thief_once_finished"
			alls = "sgin_thief_all_finished"

	for _i in range(remove):
		show()
		if mode == Data.EmploymentState.ASSASSINATING:
			char_array = info
			init_face_up_ordered(char_array)
		elif mode == Data.EmploymentState.STEALING:
			char_array = info
			init_face_up_ordered(char_array)
		elif mode == Data.EmploymentState.SELECTING:
			char_array = get_selectable_characters(true)
			init_face_up_ordered(char_array)
		else:
			char_array = get_selectable_characters(false)
			init_face_down_shuffled(char_array)
		state = mode
		Signal.emit_signal("sgin_set_reminder", note)
		yield(Signal, once)
		Signal.emit_signal("sgin_set_reminder", "")
		hide()
	Signal.emit_signal(alls)


func wait_assassin(info: Array) -> void:
	wait(Data.EmploymentState.ASSASSINATING, 1, info)


func wait_thief(info: Array) -> void:
	wait(Data.EmploymentState.STEALING, 1, info)


func wait_discard(up_remove: int) -> void:
	wait(Data.EmploymentState.DISCARDING, up_remove)


func wait_hide(down_remove: int) -> void:
	wait(Data.EmploymentState.HIDING, down_remove)


func wait_select() -> void:
	wait(Data.EmploymentState.SELECTING, 1)


func move_char_to(mode: int, char_num: int) -> void:
	var list
	var function
	var fini
	var useless = []
	var rm
	if mode == Data.EmploymentState.HIDING:
		list = hidden
		function = "character_to_hidden"
		fini = "sgin_hidden_once_finished"
		rm = available
	elif mode == Data.EmploymentState.DISCARDING:
		list = discarded
		function = "character_to_discarded"
		fini = "sgin_discarded_once_finished"
		rm = available
	elif mode == Data.EmploymentState.SELECTING:
		list = useless
		function = "character_to_selected"
		fini = "sgin_selected_char_once_finished"
		rm = available
	if not list.has(char_num):
		list.append(char_num)
	if rm.has(char_num):
		rm.erase(char_num)
		var char_card = get_node(str("Characters/CharacterCard", char_num))
		call(function, char_card.char_name, char_card.global_position)
		yield(Signal, fini)


func move_char_to_discarded(char_num: int) -> void:
	move_char_to(Data.EmploymentState.DISCARDING, char_num)


func move_char_to_hidden(char_num: int) -> void:
	move_char_to(Data.EmploymentState.HIDING, char_num)


func move_char_to_selected(char_num: int) -> void:
	move_char_to(Data.EmploymentState.SELECTING, char_num)


func on_char_clicked(char_num: int) -> void:
	match state:
		Data.EmploymentState.IDLE:
			pass
		Data.EmploymentState.DISCARDING:
			move_char_to_discarded(char_num)
		Data.EmploymentState.HIDING:
			move_char_to_hidden(char_num)
		Data.EmploymentState.SELECTING:
			move_char_to_selected(char_num)
		Data.EmploymentState.ASSASSINATING:
			Signal.emit_signal("sgin_assassin_once_finished", char_num, available_characters[char_num])
		Data.EmploymentState.STEALING:
			Signal.emit_signal("sgin_thief_once_finished", char_num, available_characters[char_num])

	state = Data.EmploymentState.IDLE


func reset_discard_hidden():
	for c in $DiscardedHidden/Discarded.get_children():
		$DiscardedHidden/Discarded.remove_child(c)
		c.queue_free()
	for c in $DiscardedHidden/Hidden.get_children():
		$DiscardedHidden/Hidden.remove_child(c)
		c.queue_free()
	for c in $DiscardedHidden/Selected.get_children():
		$DiscardedHidden/Selected.remove_child(c)
		c.queue_free()
