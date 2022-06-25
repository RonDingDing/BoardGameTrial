extends Node2D

onready var first_person_num = 0
onready var opponent_length = 6
onready var deck_position = $Deck.position
onready var bank_position = $Bank.position
onready var discarded_hidden_position = $Employment/DiscardedHidden.position
onready var lang = "zh_CN"
onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var TweenMove = get_node("/root/Main/Tween")
onready var TimerGlobal = get_node("/root/Main/Timer")
onready var started = false
const Crown = preload("res://Crown.tscn")
const Money = preload("res://Money.tscn")
enum Phase { CHARACTER_SELECTION, RESOURCE, TURN, END, GAME_OVER }
enum Need { GOLD, CARD }
enum FindPlayerObjBy { EMPLOYEE, EMPLOYEE_NUM, PLAYER_NUM, CROWN, RELATIVE_TO_FIRST_PERSON }
const deck_num = -1
const bank_num = -2
const unfound = -3


func select_obj_by_relative_to_first_person(relative_to_me: int) -> Node:
	return select_player_obj_by(FindPlayerObjBy.RELATIVE_TO_FIRST_PERSON, relative_to_me)


func select_obj_by_player_num(player_num: int) -> Node:
	return select_player_obj_by(FindPlayerObjBy.PLAYER_NUM, player_num)


func select_obj_by_employee(employee_name: String) -> Node:
	return select_player_obj_by(FindPlayerObjBy.EMPLOYEE, employee_name)


func find_employee_4_pnum() -> int:
	var employee_4 = select_player_obj_by(FindPlayerObjBy.EMPLOYEE_NUM, 4)
	if employee_4 == null:
		return $Player.player_num
	return employee_4.player_num


func find_crown_pnum() -> int:
	var crown_player = select_player_obj_by(FindPlayerObjBy.CROWN, 0)
	if crown_player == null:
		return $Player.player_num
	return crown_player.player_num


func select_player_obj_by(find_mode: int, clue) -> Node:
	var player_obj

	for n in range(-2, opponent_length + 1):
		if n == 0:
			player_obj = $Player
		elif n == bank_num:
			player_obj = $Bank
		elif n == deck_num:
			player_obj = $Deck
		else:
			player_obj = get_node(str("Opponent", n))

		if find_mode == FindPlayerObjBy.EMPLOYEE and player_obj.employee == clue:
			return player_obj
		elif (
			find_mode == FindPlayerObjBy.EMPLOYEE_NUM
			and player_obj.employee == $Employment.find_by_num(clue)
		):
			return player_obj
		elif find_mode == FindPlayerObjBy.CROWN and player_obj.has_crown:
			return player_obj
		elif find_mode == FindPlayerObjBy.PLAYER_NUM and player_obj.player_num == clue:
			return player_obj
		elif find_mode == FindPlayerObjBy.RELATIVE_TO_FIRST_PERSON and n == clue:
			return player_obj
	return null


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
	on_sgin_set_reminder("")
	$Employment.set_char_pos($Player/Employee.global_position)
	to_be_delete()


	

func show_player() -> void:
	$OpponentPath2D/PathFollow2D.unit_offset = 0
	for i in range(opponent_length):
		$OpponentPath2D/PathFollow2D.unit_offset += 1 / float(opponent_length + 1)
		var node = get_node(str("Opponent", i + 1))
		node.position = $OpponentPath2D/PathFollow2D.position


func on_sgin_draw_card(player_num: int, face_is_up: bool, from_pos: Vector2 = deck_position):
	if from_pos == null:
		from_pos = deck_position
	var card_name = $Deck.pop()
	var player_obj = select_obj_by_player_num(player_num)
	player_obj.draw(card_name, face_is_up, from_pos, 1)


func start_game():
	# 洗牌
	$Deck.shuffle()
	deal_cards()


func deal_cards():
	var all_player_length = opponent_length + 1
	# 每个玩家派4张牌
	for _i in range(4):
		for p_num in range(all_player_length):
			TimerGlobal.set_wait_time(0.1)
			TimerGlobal.start()
			yield(TimerGlobal, "timeout")
			on_sgin_draw_card(p_num, false)
	for _i in range(4):
		for p_num in range(all_player_length):
			if p_num == $Player.player_num:
				yield(Signal, "sgin_player_draw_ready")
			else:
				yield(Signal, "sgin_opponent_draw_ready")
	Signal.emit_signal("sgin_card_dealt", all_player_length)


func on_sgin_card_dealt(all_player_length: int) -> void:
	for _i in range(2):
		for p_num in range(all_player_length):
			TimerGlobal.set_wait_time(0.1)
			TimerGlobal.start()
			yield(TimerGlobal, "timeout")
			var done_signal = (
				"sgin_player_gold_ready"
				if p_num == $Player.player_num
				else "sgin_opponent_gold_ready"
			)
			on_sgin_gold_transfer(bank_num, p_num, done_signal)
	yield(TweenMove, "tween_all_completed")
	Signal.emit_signal("sgin_ready_game")


func first_player() -> int:
	var player_num = randi() % (opponent_length + 1)
	return player_num


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


func get_all_players_info_relative() -> Array:
	var info_array = []
	for i in range(opponent_length + 1):
		var player_obj = select_obj_by_relative_to_first_person(i)
		var info = player_obj.get_my_player_info()
		info_array.append(info)
	return info_array


func get_reseat_info(info_array: Array, original_first_player: int, current_first_player) -> Array:
	var seat = (
		current_first_player - original_first_player
		if current_first_player >= original_first_player
		else opponent_length + 1 - original_first_player + current_first_player
	)

	return info_array.slice(seat, info_array.size()) + info_array.slice(0, seat - 1)


func send_all_player_info(reseated_info: Array) -> void:
	for i in range(opponent_length + 1):
		var player_obj = select_obj_by_relative_to_first_person(i)
		player_obj.on_player_info(reseated_info[i])


func reseat(orginal_first_player: int, current_first_player: int) -> void:
	var info_array = get_all_players_info_relative()
	if current_first_player == $Player.player_num:
		send_all_player_info(info_array)
		return

	var reseated_info = get_reseat_info(info_array, orginal_first_player, current_first_player)
	send_all_player_info(reseated_info)


func set_first_person_num(num: int) -> void:
	first_person_num = num
	$Skill.set_first_person_num(num)

func hand_over_control(player_num: int) -> void:
	var player_obj = select_obj_by_player_num(player_num)
	var player_name = player_obj.username
	var orginal_first_player = first_person_num
	var current_first_player = player_obj.player_num
	set_first_person_num(player_obj.player_num)
	Signal.emit_signal("hand_over", player_name)
	reseat(orginal_first_player, current_first_player)
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
	$Player.set_script_mode($Player.ScriptMode.RESOURCE)
	$Player.show_scripts()


func mask_turn() -> void:
	Signal.emit_signal("phase", "PHASE_TURN_START")
	hide()


func mask_character_selection() -> void:
	Signal.emit_signal("phase", "PHASE_CHARACTER_SELECTION")
	hide()
	$Employment/DiscardedHidden.show()


func on_sgin_ready_game() -> void:
	var player_num = first_player()
	var player_obj = select_obj_by_player_num(player_num)
	player_obj.set_crown(true)
	character_selection(player_num)


func character_selection(player_num: int) -> void:
	phase(Phase.CHARACTER_SELECTION)
	yield(Signal, "uncover")
	show()
	hand_over_control(player_num)
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
		}
	]
	for i in range(data.size()):
		var d = data[i]
		var node = select_obj_by_relative_to_first_person(i)
		node.on_player_info(d)


func on_sgin_char_selected(char_num: int) -> void:
	$Employment.on_char_clicked(char_num)


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
	var hidden_has_char = $Employment/DiscardedHidden/Hidden.store
	var hidden_char_obj = $Employment/DiscardedHidden/Hidden.get_child(0)

	if is_7_players and last_player_selecting and hidden_has_char:
		var char_info = hidden_has_char.pop_back()
		$Employment.add_employee(char_info["char_num"])
		$Employment/DiscardedHidden/Hidden.remove_child(hidden_char_obj)
		hidden_char_obj.queue_free()


func get_next_x_player_num(x: int = 1) -> int:
	var next_x_num = $Player.player_num + x
	if next_x_num > opponent_length:
		print("next " + str(x) + " num: ", next_x_num - opponent_length - 1)
		return next_x_num - opponent_length - 1
	print("next " + str(x) + " num: ", next_x_num)
	return next_x_num


func on_sgin_character_selection() -> void:
	for i in range(opponent_length + 1):
		handle_last_player_who_select(i)
		$Employment.wait_select()
		yield(Signal, "sgin_selected_char_once_finished")
		# 交给下一位玩家
		if i < opponent_length:
			var next_player_num = get_next_x_player_num(1)
			hand_over_control(next_player_num)
			yield(Signal, "uncover")
			show()
	Signal.emit_signal("sgin_start_turn")


class Params:
	var employ_global_pos: Vector2 = Vector2(0, 0)
	var scaling: Vector2 = Vector2(0, 0)

	func _init(global_pos: Vector2, scalings: Vector2) -> void:
		employ_global_pos = global_pos
		scaling = scalings


func make_params(player_obj: Node, employee_num: int, employee_name: String) -> Params:
	var employ_global_pos
	var scaling
	if player_obj == null or $Skill.is_assassinated(employee_num, employee_name):
		employ_global_pos = get_viewport_rect().size / 2
		scaling = Vector2(0, 0)
	else:
		employ_global_pos = player_obj.get_node("Employee").global_position
		if player_obj.player_num == first_person_num:
			scaling = Vector2(0.04, 0.04)
		else:
			scaling = Vector2(0.02, 0.02)
	var params = Params.new(employ_global_pos, scaling)
	return params


func on_start_turn() -> void:
	mask_turn()
	yield(Signal, "uncover")
	show()
	for employee_num in range(1, $Employment.full_num):
		# 播放动画，显示大牌，然后移动到相应的雇佣区去
		var employee_name = $Employment.find_by_num(employee_num)
		var player_obj = select_obj_by_employee(employee_name)
		var param = make_params(player_obj, employee_num, employee_name)
		$AnyCardEnlarge.char_enter(employee_name, param.scaling, param.employ_global_pos)
		yield(Signal, "sgin_char_entered")

		var should_continue = $Skill.check_continue(employee_num, employee_name, player_obj == null)
		if should_continue:
			continue
		player_obj.show_employee()
		hand_over_control(player_obj.player_num)
		yield(Signal, "uncover")
		show()

		print("start turn: ")
		for n in range(opponent_length + 1):
			var player_objs = select_obj_by_relative_to_first_person(n)
			print(
				player_objs.username,
				" ",
				player_objs.hands,
				" ",
				player_objs.built,
				" ",
				player_objs.employee,
				" ",
				player_objs.gold
			)
		print()

		var wait_signal = $Skill.check_reveal(employee_num, employee_name, player_obj.player_num)
		if wait_signal:
			yield(Signal, wait_signal)

		$Player.set_all_activated_this_turn(false)
		$Player.reset_script_color()
		phase(Phase.RESOURCE)

		$Player.disable_play()
		yield(Signal, "sgin_resource_need")
		$Player.hide_scripts()
		yield(Signal, "sgin_resource_end")

		Signal.emit_signal("sgin_set_reminder", "NOTE_PLAY")
		$Player.enable_play()

		$Player.show_end_turn()
		yield(Signal, "sgin_end_turn")
		$Player.hide_end_turn()
		$Player.after_end_turn()
		print("end turn: ")
		for n in range(opponent_length + 1):
			var player_objs = select_obj_by_relative_to_first_person(n)
			print(
				player_objs.username,
				" ",
				player_objs.hands,
				" ",
				player_objs.built,
				" ",
				player_objs.employee,
				" ",
				player_objs.gold
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
		TimerGlobal.set_wait_time(0.1)
		TimerGlobal.start()
		yield(TimerGlobal, "timeout")
		var done_signal = "sgin_player_gold_ready"
		on_sgin_gold_transfer(bank_num, $Player.player_num, done_signal)
		yield(Signal, done_signal)
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
		yield(Signal, "sgin_player_draw_ready")
		to_select.erase(sig[0])  #.card_name

	$Deck.extend(to_select)
	Signal.emit_signal("sgin_resource_end")


func on_sgin_card_selected(card_name: String, from_pos: Vector2) -> void:
	$Player.draw(card_name, true, from_pos, 1)
	$AnyCardEnlarge.reset_cards()


func on_sgin_card_played(card_name: String, from_pos: Vector2) -> void:
	if $Player.can_end:
		var card_info = Data.get_card_info(card_name)
		var price = card_info["star"]
		var enough_money = $Player.has_enough_money(price)
		var not_played_same = $Player.has_not_played_same(card_name)
		var not_ever_played = (
			$Skill.has_ever_played($Player.employee, $Player.played_this_turn)
			or $Player.has_ever_played()
		)
		if not (enough_money and not_played_same and not_ever_played):
			return
		$Player.disable_play()
		var success_play = $Player.card_played(card_name, price, from_pos)
		if success_play:
			yield(Signal, "sgin_card_played_finished")
		$Player.enable_play()


func is_game_over() -> bool:
	var game_over = false
	for p in range(opponent_length + 1):
		var player_obj = select_obj_by_player_num(p)
		if player_obj.can_end_game():
			game_over = true
	return game_over


func on_sgin_one_round_finished() -> void:
	if not is_game_over():
		var crown_player_num = find_employee_4_pnum()
		$Employment.reset_available()
		character_reset()
		character_selection(crown_player_num)
	else:
		game_over()


func character_reset() -> void:
	for i in range(opponent_length + 1):
		var player_obj = select_obj_by_player_num(i)
		player_obj.set_employee("Unchosen")


func game_over() -> void:
	pass


func on_sgin_assassin_wait() -> void:
	$Employment.hide_discard_hidden()
	$Player.disable_play()
	$Employment.wait_assassin()


func on_sgin_assassin_once_finished(char_num: int, char_name: String) -> void:
	Signal.emit_signal("sgin_set_reminder", "NOTE_PLAY")
	$Skill.assassinate(char_num, char_name)
	$AnyCardEnlarge.assassinate(char_name)
	yield(TweenMove, "tween_all_completed")
	$Player.set_assassinated(char_name)
	$Player.enable_play()


func on_sgin_thief_once_finished(char_num: int, char_name: String) -> void:
	Signal.emit_signal("sgin_set_reminder", "NOTE_PLAY")
	$Skill.steal(char_num, char_name)
	$AnyCardEnlarge.steal(char_name)
	yield(TweenMove, "tween_all_completed")
	$Player.set_stolen(char_name)
	$Player.enable_play()


func on_sgin_thief_wait():
	$Employment.hide_discard_hidden()
	$Player.disable_play()
	$Employment.wait_thief()


func on_sgin_thief_stolen():
	$Player.disable_play()
	var thief_obj = select_player_obj_by(FindPlayerObjBy.EMPLOYEE, "Thief")
	for _i in range($Player.gold):
		on_sgin_gold_transfer($Player.player_num, thief_obj.player_num, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")
	$Player.enable_play()
	Signal.emit_signal("sgin_thief_done")


func on_sgin_magician_wait():
	$Employment.hide_discard_hidden()
	$Player.disable_play()
	$Player.wait_magician()


func on_sgin_merchant_wait():
	$Employment.hide_discard_hidden()
	$Player.disable_play()
	$Player.wait_merchant()


func magician_select_deck() -> void:
	for c in $Player/HandScript.get_children():
		TweenMove.animate(
			[
				[c, "global_position", c.global_position, deck_position, 1],
			]
		)
		TimerGlobal.set_wait_time(0.1)
		TimerGlobal.start()
		yield(TimerGlobal, "timeout")
	yield(TweenMove, "tween_all_completed")

	$Player.shuffle_hands()
	var temp = $Player.hands
	$Player.clear_hands()
	$Deck.extend(temp)
	for _i in temp.size():
		TimerGlobal.set_wait_time(0.1)
		TimerGlobal.start()
		yield(TimerGlobal, "timeout")
		on_sgin_draw_card($Player.player_num, true)
	yield(TweenMove, "tween_all_completed")
	Signal.emit_signal("sgin_set_reminder", "NOTE_PLAY")
	$Player.enable_play()
	$Player.hide_scripts()


func magician_select_player() -> void:
	var xrange = range(first_person_num, opponent_length + 1) + range(0,  opponent_length + 1) + range(0, first_person_num)
	for i in range(1, opponent_length + 1):
		var opponent = select_obj_by_player_num(xrange[i])
		opponent.set_opponent_state(opponent.OpponentState.MAGICIAN_CLICKABLE)

	$Player.hide_scripts()
	Signal.emit_signal("sgin_set_reminder", "NOTE_MAGICIAN_SELECT_CHARACTER")
	var player_num = yield(Signal, "sgin_magician_opponent_selected")

	for i in range(1, opponent_length + 1):
		var opponent = select_obj_by_player_num(xrange[i])
		opponent.set_opponent_state(opponent.OpponentState.IDLE)

	var switch_opponent = select_obj_by_player_num(player_num)
	var player_hands_obj = $Player/HandScript.get_children().duplicate()
	var switch_hands_name = switch_opponent.hands.duplicate()

	for card_obj in player_hands_obj:
		switch_opponent.draw(card_obj.card_name, true, card_obj.global_position, 1)
		$Player.remove_hand(card_obj)

	for _i in range(player_hands_obj.size()):
		yield(Signal, "sgin_opponent_draw_ready")

	for card_name in switch_hands_name:
		$Player.draw(
			card_name,
			true,
			switch_opponent.get_node("HandsInfo").global_position,
			1,
			Vector2(0.03, 0.03)
		)
		switch_opponent.remove_hand_name(card_name)

	for _i in range(switch_hands_name.size()):
		yield(Signal, "sgin_player_draw_ready")

	Signal.emit_signal("sgin_set_reminder", "NOTE_PLAY")
	$Player.enable_play()


func on_sgin_magician_switch(switch):
	if switch == $Player.MagicianSwitch.DECK:
		magician_select_deck()
	else:
		magician_select_player()


func on_sgin_king_move_crown() -> void:
	var crown_pnum = find_crown_pnum()
	var original_crown_owner = select_obj_by_player_num(crown_pnum)
	var from_pos = original_crown_owner.get_node("Crown").global_position

	var emoloyee_4_pnum = find_employee_4_pnum()
	var emoloyee_4 = select_obj_by_player_num(emoloyee_4_pnum)
	var to_pos = emoloyee_4.get_node("Crown").global_position

	var start_scale = (
		Vector2(0.15, 0.15)
		if crown_pnum == $Player.player_num
		else Vector2(0.07, 0.07)
	)
	var end_scale = (
		Vector2(0.15, 0.15)
		if emoloyee_4_pnum == $Player.player_num
		else Vector2(0.07, 0.07)
	)

	var crown = Crown.instance()
	crown.init(from_pos)
	$Player.add_child(crown)
	TweenMove.animate(
		[
			[
				crown,
				"global_position",
				from_pos,
				to_pos,
			],
			[
				crown,
				"scale",
				start_scale,
				end_scale,
			],
		]
	)
	yield(TweenMove, "tween_all_completed")
	original_crown_owner.set_crown(false)
	emoloyee_4.set_crown(true)
	$Player.remove_child(crown)
	Signal.emit_signal("sgin_4_done")


func on_sgin_gold_transfer(from_pnum: int, to_pnum: int, done_signal: String) -> void:
	var from_player = select_obj_by_player_num(from_pnum)
	var to_player = select_obj_by_player_num(to_pnum)
	var start_scale = Vector2(1.7, 1.7) if from_pnum == $Player.player_num else Vector2(1, 1)
	var end_scale = Vector2(1.7, 1.7) if to_pnum == $Player.player_num else Vector2(1, 1)
	var from_pos = from_player.get_node("MoneyIcon").global_position
	var to_pos = to_player.get_node("MoneyIcon").global_position
	var money = Money.instance()
	money.to_coin(start_scale, from_pos)
	$Bank.add_child(money)
	TweenMove.animate(
		[
			[
				money,
				"global_position",
				from_pos,
				to_pos,
			],
			[
				money,
				"scale",
				start_scale,
				end_scale,
			],
		]
	)
	TweenMove.start()
	from_player.add_gold(-1)
	to_player.add_gold(1)
	yield(TweenMove, "tween_all_completed")
	$Bank.remove_child(money)
	Signal.emit_signal(done_signal)


func on_sgin_set_reminder(text: String) -> void:
	if not text:
		$Player.hide_reminder()
	else:
		$Player.show_reminder()
	$Player.set_reminder_text(tr(text))


func on_sgin_ask_built_num(color: String) -> void:
	var num = $Player.built_color_num(color)
	$Skill.set_player_built_color(color, num)


func on_sgin_merchant_gold(mode: int) -> void:
	$Player.hide_scripts()
	if mode == $Player.MerchantGold.ONE:
		on_sgin_gold_transfer(bank_num, $Player.player_num, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")
	else:
		$Skill.gain_gold_by_color("green")
	$Player.enable_play()


func on_sgin_show_built(player_num: int) -> void:
	var player_obj = select_obj_by_player_num(player_num)
	if player_obj != null:
		var built = player_obj.built
		var name = player_obj.username
		$Player.show_opponent_built(name, built)

func on_sgin_hide_built() -> void:
	$Player.hide_opponent_built()


func on_input_event(viewport, event, shape_idx):
	if (
		event is InputEventMouseButton
		and event.button_index == BUTTON_LEFT
		and event.pressed
		
	):
		if not started:
			start_game()
			started = true
		$Player.hide_opponent_built()

