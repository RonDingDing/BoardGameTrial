extends Node2D

onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var available_characters = {
	1: "Assassin",
	2: "Thief",
	3: "Wizard",
	4: "King",
	5: "Bishop",
	6: "Merchant",
	7: "Architect",
	8: "Warlord",
	9: "Queen"
}
onready var nine_chars = true
onready var full_num = 10 if nine_chars else 9
onready var available = available_characters.keys()
onready var discarded = []
onready var hidden = []
enum State { IDLE, DISCARDING, HIDING, SELECTING }
onready var state = State.IDLE
onready var discarded_hidden_position = Vector2(-9999, -9999)

#func _ready():
#	set_global_position(Vector2(720, 540))


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


func init_face_up_ordered() -> void:
	var char_array = get_selectable_characters(true)
	put_char_num(char_array, true, true)


func init_face_down_shuffled() -> void:
	var char_array = get_selectable_characters(false)
	randomize()
	char_array.shuffle()
	put_char_num(char_array, false, false)


func get_card_positions(array: Array) -> Array:
	var positions = []
	var start = -550
	var end = -start
	var num = array.size()

	for i in range(num):
		var pos = start + (end - start) / (num + 1) * (i + 1)
		positions.append(Vector2(pos, 0))
	return positions


func put_char_num(char_array: Array, face_up: bool, enlargeable: bool) -> void:
	for i in range(1, full_num):
		var node_name = str("Characters/CharacterCard", i)
		var node = get_node(node_name)
		node.position = Vector2(-99999, -99999)

	var array_len = char_array.size()
	var positions = get_card_positions(char_array)
	for n in range(array_len):
		var char_num = char_array[n]
		var node_name = str("Characters/CharacterCard", char_num)
		var node = get_node(node_name)
		node.show()
		var animation_name = available_characters[char_num]
		var up_offset = Data.get_up_offset_char(animation_name)
		node.init_char(
			animation_name, char_num, up_offset, Vector2(0.13, 0.13), positions[n], face_up
		)
		node.set_enlargeable(enlargeable)


func wait(mode: int, remove: int) -> void:
	var note
	var once
	var alls

	if mode == State.HIDING:
		note = "NOTE_HIDE"
		once = "sgin_hidden_once_finished"
		alls = "sgin_hidden_all_finished"
	elif mode == State.DISCARDING:
		note = "NOTE_DISCARD"
		once = "sgin_discarded_once_finished"
		alls = "sgin_discarded_all_finished"
	else:
		note = "NOTE_SELECT"
		once = "sgin_selected_char_once_finished"
		alls = "sgin_selected_char_all_finished"

	for _i in range(remove):
		show()
		if mode == State.SELECTING:
			init_face_up_ordered()
		else:
			init_face_down_shuffled()
		state = mode
		Signal.emit_signal("sgin_set_reminder", note)
		yield(Signal, once)
		Signal.emit_signal("sgin_set_reminder", "")
		hide()
	Signal.emit_signal(alls)


func wait_discard(up_remove: int) -> void:
	wait(State.DISCARDING, up_remove)


func wait_hide(down_remove: int) -> void:
	wait(State.HIDING, down_remove)


func wait_select() -> void:
	wait(State.SELECTING, 1)


func move_char_to(mode: int, char_num) -> void:
	var list
	var emite
	var fini
	var useless = []
	if mode == State.HIDING:
		list = hidden
		emite = "sgin_move_char_to_hidden"
		fini = "sgin_hidden_once_finished"
	elif mode == State.DISCARDING:
		list = discarded
		emite = "sgin_move_char_to_discarded"
		fini = "sgin_discarded_once_finished"
	else:
		list = useless
		emite = "sgin_move_char_to_selected"
		fini = "sgin_selected_char_once_finished"

	if not list.has(char_num):
		list.append(char_num)
	if available.has(char_num):
		available.erase(char_num)
		var char_card = get_node(str("Characters/CharacterCard", char_num))
		var char_info = char_card.get_char_info()
		Signal.emit_signal(emite, char_info)
		yield(Signal, fini)


func move_char_to_discarded(char_num: int) -> void:
	move_char_to(State.DISCARDING, char_num)


func move_char_to_hidden(char_num: int) -> void:
	move_char_to(State.HIDING, char_num)


func move_char_to_selected(char_num: int) -> void:
	move_char_to(State.SELECTING, char_num)


func on_char_clicked(char_num: int) -> void:
	match state:
		State.IDLE:
			pass
		State.DISCARDING:
			move_char_to_discarded(char_num)
		State.HIDING:
			move_char_to_hidden(char_num)
		State.SELECTING:
			move_char_to_selected(char_num)
