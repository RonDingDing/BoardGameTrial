extends Node2D

onready var current_turn_num = 1
onready var first_person_num = 0
onready var opponent_length = 3#6
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
onready var center = get_viewport_rect().size / 2

#Game
onready var city_finished = []


#Skill
onready var stolen = [unfound, "Unchosen"]
onready var assassinated = [unfound, "Unchosen"]
onready var destroyed = [unfound, "Unchosen"]


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
	$Employment.set_char_pos($Player.get_employee_global_position())
	to_be_delete()


# Data : {"player_num": 1, "username": "username", "money": 0, "employee": "unknown", "hand": ["<������>"], "built": ["<������>"]}


#
func to_be_delete():
	var data = [
		{
			"player_num": 0,
			"username": "zero",
			"money": 9,
			#			"employee": "Architect",
			#			"hand_num": 8,
			"hands":[],
			"built": ["Tavern", "Tavern", "Tavern","Tavern", "Tavern","Tavern","Tavern"]
		},
		{
			"player_num": 1,
			"username": "one",
			"money": 9,
			# "hands":["Tavern", "Tavern"],
			#			"employee": "Architect",
			#			"hand_num": 8,
			"built": []
		},
		{
			"player_num": 2,
			"username": "two",
			"money": 9,
			#			"employee": "Wizard",
			#			"hand_num": 2,
			#			"built": ["Market", "Dragon House"]
		},
		{
			"player_num": 3,
			"username": "three",
			"money": 9,
			#			"employee": "King",
			#			"hand_num": 3,
			#			"built": ["Market", "Dragon House"]
		},
		{
			"player_num": 4,
			"username": "four",
			"money": 9,
			#			"employee": "Merchant",
			#			"hand_num": 4,
			#			"built": ["Market", "Dragon House"]
		},
		{
			"player_num": 5,
			"username": "five",
			"money": 9,
			#			"employee": "Warlord",
			#			"hand_num": 6,
			#			"built": ["Market", "Dragon House"]
		},
		{
			"player_num": 6,
			"username": "six",
			"money": 9,
			#			"employee": "Wizard",
			#			"hand_num": 6,
			#			"built": ["Market", "Dragon House"]
		}
	]
	for i in range(data.size()):
		var d = data[i]
		var node = select_obj_by_relative_to_first_person(i)
		if node != null:
			node.on_player_info(d)


func select_obj_by_relative_to_first_person(relative_to_me: int) -> Node:
	return select_player_obj_by(FindPlayerObjBy.RELATIVE_TO_FIRST_PERSON, relative_to_me)


func select_obj_by_player_num(player_num: int) -> Node:
	return select_player_obj_by(FindPlayerObjBy.PLAYER_NUM, player_num)


func select_obj_by_employee(employee_name: String) -> Node:
	return select_player_obj_by(FindPlayerObjBy.EMPLOYEE, employee_name)

func find_employee_4_player() -> Node:
	var employee_4 = select_player_obj_by(FindPlayerObjBy.EMPLOYEE_NUM, 4)
	if employee_4 == null:
		return $Player
	return employee_4


func find_employee_4_pnum() -> int:
	var employee_4 = select_player_obj_by(FindPlayerObjBy.EMPLOYEE_NUM, 4)
	if employee_4 == null:
		return first_person_num
	return employee_4.player_num


func find_crown_pnum() -> int:
	var crown_player = select_player_obj_by(FindPlayerObjBy.CROWN, 0)
	if crown_player == null:
		return first_person_num
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
			and player_obj.employee_num == clue
		):
			return player_obj
		elif find_mode == FindPlayerObjBy.CROWN and player_obj.has_crown:
			return player_obj
		elif find_mode == FindPlayerObjBy.PLAYER_NUM and player_obj.player_num == clue:
			return player_obj
		elif find_mode == FindPlayerObjBy.RELATIVE_TO_FIRST_PERSON and n == clue:
			return player_obj
	return null


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
	if card_name != "":
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
			on_sgin_gold_transfer(bank_num, p_num)
	if TweenMove.is_active():
		yield(TweenMove, "tween_all_completed")
	Signal.emit_signal("sgin_ready_game")

func gold_move(from_pnum: int, to_pnum: int, gold_num: int, done_signal: String) -> void:
	for _i in range(gold_num):
		TimerGlobal.set_wait_time(0.1)
		TimerGlobal.start()
		yield(TimerGlobal, "timeout")
		on_sgin_gold_transfer(from_pnum, to_pnum)
	if TweenMove.is_active():
		yield(TweenMove, "tween_all_completed")
	Signal.call_deferred("emit_signal", done_signal)


func card_gain(player_num: int, card_num: int, done_signal: String) -> void:
	for _i in card_num:
		TimerGlobal.set_wait_time(0.1)
		TimerGlobal.start()
		yield(TimerGlobal, "timeout")
		on_sgin_draw_card(player_num, true)
	if TweenMove.is_active():
		yield(TweenMove, "tween_all_completed")
	Signal.call_deferred("emit_signal", done_signal)

func first_player() -> int:
	var player_num = randi() % (opponent_length + 1)
	# TODO Remove the next line
	player_num = 0
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


func hand_over_control(player_num: int) -> void:
	$AnyCardEnlarge.reset_cards()
	$AnyCardEnlarge.reset_characters()
	$Player.hide_opponent_built()
	var player_obj = select_obj_by_player_num(player_num)
	var player_name = player_obj.username
	var orginal_first_player = first_person_num
	var current_first_player = player_obj.player_num
	set_first_person_num(player_obj.player_num)
	Signal.emit_signal("hand_over", player_name)
	reseat(orginal_first_player, current_first_player)
	hide()


func on_sgin_ready_game() -> void:
	var player_num = first_player()
	var player_obj = select_obj_by_player_num(player_num)
	player_obj.set_crown(true)
	character_selection(player_num)


func character_selection(player_num: int) -> void:
	Signal.emit_signal("phase", tr("PHASE_TURN_NUM").replace('X', current_turn_num))
	hide()
	yield(Signal, "uncover")
	show()	
	Signal.emit_signal("phase", "PHASE_CHARACTER_SELECTION")
	hide()
	$Employment/DiscardedHidden.show()
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
		return next_x_num - opponent_length - 1
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
	if player_obj == null or is_assassinated(employee_num, employee_name):
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

	Signal.emit_signal("phase", "PHASE_TURN_START")
	hide()
	yield(Signal, "uncover")
	show()
	for employee_num in range(1, $Employment.full_num):
		# 播放动画，显示大牌，然后移动到相应的雇佣区去
		var employee_name = $Employment.find_by_num(employee_num)
		var player_obj = select_obj_by_employee(employee_name)
		var param = make_params(player_obj, employee_num, employee_name)
		$AnyCardEnlarge.char_enter(employee_name, param.scaling, param.employ_global_pos)
		yield(Signal, "sgin_char_entered")

		var should_continue = check_continue(employee_num, employee_name, player_obj == null)
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
				" [",
				player_objs.employee_num,
				"] ",
				player_objs.gold
			)
		print()
		on_sgin_disable_player_play()
		var sig = check_reveal(employee_num, employee_name, player_obj.player_num)
		if sig == "sgin_reveal_done":
			yield(Signal, "sgin_reveal_done")
		$Player.set_employee_activated_this_turn($Player/Employee.ActivateMode.ALL, false)
		var gold_to_draw = check_skill_resource_draw_gold($Player.built)
		var cards_to_select = check_skill_resource_draw_card_to_select($Player.built)
		var cards_to_draw = check_skill_resource_draw_card_to_click($Player.built, cards_to_select)
		on_sgin_set_reminder(tr("NOTE_CHOOSE_RESOURCE").replace("XXX", str(gold_to_draw)).replace("YYY",str(cards_to_select)).replace("ZZZ", str(cards_to_select-cards_to_draw)))
		$Player.set_script_mode($Player.ScriptMode.RESOURCE)
		$Player.show_scripts()
		yield(Signal, "sgin_resource_need")
		$Player.hide_scripts()
		yield(Signal, "sgin_resource_end")
		on_sgin_set_reminder("NOTE_PLAY")
		$Player.enable_play()
		$Player.reset_all_card_skill_activated()
		$Player.show_script3()
		yield(Signal, "sgin_end_turn")
		var sig2 = check_skill_end_turn($Player.hands, $Player.built, $Player.gold)
		if sig2 == "sgin_check_skill_end_turn_done":
			yield(Signal, "sgin_check_skill_end_turn_done")
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
				" [",
				player_objs.employee_num,
				"] ",
				player_objs.gold
			)
		print()
		
	var employee_4_player = find_employee_4_player()
	if is_assassinated(employee_4_player.employee_num, employee_4_player.employee):
		charskill_play_passive_king()
		charskill_play_passive_queen(false)
	if TweenMove.is_active():
		yield(TweenMove, "tween_all_completed")
	on_sgin_one_round_finished()


func on_sgin_selected_char_once_finished(char_num: int, char_name: String) -> void:
	$Player.set_employee(char_num, char_name)


func on_sgin_resource_need(what: int) -> void:
	match what:
		Need.GOLD:
			gain_gold()
		Need.CARD:
			gain_card()


func gain_gold() -> void:
	var gold_to_gain = check_skill_resource_draw_gold($Player.built)
	gold_move(bank_num, $Player.player_num, gold_to_gain, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	Signal.emit_signal("sgin_resource_end")

func check_skill_resource_draw_card_to_click(player_built: Array, card_to_select: int) -> int:
	for card_name in player_built:
		if "Library" in card_name:
			return card_skill_resource_draw_library(card_to_select)	
	return 1


func check_skill_resource_draw_card_to_select(player_built: Array) -> int:
	for card_name in player_built:
		if "Observatory" in card_name:
			return card_skill_resource_draw_observatory()	
	return 2


func check_skill_resource_draw_gold(player_built: Array) -> int:
	for b in player_built:
		if "Gold Mine" in b:
			return 3
	return 2
	
	
func check_skill_not_played_same(card_name: String) -> bool:
	var skill_not_played_same = false
	for card_name in $Player.built:
		if "Quarry" in card_name:
			skill_not_played_same = card_skill_play_quarry()
	var player_not_played_same = $Player.has_not_played_same(card_name)
	return skill_not_played_same or player_not_played_same

func check_skill_price(card_name: String) -> int:
	var data =  Data.get_card_info(card_name)
	var price = data['star']
	var color = data['kind']
	for card_name in $Player.built:
		if "Factory" in card_name:
			return card_skill_play_factory(color, price)
	return price



func check_skill_end_turn(player_hand: Array, player_built: Array, player_gold: int) -> String:
	var sig = ""
	for card_name in player_built:
		if "Park" in card_name:
			card_skill_end_turn_park(player_hand.size())
			sig = "sgin_check_skill_end_turn_done"
		if "Poor House" in card_name:
			card_skill_end_turn_poor_house(player_gold)
			sig = "sgin_check_skill_end_turn_done"
	Signal.call_deferred("emit_signal", "sgin_check_skill_end_turn_done")
	return sig

func gain_card() -> void:
	var card_to_select = check_skill_resource_draw_card_to_select($Player.built)
	var card_to_click = check_skill_resource_draw_card_to_click($Player.built, card_to_select)
	var to_select = []
	for _i in range(card_to_select):
		var card_name = $Deck.pop()
		if card_name != "":
			to_select.append(card_name)
	
	for _i in range(card_to_click):
		if to_select.size() > 0:
			$AnyCardEnlarge.selectable_cards(to_select)
			var sig = yield(Signal, "sgin_card_selected")
			yield(Signal, "sgin_player_draw_ready")
			to_select.erase(sig[0])  #.card_name

	$Deck.extend(to_select)
	Signal.emit_signal("sgin_resource_end")


func on_sgin_card_selected(card_name: String, from_pos: Vector2) -> void:
	$Player.draw(card_name, true, from_pos, 1)
	$AnyCardEnlarge.reset_cards()


func on_sgin_card_played(card_name: String, from_pos: Vector2) -> void:
	if $Player.script_mode == $Player.ScriptMode.PLAYING:		
 
		var price = check_skill_price(card_name)
		var enough_money = $Player.has_enough_money(price)
		var not_played_same = check_skill_not_played_same(card_name)
		var not_ever_played = check_skill_has_ever_played()
		if not (enough_money and not_played_same and not_ever_played):
			return
		on_sgin_disable_player_play()
		var success_play = $Player.card_played(card_name, price, from_pos)
		if success_play:
			yield(Signal, "sgin_card_played_finished")
		if $Player.built.size() == 7:
			city_finished.append($Player.player_num)
		$Player.enable_play()


func is_game_over() -> bool:
	var over = false
	for p in range(opponent_length + 1):
		var player_obj = select_obj_by_player_num(p)
		if player_obj.can_end_game():
			over = true
	return over


func on_sgin_one_round_finished() -> void:
	
	if not is_game_over():
		current_turn_num += 1
		var crown_player_num = find_employee_4_pnum()
		$Employment.reset_available()
		employee_reset()
		$Player.set_assassinated("Unchosen")
		$Player.set_stolen("Unchosen")
		character_selection(crown_player_num)
	else:
		game_over()


func employee_reset() -> void:
	for i in range(opponent_length + 1):
		var player_obj = select_obj_by_player_num(i)
		player_obj.set_employee(-1, "Unchosen")
		player_obj.set_hide_employee(true)


func check_game_over_skill() -> String:
	var sig = ""
	for player_num in range(opponent_length + 1):
		for b in select_obj_by_player_num(player_num).built:
			if "Haunted Quarter" in b:
				card_skill_game_over_haunted_quarter(player_num)
				sig = "sgin_haunted_quarter_color_selected"
				break
	return sig

func game_over() -> void:
	Signal.emit_signal("phase", "PHASE_GAME_OVER")
	hide()
	yield(Signal, "uncover")
	show()
	var sig = check_game_over_skill()
	var haunted_color = ""
	if sig:
		haunted_color = yield(Signal, "sgin_haunted_quarter_color_selected")
	var score_dic = {}
	for player_num in range(opponent_length + 1):
		score_dic[player_num] = calculate_score(player_num, haunted_color)
		
		
func calculate_score(player_num: int, haunted_color: String) -> Array:
	var score = 0
	var player_obj = select_obj_by_player_num(player_num)
	var _player_hands = player_obj.hands
	var player_built = player_obj.built
	var score_coins = 0
	var score_color = 0
	var score_hand = 0
	var score_built = 0
	var _hands_effect = []
	var built_effect = []
	var score_finished_7 = 0
	var has_red = 0
	var has_yellow = 0
	var has_blue = 0
	var has_green = 0
	var has_purple = 0
	var has_odd = 0
	
	var score_card = []
	
	for b in player_obj.built:
		var data = Data.get_card_info(b)
		var star = data['star']
		score_coins += star
		if star % 2:
			has_odd += 1		
		score_card.append(star)
		var color
		if "Haunted Quarter" in b:
			color = haunted_color
		else:
			color = data['kind']
		match color:
			"red":
				has_red += 1
			"yellow":
				has_yellow += 1
			"blue":
				has_blue += 1
			"green":
				has_green += 1
			"purple":
				has_purple += 1
	if has_red > 0 and has_yellow > 0 and has_blue > 0 and has_green > 0 and has_purple > 0:
		score_color = 3
	var finished_found = city_finished.find(player_num) 
	if finished_found == 0:
		score_finished_7 = 4
	elif finished_found == 1:
		score_finished_7 = 2
	
	for b in player_built:
		if "Ivory Tower" in b:
			var score_ivory = card_skill_game_over_ivory_tower(has_purple)
			if score_ivory > 0:
				built_effect.append("Ivory Tower")
				score_built += score_ivory
		if "Basilica" in b:
			var score_basilica = card_skill_game_over_basilica(has_odd)
			if score_basilica > 0:
				built_effect.append("Basilica")
				score_built += score_basilica
		if "Wishing Well" in b:
			var score_wishing_well = card_skill_game_over_wishing_well(has_purple)
			if score_wishing_well > 0:
				built_effect.append("Wishing Well")
				score_built += score_wishing_well
		if "Statue" in b:
			var score_statue = card_skill_game_over_statue(player_obj.has_crown)
			if score_statue > 0:
				built_effect.append("Statue")
				score_built += score_statue
		if "Imperial Treasury" in b:
			var score_imperial_treasury = card_skill_game_over_imperial_treasury(player_obj.gold)
			if score_imperial_treasury > 0:
				built_effect.append("Imperial Treasury")
				score_built += score_imperial_treasury
		if "Dragon Gate" in b:
			var score_dragon_gate = card_skill_game_over_dragon_gate()
			if score_dragon_gate > 0:
				built_effect.append("Dragon Gate")
				score_built += score_dragon_gate
		
	score = score_coins +  score_color + score_finished_7 + score_hand + score_built
	print()
	print(player_num)
	print(player_obj.username)
	print(player_built)
	print("score_cards: ", score_card)
	print("score_coins: ", score_coins)
	print("score_color: ", score_color)
	print("score_finished_7: ", score_finished_7)
	print("score_hand: ", score_hand)
	print("score_built: ", score_built)
	print("total_score: ", score)
	print()
	return [score, score_hand, score_built]
	
func check_skill_has_ever_played() -> bool:
	var skill_ever_played = false
	if $Player.employee == "Architect":
		skill_ever_played = $Player.built.size() < 3
	var player_ever_played = $Player.has_ever_played()
	return skill_ever_played or player_ever_played

func on_sgin_disable_player_play() -> void:
	$Employment.hide_discard_hidden()
	$AnyCardEnlarge.reset_cards()
	$AnyCardEnlarge.reset_characters()
	$Player.hide_scripts()
	$Player.disable_play()


func assassin_wait() -> void:
	on_sgin_disable_player_play()	
	$Player.set_script_mode($Player.ScriptMode.ASSASSIN)
	$Employment.wait_assassin(get_assassinable_characters())


func on_sgin_assassin_once_finished(char_num: int, char_name: String) -> void:
	on_sgin_disable_player_play()
	on_sgin_set_reminder("NOTE_PLAY")
	assassinate(char_num, char_name)
	$AnyCardEnlarge.assassinate(char_name)
	yield(TweenMove, "tween_all_completed")
	$Player.set_assassinated(char_name)
	$Player.enable_play()


func on_sgin_thief_once_finished(char_num: int, char_name: String) -> void:
	on_sgin_disable_player_play()
	on_sgin_set_reminder("NOTE_PLAY")
	steal(char_num, char_name)
	$AnyCardEnlarge.steal(char_name)
	yield(TweenMove, "tween_all_completed")
	$Player.set_stolen(char_name)
	$Player.enable_play()


func thief_wait():
	on_sgin_disable_player_play()
	$Player.set_script_mode($Player.ScriptMode.THIEF)
	$Employment.wait_thief(get_stealable_characters())


func on_sgin_thief_stolen():
	var thief_obj = select_player_obj_by(FindPlayerObjBy.EMPLOYEE, "Thief")
	gold_move($Player.player_num, thief_obj.player_num, $Player.gold, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	

func magician_wait():
	$Player.wait_magician()


func magician_select_deck() -> void:
	on_sgin_disable_player_play()
	for c in $Player.get_handscript_children():
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
	card_gain(first_person_num, temp.size(), "sgin_player_draw_ready")
	yield(Signal, "sgin_player_draw_ready")
	on_sgin_set_reminder("NOTE_PLAY")
	$Player.enable_play()


func magician_select_player() -> void:
	$Player.hide_scripts()
	for i in range(1, opponent_length + 1):
		var opponent = select_obj_by_relative_to_first_person(i)
		opponent.set_opponent_state(opponent.OpponentState.MAGICIAN_CLICKABLE)
	on_sgin_set_reminder("NOTE_MAGICIAN_SELECT_CHARACTER")
	


func on_sgin_magician_switch(switch):
	if switch == $Player.MagicianSwitch.DECK:
		magician_select_deck()
	else:
		magician_select_player()


func on_sgin_magician_opponent_selected(player_num: int) -> void:
	on_sgin_disable_player_play()
	for i in range(1, opponent_length + 1):
		var opponent = select_obj_by_relative_to_first_person(i)
		opponent.set_opponent_state(opponent.OpponentState.IDLE)

	var switch_opponent = select_obj_by_player_num(player_num)
	var player_hands_obj = $Player.get_handscript_children().duplicate()
	var switch_hands_name = switch_opponent.hands.duplicate()

	for card_obj in player_hands_obj:
		switch_opponent.draw(card_obj.card_name, true, card_obj.global_position, 1)
		$Player.remove_hand(card_obj.card_name)

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
		switch_opponent.remove_hand(card_name)

	for _i in range(switch_hands_name.size()):
		yield(Signal, "sgin_player_draw_ready")

	on_sgin_set_reminder("NOTE_PLAY")
	$Player.enable_play()

func charskill_play_passive_queen(in_turn: bool=true) -> void:
	var four_player = find_employee_4_player()
	if is_assassinated(four_player.employee_num, four_player.employee) and in_turn:
		return false
	var four_pnum = four_player.player_num
	var caught_king = false
	if first_person_num == 0:
		if four_pnum in [opponent_length, first_person_num + 1]:
			caught_king = true
	elif first_person_num == opponent_length:
		if four_pnum in [0, first_person_num - 1]:
			caught_king = true	
	elif four_pnum in [first_person_num -1,  first_person_num + 1]:
		caught_king = true
	if caught_king:
		gold_move(bank_num, first_person_num, 3, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")

func charskill_play_passive_king() -> void:
	var crown_pnum = find_crown_pnum()
	var emoloyee_4_pnum = find_employee_4_pnum()	
	var original_crown_owner = select_obj_by_player_num(crown_pnum)
	var from_pos = original_crown_owner.get_node("Crown").global_position
	
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
	crown.queue_free()


func on_sgin_gold_transfer(from_pnum: int, to_pnum: int) -> void:
	var from_player = select_obj_by_player_num(from_pnum)
	var to_player = select_obj_by_player_num(to_pnum)
	var start_scale = Vector2(1.7, 1.7) if from_pnum == $Player.player_num else Vector2(1, 1)
	var end_scale = Vector2(1.7, 1.7) if to_pnum == $Player.player_num else Vector2(1, 1)
	var from_pos = from_player.get_node("MoneyIcon").global_position
	var to_pos = to_player.get_node("MoneyIcon").global_position
	var money = Money.instance()
	money.to_coin(start_scale, from_pos)
	$Bank.add_child(money)
	var animations = []
	animations.append([money, "global_position", from_pos, to_pos])
	animations.append([money, "scale", start_scale, end_scale])
	TweenMove.animate(animations)
	from_player.add_gold(-1)
	to_player.add_gold(1)
	yield(TweenMove, "tween_all_completed")
	$Bank.remove_child(money)
	money.queue_free()


func on_sgin_set_reminder(text: String) -> void:
	if not text:
		$Player.hide_reminder()
	else:
		$Player.show_reminder()
	$Player.set_reminder_text(tr(text))


func on_sgin_merchant_gold(mode: int) -> void:
	$Player.hide_scripts()
	if mode == $Player.MerchantGold.ONE:
		$Player.disable_play()
		gold_move(bank_num, $Player.player_num, 1, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")
	else:
		var gained = gain_gold_by_color("green")
		gold_move(bank_num, $Player.player_num, gained, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")
		if gained == 0:
			$Player.set_employee_activated_this_turn($Player/Employee.ActivateMode.SKILL2, false)
	on_sgin_set_reminder("NOTE_PLAY")		
	$Player.enable_play()


func on_sgin_show_built(player_num: int) -> void:
	var player_obj = select_obj_by_player_num(player_num)
	if player_obj != null:
		var built = player_obj.built
		var name = player_obj.username
		$Player.show_opponent_built(name, built)


func on_sgin_hide_built() -> void:
	$Player.hide_opponent_built()


func on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if not started:
			start_game()
			started = true
		$Player.hide_opponent_built()


func on_sgin_skill(skill_name: String) -> void:
	if skill_name == "assassin":
		assassin_wait()
	elif skill_name == "thief":
		thief_wait()
	elif skill_name == "magician":
		magician_wait()
	elif skill_name == "king":
		charskill_play_active_king()
	elif skill_name == "bishop":
		charskill_play_active_bishop()
	elif skill_name == "merchant":
		charskill_play_active_merchant()
	elif skill_name == "architect":
		charskill_play_active_architect()
	elif skill_name == "warlord":
		charskill_play_active_warlord()


func on_sgin_cancel_skill(components: Array, activate_key: String="", activate_mode: int=-1) -> void:
	for component in components:
		if component == "employment":
			$Employment.hide()
		elif component == "opponent":
			for p in range(opponent_length + 1):
				var opponent = select_obj_by_relative_to_first_person(p)
				opponent.set_opponent_state(opponent.OpponentState.IDLE)			
		elif component == "scripts":	
			$Player.hide_scripts()
		elif component == "opponent_built":
			$Player.set_opponent_built_mode($Player.OpponentBuiltMode.SHOW)
			$Player.hide_opponent_built()
		elif component == "destroy":
			destroyed = [unfound, "Unchosen"]

		if not activate_key:
			pass
		elif activate_key == "Character":
			$Player.set_employee_activated_this_turn(activate_mode, false)
		else:
			$Player.set_card_skill_activated(activate_key, activate_mode)
			
	on_sgin_set_reminder("NOTE_PLAY")
	$Player.enable_play()


func is_stolen(employee_num: int, employee_name: String) -> bool:
	return [employee_num, employee_name] == stolen


func check_reveal(employee_num: int, employee_name: String, _player_num: int) -> String:
	var sig = ""
	if is_stolen(employee_num, employee_name):
		on_sgin_thief_stolen()
		sig = "sgin_reveal_done"
	if is_number_four(employee_num) and (not is_assassinated(employee_num, employee_name)):
		charskill_play_passive_king()
		sig = "sgin_reveal_done"
	if employee_name == "Queen" and (not is_assassinated(employee_num, employee_name)):
		charskill_play_passive_queen(true)
		sig = "sgin_reveal_done"
	Signal.call_deferred("emit_signal", "sgin_reveal_done")
	return sig
	
func check_continue(employee_num: int, employee_name: String, player_is_null: int) -> bool:
	if player_is_null:
		return true
	elif is_assassinated(employee_num, employee_name):
		return true
	return false


func is_number_four(employee_num: int) -> bool:
	return employee_num == 4


func charskill_play_active_king() -> void:
	$Player.disable_play()
	var gained = gain_gold_by_color("yellow")
	gold_move(bank_num, first_person_num, gained, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	if gained == 0:
		$Player.set_employee_activated_this_turn($Player/Employee.ActivateMode.ALL, false)
	$Player.enable_play()

func charskill_play_active_bishop() -> void:
	$Player.disable_play()
	var gained = gain_gold_by_color("blue")
	gold_move(bank_num, first_person_num, gained, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	if gained == 0:
		$Player.set_employee_activated_this_turn($Player/Employee.ActivateMode.ALL, false)
	$Player.enable_play()
	

func gain_gold_by_color(color: String) -> int:
	var built_color_num = $Player.built_color_num(color)
	var add_num = card_type_change(color)
	var gained = built_color_num + add_num
	return gained
	

	


func card_type_change(_color: String) -> int:
	return 0


func card_skill_resource_draw_library(card_to_gain: int) -> int:
	return card_to_gain


func card_skill_end_turn_park(hand_size: int) -> void:
	if hand_size == 0:
		card_gain(first_person_num, 2, "sgin_player_draw_ready")
		yield(Signal, "sgin_player_draw_ready")


func card_skill_play_quarry() -> bool:
	return true

func card_skill_play_armory() -> void:
	for p in range(opponent_length + 1):
		var opponent = select_obj_by_relative_to_first_person(p)
		if armory_destructable(opponent.player_num):
			opponent.set_opponent_state(opponent.OpponentState.ARMORY_CLICKABLE)
		else:
			opponent.set_opponent_state(opponent.OpponentState.SILENT)
	$Player.wait_armory()


func card_skill_out_turn_keep() -> bool:
	return false


func card_skill_game_over_ivory_tower(purple_size: int) -> int:
	if purple_size == 1:
		return 5
	return 0


func card_skill_resource_draw_observatory() -> int:
	return 3


func card_skill_play_factory(color: String, price: int) -> int:
	if color == "purple":
		return price - 1
	return price


func card_skill_play_smithy() -> void:
	if $Player.get_card_skill_activated("Smithy"):
		return
	elif $Player.gold < 2:
		return
	$Player.set_card_skill_activated("Smithy", true) 
	gold_move(first_person_num, bank_num, 2, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	card_gain(first_person_num, 3, "sgin_player_draw_ready")
	yield(Signal, "sgin_player_draw_ready")
	

func card_skill_play_laboratory() -> void:
	if $Player.get_card_skill_activated("Laboratory"):
		return
	$Player.wait_laboratory()


func card_skill_game_over_basilica(odd_size: int) -> int:
	return odd_size


func card_skill_game_over_wishing_well(has_purple: int) -> int:
	return has_purple


func card_skill_game_over_statue(has_crown: bool) -> int:
	return 5 if has_crown else 0


func card_skill_game_over_imperial_treasury(gold: int) -> int:
	return gold


func card_skill_play_great_wall(price_raw: int) -> int:
	return price_raw + 1


func cardskill_resourcegold_gold_mine() -> int:
	return 3


func card_skill_game_over_dragon_gate() -> int:
	return 2


func card_skill_end_turn_poor_house(gold: int) -> void:
	if gold == 0:
		gold_move(bank_num, first_person_num, 1, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")


func card_skill_game_over_haunted_quarter(player_num: int) -> void:
	hide()
	hand_over_control(player_num)
	yield(Signal, "uncover")
	show()	
	on_sgin_disable_player_play()
	on_sgin_set_reminder("NOTE_HAUNTED_QUARTER")
	$Player.wait_haunted_quarter_color()


func framework() -> void:
	pass


func necropolis() -> void:
	pass


func cardskill_gameover_map_room(hand_num: int) -> void:
	Signal.emit_signal("sgin_add_point", hand_num)


func cardskill_canbuild_monument(built_num: int) -> bool:
	return built_num >= 5


func cardskill_builtcount_monument() -> int:
	return 2


func cardskill_gameoverhand_secret_vault() -> void:
	Signal.emit_signal("sgin_add_point", 3)


func school_of_magic() -> void:
	pass


func thieves_den() -> void:
	pass


func cardskill_gameover_capitol(
	red_num: int, blue_num: int, green_num: int, yellow_num: int, purple_num: int
) -> void:
	if red_num >= 3 or blue_num >= 3 or green_num >= 3 or yellow_num >= 3 or purple_num >= 3:
		Signal.emit_signal("sgin_add_point", 3)


func theater():
	pass


func cardskill_play_stables():
	return false


func museum() -> void:
	pass


func get_assassinable_characters() -> Array:
	var char_array = []
	for num in range(2, $Employment.full_num):
		char_array.append(num)
	return char_array


func get_stealable_characters() -> Array:
	var char_array = []
	for num in range(3, $Employment.full_num):
		if num != assassinated[0]:
			char_array.append(num)
	return char_array


func assassinate(employee_num: int, employee_name: String) -> void:
	assassinated = [employee_num, employee_name]


func is_assassinated(employee_num: int, employee_name: String) -> bool:
	return [employee_num, employee_name] == assassinated


func steal(employee_num: int, employee_name: String) -> void:
	stolen = [employee_num, employee_name]


func charskill_play_active_merchant() -> void:
	$Player.wait_merchant()


func charskill_play_active_architect() -> void:
	card_gain(first_person_num, 2, "sgin_player_draw_ready")
	yield(Signal, "sgin_player_draw_ready")
	$Player.enable_play()

func charskill_play_active_warlord() -> void:
	$Player.wait_warlord()


func warlord_destructable(player_num: int, employee_name: String) -> bool:
	if employee_name == "Bishop":
		if assassinated[1] == employee_name:
			return true
		else:
			return false
	if player_num in city_finished:
		return false
	return true


func armory_destructable(player_num: int) -> bool:
	return not player_num in city_finished
	
func warlord_destructable_card(built: Array, warlord_gold: int, card_name: String) -> bool:
	if "Keep" in card_name:
		return card_skill_out_turn_keep()
	var price_raw = Data.get_card_info(card_name)['star'] - 1
	return warlord_gold >= check_skill_8_price(built, price_raw)

func armory_destructable_card(card_name: String) -> bool:
	return card_name != "Armory"


func on_sgin_warlord_choice(mode: int) -> void:
	$Player.hide_scripts()
	if mode == $Player.WarlordChoice.DESTROY:
		for p in range(opponent_length + 1):
			var opponent = select_obj_by_relative_to_first_person(p)
			if warlord_destructable(opponent.player_num, opponent.employee):
				opponent.set_opponent_state(opponent.OpponentState.WARLORD_CLICKABLE)
			else:
				opponent.set_opponent_state(opponent.OpponentState.SILENT)
	else:
		var gained = gain_gold_by_color("red")
		gold_move(bank_num, first_person_num, gained, "sgin_player_gold_ready")
		if gained == 0:
			$Player.set_employee_activated_this_turn($Player/Employee.ActivateMode.SKILL2, false)
		on_sgin_set_reminder("NOTE_PLAY")		
		$Player.enable_play()


func on_sgin_warlord_opponent_selected(player_num: int, player_employee: String, opponent_name: String, built: Array) -> void:
	$Player.set_opponent_built_mode($Player.OpponentBuiltMode.WARLORD_SHOW)
	var shown = []
	var warlord_gold = $Player.gold
	var war_opponent = select_obj_by_player_num(player_num)
	for card_name in built:
		if warlord_destructable_card(war_opponent.built, warlord_gold, card_name):
			shown.append(card_name)
	destroyed = [player_num, player_employee]
	$Player.show_opponent_built(opponent_name, shown)
	
func on_sgin_armory_opponent_selected(player_num: int, player_employee: String, opponent_name: String, built: Array) -> void:
	$Player.set_opponent_built_mode($Player.OpponentBuiltMode.ARMORY_SHOW)
	var shown = []
	
	for card_name in built:
		if armory_destructable_card(card_name):
			shown.append(card_name)
	destroyed = [player_num, player_employee]
	$Player.show_opponent_built(opponent_name, shown)


func on_sgin_card_laboratory_selected(card_name: String, from_pos: Vector2) -> void:
	on_sgin_disable_player_play()
	var card_obj = $Player.get_hand_obj(card_name)
	if card_obj == null:
		return
	var original_scale = card_obj.scale
	card_enlarge_to_center(card_obj, from_pos)
	yield(Signal, "sgin_card_move_done")
	card_obj.global_position = center
	center_card_shrink_to_away(card_obj, original_scale)
	yield(Signal, "sgin_card_move_done")	
	$Player.remove_hand(card_name)
	$Player.rearrange_hands()
	yield(TweenMove, "tween_all_completed")
	gold_move(bank_num, first_person_num, 2, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	$Deck.append(card_name)
	$Player.set_card_skill_activated("Laboratory", true)
	$Player.enable_play()

func check_skill_8_price(built: Array, price: int) -> int:
	for b in built:
		if "Great Wall" in b:
			return price + 1
	return price

func on_sgin_card_warlord_selected(card_name: String, from_pos: Vector2) -> void:
	$AnyCardEnlarge.reset_cards()
	$AnyCardEnlarge.reset_characters()
	var war_opponent = select_obj_by_player_num(destroyed[0])
	var price_raw = Data.get_card_info(card_name)['star'] - 1
	var price = check_skill_8_price(war_opponent.built, price_raw)	
	var card_obj = $Player.get_opponent_built_obj(card_name)
	if card_obj == null:
		return	
	on_sgin_disable_player_play()
	gold_move(first_person_num, bank_num, price, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	card_obj.on_mouse_exited()
	var original_scale = card_obj.scale
	if destroyed[0] == first_person_num:
		var c = $Player.get_built_obj(card_name)
		if c != null:
			card_move(c, c.global_position, from_pos, c.scale, original_scale, "sgin_card_move_done")
			yield(Signal, "sgin_card_move_done")
			c.set_visible(false)	
	card_enlarge_to_center(card_obj, from_pos)
	yield(Signal, "sgin_card_move_done")
	card_obj.global_position = center
	center_card_shrink_to_away(card_obj, original_scale)
	yield(Signal, "sgin_card_move_done")
	war_opponent.remove_built(card_name)
	$Deck.append(card_name)
	on_sgin_cancel_skill(["opponent", "opponent_built", "destroyed"])


func on_sgin_card_clickable_clicked(card_name: String, _global_position: Vector2) -> void:
	if "Armory" in card_name:
		card_skill_play_armory()
	elif "Smithy" in card_name:
		card_skill_play_smithy()
	elif "Laboratory" in card_name:
		card_skill_play_laboratory()

func card_move(card_obj: Node, start_pos: Vector2, end_pos: Vector2, start_scale: Vector2, end_scale: Vector2, done_signal: String) -> void:
	var z_index = card_obj.z_index
	card_obj.z_index = 4096
	var animations = []
	animations.append([card_obj, "global_position", start_pos, end_pos])
	animations.append([card_obj, "scale", start_scale, end_scale])
	TweenMove.animate(animations)
	yield(TweenMove, "tween_all_completed")
	card_obj.z_index = z_index
	Signal.call_deferred("emit_signal", done_signal)

func card_enlarge_to_center(card_obj: Node, start_pos: Vector2, done_signal: String = "sgin_card_move_done") -> void:
	card_move(card_obj, start_pos, center, card_obj.scale, Vector2(0.6, 0.6), done_signal)

func center_card_shrink_to_away(card_obj: Node, end_scale: Vector2, done_signal: String = "sgin_card_move_done") -> void:
	card_move(card_obj, center, Vector2(3000, center.y), Vector2(0.6, 0.6), end_scale, done_signal)
	

func on_sgin_card_armory_selected(card_name: String, from_pos: Vector2) -> void:	
	$AnyCardEnlarge.reset_cards()
	$AnyCardEnlarge.reset_characters()
	var card_obj = $Player.get_opponent_built_obj("card_name")
	if card_obj == null:
		return
	on_sgin_disable_player_play()
	card_obj.on_mouse_exited()
	var war_opponent = select_obj_by_player_num(destroyed[0])
	if destroyed[0] == first_person_num:
		# my built to center
		var c = $Player.get_built_obj(card_name)
		if c != null:
			card_move(c, c.global_position, from_pos, c.scale, card_obj.scale, "sgin_card_move_done")
			yield(Signal, "sgin_card_move_done")
			c.set_visible(false)				
	
	card_enlarge_to_center(card_obj, from_pos)
	yield(Signal, "sgin_card_move_done")
	center_card_shrink_to_away(card_obj, card_obj.scale)
	yield(Signal, "sgin_card_move_done")
	war_opponent.remove_built(card_name)
	$Deck.append(card_name)
	
	# remove armory
	var armory_obj = $Player.get_built_obj("Armory")
	var armory_scale = armory_obj.scale
	card_enlarge_to_center(armory_obj, armory_obj.global_position)
	yield(Signal, "sgin_card_move_done")
	armory_obj.global_position = center
	center_card_shrink_to_away(armory_obj, armory_scale)
	yield(Signal, "sgin_card_move_done")
	$Player.remove_built("Armory")
	$Player.rearrange_built()
	if TweenMove.is_active():
		yield(TweenMove, "tween_all_completed")
	
	# reset
	on_sgin_cancel_skill(["opponent", "opponent_built", "destroyed"])


