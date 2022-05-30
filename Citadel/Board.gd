extends Node2D

onready var first_person_num = 0
onready var opponent_length = 6
onready var deck_position = $Deck.position
onready var bank_position = $Bank.position
onready var discarded_hidden_position = $DiscardedHidden.position
onready var lang = "zh_CN"
onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var TimerGlobal = get_node("/root/Main/Timer")
onready var started = false
enum Phase { CHARACTER_SELECTION, RESOURCE, TURN, END, GAME_OVER }
enum Need { GOLD, CARD }


func _ready() -> void:
	TranslationServer.set_locale(lang)
	$Player.set_deck_position(deck_position)
	$Player.set_bank_position(bank_position)
	for i in range(1, 9):
		var opponent = get_node(str("Opponent", i))
		opponent.set_deck_position(deck_position)
		opponent.set_bank_position(bank_position)

	$Employment.set_discarded_hidden_position(discarded_hidden_position)
	show_player()
	onsgin_set_reminder("")
	$DiscardedHidden.set_char_pos($Player/Employee.global_position)
	to_be_delete()


func _input(event):
	if (
		event is InputEventMouseButton
		and event.button_index == BUTTON_LEFT
		and event.pressed
		and not started
	):
		start_game()
		started = true


func show_player() -> void:
	$OpponentPath2D/PathFollow2D.unit_offset = 0
	for i in range(opponent_length):
		$OpponentPath2D/PathFollow2D.unit_offset += 1 / float(opponent_length + 1)
		var node = get_node(str("Opponent", i + 1))
		node.position = $OpponentPath2D/PathFollow2D.position

#
#func start_game() -> void:
#	Signal.emit_signal("sgin_start_game", opponent_length + 1)


func cal_seat_num(relative_to_me: int) -> int:
	# 算出是opponent几号
	if relative_to_me >= first_person_num:
		return relative_to_me - first_person_num
	else:
		return opponent_length + 1 - first_person_num + relative_to_me


func select_obj_by_num(relative_to_me: int) -> Node:
	if relative_to_me == 0:
		return $Player
	else:
		return get_node(str("Opponent", relative_to_me))


func on_sgin_gold(relative_to_me: int, from_pos: Vector2=bank_position) -> void:
	if from_pos == null:
		from_pos = bank_position
	var player_obj = select_obj_by_num(relative_to_me)
	player_obj.on_draw_gold(from_pos)


func on_sgin_draw_card(relative_to_me: int, face_is_up: bool, from_pos: Vector2=deck_position):
	if from_pos == null:
		from_pos = deck_position	
	var card_name = $Deck.pop()
	var player_obj = select_obj_by_num(relative_to_me)
	player_obj.draw(card_name, face_is_up, from_pos, 1)


func start_game():
	# 洗牌
	$Deck.shuffle()
	deal_cards()


func deal_cards():
	var all_player_length = opponent_length + 1
	# 每个玩家派4张牌
	for _i in range(4):
		for relative_to_me in range(all_player_length):
			TimerGlobal.set_wait_time(0.1)
			TimerGlobal.start()		
			yield(TimerGlobal, "timeout")
			on_sgin_draw_card(relative_to_me, false)
	for _i in range(4):
		for relative_to_me in range(all_player_length):
			if relative_to_me == 0:
				yield(Signal, "sgin_player_draw_ready")
			else:
				yield(Signal, "sgin_opponent_draw_ready")
	Signal.emit_signal("sgin_card_dealt", all_player_length)
	
	
func on_sgin_card_dealt(all_player_length: int) -> void:
	# 每人发2个金币
	for _i in range(2):
		for relative_to_me in range(all_player_length):
			TimerGlobal.set_wait_time(0.1)
			TimerGlobal.start()		
			yield(TimerGlobal, "timeout")
			on_sgin_gold(relative_to_me, bank_position)
	for _i in range(2):
		for relative_to_me in range(all_player_length):
			if relative_to_me == 0:
				yield(Signal, "sgin_player_gold_ready")
			else:
				yield(Signal, "sgin_opponent_gold_ready")
	Signal.emit_signal("sgin_ready_game")





func first_player() -> int:
	var seat_num = randi() % (opponent_length + 1)
	return seat_num


func character_phase_remove() -> Array:
	match opponent_length + 1:
		4:
			return [2, 1, 0]
		5:
			return [1, 1, 0]
		6:
			return [0, 1, 0]
		7:
			return [0, 1, 1]
		_:
			return [2, 1, 0]


func get_all_players_info() -> Array:
	var info_array = []
	for i in range(opponent_length + 1):
		var player_obj = select_obj_by_num(i)
		var info = player_obj.get_my_player_info()
		info_array.append(info)
	return info_array


func get_reseat_info(info_array: Array, relative_seat: int) -> Array:
	return (
		info_array.slice(relative_seat, info_array.size())
		+ info_array.slice(0, relative_seat - 1)
	)


func cal_relative_to_me(seat_num: int) -> int:
	if seat_num >= first_person_num:
		return seat_num - first_person_num
	else:
		return opponent_length + 1 - first_person_num + seat_num


func send_all_player_info(reseated_info: Array) -> void:
	for i in range(opponent_length + 1):
		var player_obj = select_obj_by_num(i)
		player_obj.on_player_info(reseated_info[i])


func reseat(relative_to_me: int) -> void:
	# 座位从0开始，0是自己，先获取所有的player_info
	var info_array = get_all_players_info()
	if relative_to_me == 0:
		send_all_player_info(info_array)
		return
	# 将主视角交给座位号为 relative_to_me 的玩家，也就是 opponentN，即将原数组向左移动N
	var e = []
	for f in info_array:
		var s = f.get("hands", [])
		var p = []
		for m in s:
			p.append(m)
		e.append(p)

	var reseated_info = get_reseat_info(info_array, relative_to_me)
	send_all_player_info(reseated_info)


func hand_over_control(relative_to_me: int) -> void:
	var player_obj = select_obj_by_num(relative_to_me)
	var player_name = player_obj.username
	first_person_num = player_obj.player_num
	Signal.emit_signal("hand_over", player_name)
	reseat(relative_to_me)
	hide()


func phase(phase_string: int) -> void:
	match phase_string:
		Phase.CHARACTER_SELECTION:
			mask_character_selection()

		Phase.TURN:
			mask_turn()

		Phase.RESOURCE:
			resource()


func resource():
	Signal.emit_signal("sgin_set_reminder", "NOTE_CHOOSE_RESOURCE")
	$ButtonScript.show_resource()


func mask_turn() -> void:
	Signal.emit_signal("phase", "PHASE_TURN_START")
	hide()


func mask_character_selection() -> void:
	Signal.emit_signal("phase", "PHASE_CHARACTER_SELECTION")
	hide()


func on_sgin_ready_game() -> void:
	var relative_to_me = first_player()
	var player_obj = select_obj_by_num(relative_to_me)
	player_obj.set_crown(true)
	character_selection(relative_to_me)


func character_selection(relative_to_me: int) -> void:
	phase(Phase.CHARACTER_SELECTION)
	yield(Signal, "uncover")
	show()
	hand_over_control(relative_to_me)
	yield(Signal, "uncover")
	show()
	var remove_data = character_phase_remove()
	$Employment.wait_discard(remove_data[0])
	if remove_data[0] > 0:
		yield(Signal, "sgin_discarded_all_finished")
	$Employment.wait_hide(remove_data[1])
	if remove_data[1] > 0:
		yield(Signal, "sgin_hidden_all_finished")
	Signal.emit_signal("sgin_character_selection")


# Data : {"player_num": 1, "username": "username", "money": 0, "employee": "unknown", "hand": ["<������>"], "built": ["<������>"]}


#
func to_be_delete():
	var data = [
		{
			"player_num": 0,
			"username": "zero",
			#			"money": 9,
			#			"employee": "Architect",
			#			"hand_num": 8,
			#			"built": ["Market", "Apothery"]
		},
		{
			"player_num": 1,
			"username": "one",
			#			"money": 9,
			#			"employee": "Architect",
			#			"hand_num": 8,
			#			"built": ["Market", "Apothery"]
		},
		{
			"player_num": 2,
			"username": "two",
			#			"money": 3,
			#			"employee": "Wizard",
			#			"hand_num": 2,
			#			"built": ["Market", "Dragon House"]
		},
		{
			"player_num": 3,
			"username": "three",
			#			"money": 2,
			#			"employee": "King",
			#			"hand_num": 3,
			#			"built": ["Market", "Dragon House"]
		},
		{
			"player_num": 4,
			"username": "four",
			#			"money": 4,
			#			"employee": "Merchant",
			#			"hand_num": 4,
			#			"built": ["Market", "Dragon House"]
		},
		{
			"player_num": 5,
			"username": "five",
			#			"money": 5,
			#			"employee": "Warlord",
			#			"hand_num": 6,
			#			"built": ["Market", "Dragon House"]
		},
		{
			"player_num": 6,
			"username": "six",
			#			"money": 6,
			#			"employee": "Wizard",
			#			"hand_num": 6,
			#			"built": ["Market", "Dragon House"]
		},
		{
			"player_num": 7,
			"username": "seven",
			#			"money": 7,
			#			"employee": "Thief",
			#			"hand_num": 2,
			#			"built": ["Market", "Dragon House"]
		},
	]
	for i in range(data.size()):
		var d = data[i]
		var node = select_obj_by_num(i)
		node.on_player_info(d)


func onsgin_set_reminder(text: String) -> void:
	if not text:
		$Reminder.hide()
	else:
		$Reminder.show()
	$Reminder/Text.set_text(tr(text))


func on_sgin_char_selected(char_num: int) -> void:
	$Employment.on_char_clicked(char_num)


func on_sgin_move_char_to_discarded(char_name: String, from_pos: Vector2) -> void:
	$DiscardedHidden.move_char_to_discarded(char_name, from_pos)


func on_sgin_move_char_to_hidden(char_name: String, from_pos: Vector2) -> void:
	$DiscardedHidden.move_char_to_hidden(char_name, from_pos)


func on_sgin_move_char_to_selected(char_name: String, from_pos) -> void:
	$DiscardedHidden.move_char_to_selected(char_name, from_pos)


func on_sgin_card_focused(card_name: String) -> void:
	$AnyCardEnlarge.on_sgin_card_focused(card_name)


func on_sgin_char_focused(char_name: String) -> void:
	$AnyCardEnlarge.on_sgin_char_focused(char_name)


func on_sgin_card_unfocused(card_name: String) -> void:
	$AnyCardEnlarge.on_sgin_card_unfocused(card_name)


func on_sgin_char_unfocused(char_name: String) -> void:
	$AnyCardEnlarge.on_sgin_char_unfocused(char_name)


func handle_last_player_who_select(i: int) -> void:
	var is_7_players = opponent_length + 1 == 7
	var last_player_selecting = i == 6
	var hidden_has_char = $DiscardedHidden/Hidden.store
	var hidden_char_obj = $DiscardedHidden/Hidden.get_child(0)

	if is_7_players and last_player_selecting and hidden_has_char:
		var char_info = hidden_has_char.pop_back()
		$Employment.add_employee(char_info["char_num"])
		$DiscardedHidden/Hidden.remove_child(hidden_char_obj)
		hidden_char_obj.queue_free()


func on_sgin_character_selection() -> void:
	for i in range(opponent_length + 1):
		handle_last_player_who_select(i)
		$Employment.wait_select()
		yield(Signal, "sgin_selected_char_once_finished")
		# 交给下一位玩家
		if i < opponent_length:
			hand_over_control(1)
			yield(Signal, "uncover")
			show()
	Signal.emit_signal("sgin_start_turn")


func select_obj_by_employee(employee_name: String):
	for i in range(opponent_length + 1):
		var obj = select_obj_by_num(i)
		if obj.employee == employee_name:
			return obj


func is_disabled(_employee_name: String) -> bool:
	return false


class Params:
	var should_continue: bool = false
	var employ_global_pos: Vector2 = Vector2(0, 0)
	var scaling: Vector2 = Vector2(0, 0)

	func _init(global_pos: Vector2, is_continue: bool, scalings: Vector2) -> void:
		employ_global_pos = global_pos
		should_continue = is_continue
		scaling = scalings


func make_params(player_obj: Node, employee_name: String) -> Params:
	var employ_global_pos
	var should_continue
	var scaling
	if player_obj == null or is_disabled(employee_name):
		should_continue = true
		employ_global_pos = get_viewport_rect().size / 2
		scaling = Vector2(0, 0)
	else:
		should_continue = false
		employ_global_pos = player_obj.get_node("Employee").global_position
		if player_obj.player_num == first_person_num:
			scaling = Vector2(0.04, 0.04)
		else:
			scaling = Vector2(0.02, 0.02)
	var params = Params.new(employ_global_pos, should_continue, scaling)
	return params


func on_start_turn() -> void:
	mask_turn()
	yield(Signal, "uncover")
	show()
	for num in range(1, $Employment.full_num):
		# 播放动画，显示大牌，然后移动到相应的雇佣区去
		var employee_name = $Employment.available_characters[num]
		var player_obj = select_obj_by_employee(employee_name)
		var param = make_params(player_obj, employee_name)
		$AnyCardEnlarge.char_enter(employee_name, param.scaling, param.employ_global_pos)
		if player_obj != null:
			yield(Signal, "sgin_char_entered")
			player_obj.show_employee()
		if param.should_continue:
			continue

		var relative_to_me = cal_relative_to_me(player_obj.player_num)
		hand_over_control(relative_to_me)
		yield(Signal, "uncover")
		show()

		phase(Phase.RESOURCE)
		yield(Signal, "sgin_resource_need")
		$ButtonScript.hide_resource()
		yield(Signal, "sgin_resource_end")

		Signal.emit_signal("sgin_set_reminder", "NOTE_PLAY")
		$Player.enable_play()

		$ButtonScript.show_end_turn()
		yield(Signal, "sgin_end_turn")
		$ButtonScript.hide_end_turn()
		$Player.after_end_turn()
		for n in range(opponent_length + 1):
			var player_objs = select_obj_by_num(n)
			print(
				player_objs.username,
				" ",
				player_objs.hands,
				" ",
				player_objs.built,
				" ",
				player_objs.employee
			)
		print()

	Signal.emit_signal("sgin_one_round_finished")


func on_sgin_selected_char_once_finished(char_name: String) -> void:
	$Player.set_employee(char_name)


func on_sgin_resource_need(what: int) -> void:
	match what:
		Need.GOLD:
			gain_gold()
		Need.CARD:
			gain_card()


func gain_gold() -> void:
	var gold_to_gain = 2
	for _i in range(gold_to_gain):
		on_sgin_gold(0, bank_position)
		yield(Signal, "sgin_player_gold_ready")
	Signal.emit_signal("sgin_resource_end")


func gain_card() -> void:
	var card_to_gain = 2
	var card_to_click = 1
	var to_select = []
	for _i in range(card_to_gain):
		to_select.append($Deck.pop())
	$AnyCardEnlarge.selectable_cards(to_select)
	for _i in range(card_to_click):
		var sig = yield(Signal, "sgin_card_selected")
		to_select.erase(sig[0])  #.card_name

	$Deck.extend(to_select)
	Signal.emit_signal("sgin_resource_end")


func on_sgin_card_selected(card_name: String, from_pos: Vector2) -> void:
	$Player.draw(card_name, true, from_pos, 1)
	$AnyCardEnlarge.reset_cards()


func on_sgin_card_played(card_name: String, from_pos: Vector2) -> void:
	$Player.on_sgin_card_played(card_name, from_pos)


func is_game_over() -> bool:
	var game_over = false
	for p in range(opponent_length + 1):
		var player_obj = select_obj_by_num(p)
		if player_obj.can_end_game():
			game_over = true
	return game_over


func find_crown_player() -> int:
	for i in range(opponent_length + 1):
		var player_obj = select_obj_by_num(i)
		if player_obj.has_crown:
			return i
	return 0


func on_sgin_one_round_finished() -> void:
	if not is_game_over():
		var crown_player_relative_to_me = find_crown_player()
		$Employment.reset_available()
		character_reset()
		character_selection(crown_player_relative_to_me)
	else:
		game_over()


func character_reset() -> void:
	for i in range(opponent_length + 1):
		var player_obj = select_obj_by_num(i)
		player_obj.set_employee("Unchosen")


func game_over():
	pass



func on_sgin_assassin_wait():
	$ButtonScript.set_can_end(false)
	$Employment.wait_assassin()
