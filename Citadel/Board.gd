extends Node2D

onready var current_turn_num = 1
onready var first_person_num = 0
onready var opponent_length = 3#6
onready var discarded_hidden_position = $Employment/DiscardedHidden.position
onready var lang = "zh_CN"
onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var TweenMove = get_node("/root/Main/Tween")
onready var TweenMotion = get_node("/root/Main/TweenMotion")
onready var TimerGlobal = get_node("/root/Main/Timer")
const Crown = preload("res://Crown.tscn")
const Money = preload("res://Money.tscn")
const Card = preload("res://Card.tscn")
onready var started = false



#Game
onready var city_finished = []


#Skill
onready var stolen = [Data.unfound, "Unchosen"]
onready var assassinated = [Data.unfound, "Unchosen"]
onready var destroyed = [Data.unfound, "Unchosen"]


func _ready() -> void:
	TranslationServer.set_locale(lang)
	Data.set_deck_position($Deck.global_position)
	Data.set_bank_position($Bank.global_position)
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
			"money": 5,
			"built": ["Laboratory"],
			"hands": []
		},
		{
			"player_num": 1,
			"username": "one",
			"money": 0,
			"built": ["Tavern"],
		},
		{
			"player_num": 2,
			"username": "two",
			"money": 0,
		},
		{
			"player_num": 3,
			"username": "three",
			"money": 0,
		},
		{
			"player_num": 4,
			"username": "four",
			"money": 0,
		},
		{
			"player_num": 5,
			"username": "five",
			"money": 0,
		},
		{
			"player_num": 6,
			"username": "six",
			"money": 0,
		}
	]
	for i in range(data.size()):
		var d = data[i]
		var node = select_obj_by_relative_to_first_person(i)
		if node != null:
			node.on_player_info(d)


func select_obj_by_relative_to_first_person(relative_to_me: int) -> Node:
	return select_player_obj_by(Data.FindPlayerObjBy.RELATIVE_TO_FIRST_PERSON, relative_to_me)


func select_obj_by_player_num(player_num: int) -> Node:
	return select_player_obj_by(Data.FindPlayerObjBy.PLAYER_NUM, player_num)


func select_obj_by_employee(employee_name: String) -> Node:
	return select_player_obj_by(Data.FindPlayerObjBy.EMPLOYEE, employee_name)

func find_employee_4_player() -> Node:
	var employee_4 = select_player_obj_by(Data.FindPlayerObjBy.EMPLOYEE_NUM, 4)
	if employee_4 == null:
		return $Player
	return employee_4


func find_employee_4_pnum() -> int:
	var employee_4 = select_player_obj_by(Data.FindPlayerObjBy.EMPLOYEE_NUM, 4)
	if employee_4 == null:
		return first_person_num
	return employee_4.player_num


func find_crown_pnum() -> int:
	var crown_player = select_player_obj_by(Data.FindPlayerObjBy.CROWN, 0)
	if crown_player == null:
		return first_person_num
	return crown_player.player_num


func select_player_obj_by(find_mode: int, clue) -> Node:
	var player_obj

	for n in range(-2, opponent_length + 1):
		if n == 0:
			player_obj = $Player
		elif n == Data.bank_num:
			player_obj = $Bank
		elif n == Data.deck_num:
			player_obj = $Deck
		else:
			player_obj = get_node(str("Opponent", n))

		if find_mode == Data.FindPlayerObjBy.EMPLOYEE and player_obj.employee == clue:
			return player_obj
		elif (
			find_mode == Data.FindPlayerObjBy.EMPLOYEE_NUM
			and player_obj.employee_num == clue
		):
			return player_obj
		elif find_mode == Data.FindPlayerObjBy.CROWN and player_obj.has_crown:
			return player_obj
		elif find_mode == Data.FindPlayerObjBy.PLAYER_NUM and player_obj.player_num == clue:
			return player_obj
		elif find_mode == Data.FindPlayerObjBy.RELATIVE_TO_FIRST_PERSON and n == clue:
			return player_obj
	return null


func show_player() -> void:
	$OpponentPath2D/PathFollow2D.unit_offset = 0
	for i in range(opponent_length):
		$OpponentPath2D/PathFollow2D.unit_offset += 1 / float(opponent_length + 1)
		var node = get_node(str("Opponent", i + 1))
		node.position = $OpponentPath2D/PathFollow2D.position


func on_sgin_draw_card(player_num: int, face_is_up: bool, from_pos: Vector2 = Data.DECK_POSITION):
	if from_pos == null:
		from_pos = Data.DECK_POSITION
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
			on_sgin_gold_transfer(Data.bank_num, p_num)
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
	Signal.call_deferred("emit_signal", done_signal, 0)

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


func on_sgin_card_unfocused() -> void:
	$AnyCardEnlarge.on_sgin_card_unfocused()


func on_sgin_char_unfocused() -> void:
	$AnyCardEnlarge.on_sgin_char_unfocused()


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
	var sig = check_skill_selection()
	if sig:
		yield(Signal, "sgin_all_selection_skill_reaction_completed")

	Signal.emit_signal("sgin_start_turn")


class Params:
	var start_pos: Vector2 = Vector2(0, 0)
	var end_pos: Vector2 = Vector2(0, 0)
	var start_scale: Vector2 = Vector2(0, 0)
	var end_scale: Vector2 = Vector2(0, 0)

	func _init(st_pos: Vector2, ed_pos: Vector2, st_scale: Vector2, ed_scale: Vector2) -> void:
		start_pos = st_pos
		end_pos = ed_pos
		start_scale = st_scale
		end_scale = ed_scale
		


func make_params(player_obj: Node, employee_num: int, employee_name: String) -> Params:
	var end_pos
	var scaling
	if player_obj == null or is_assassinated(employee_num, employee_name):
		end_pos = Data.CENTER
		scaling = Data.ZERO
	else:
		end_pos = player_obj.get_node("Employee").global_position
		if player_obj.player_num == first_person_num:
			scaling = Data.CHAR_SIZE_SMALL
		else:
			scaling = Data.CHAR_SIZE_TINY
	var params = Params.new(Data.CENTER, end_pos, Data.CHAR_SIZE_BIG, scaling)
	return params


func on_start_turn() -> void:
	Signal.emit_signal("phase", "PHASE_TURN_START")
	hide()
	yield(Signal, "uncover")
	show()
	for employee_num in range(1, $Employment.full_num):
		# 播放动画，显示大牌，然后移动到相应的雇佣区去
		on_sgin_disable_player_play()
		var employee_name = $Employment.find_by_num(employee_num)
		var player_obj = select_obj_by_employee(employee_name)
		var param = make_params(player_obj, employee_num, employee_name)
		$AnyCardEnlarge.char_enter(employee_name, param.start_pos, param.end_pos, param.start_scale, param.end_scale)
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
				player_objs.gold,
				" meseum_num:",
				player_objs.museum_num
			)
		print()
		
		var sig = check_reveal(employee_num, employee_name, player_obj.player_num)
		if sig == "sgin_reveal_done":
			yield(Signal, "sgin_reveal_done")
		$Player.set_employee_activated_this_turn(Data.ActivateMode.ALL, false)
		var gold_to_draw = check_skill_resource_draw_gold($Player.built)
		var cards_to_select = check_skill_resource_draw_card_to_select($Player.built)
		var cards_to_draw = check_skill_resource_draw_card_to_click($Player.built, cards_to_select)
		on_sgin_set_reminder(tr("NOTE_CHOOSE_RESOURCE").replace("XXX", str(gold_to_draw)).replace("YYY",str(cards_to_select)).replace("ZZZ", str(cards_to_select-cards_to_draw)))
		$Player.set_script_mode(Data.ScriptMode.RESOURCE)
		$Player.show_scripts()
		yield(Signal, "sgin_resource_need")
		$Player.hide_scripts()
		yield(Signal, "sgin_resource_end")
		on_sgin_set_reminder("NOTE_PLAY")
		on_sgin_enable_player_play()
		$Player.reset_all_card_skill_activated()
		$Player.show_script3()
		yield(Signal, "sgin_end_turn")
		on_sgin_set_reminder("NOTE_END_TURN_DISPLAY")
		var sig2 = check_skill_end_turn($Player.hands, $Player.built, $Player.gold)
		if sig2 == "sgin_check_skill_end_turn_done":
			yield(Signal, "sgin_check_skill_end_turn_done")
		$Player.after_end_turn()
		on_sgin_disable_player_play()
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
				player_objs.gold,
				" meseum_num:",
				player_objs.museum_num
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
		Data.Need.GOLD:
			gain_gold()
		Data.Need.CARD:
			gain_card()


func gain_gold() -> void:
	var gold_to_gain = check_skill_resource_draw_gold($Player.built)
	gold_move(Data.bank_num, $Player.player_num, gold_to_gain, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	Signal.emit_signal("sgin_resource_end")

func check_skill_selection() -> String:
	var sig = ""
	for i in range(opponent_length + 1):
		var player_obj = select_obj_by_player_num(i)
		for b in player_obj.built:
			if "Theater" in b:
				card_skill_selection_theater(player_obj.player_num)
				yield(Signal, "sgin_theater_reaction_completed")
				sig = "sgin_all_selection_skill_reaction_completed"
	Signal.emit_signal("sgin_all_selection_skill_reaction_completed")
	return sig

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
	
func check_rule_not_played_same(card_name: String) -> bool:
	return $Player.has_not_played_same(card_name)

func check_skill_not_played_same(card_name: String) -> bool:
	var skill_not_played_same = false
	for card_name in $Player.built:
		if "Quarry" in card_name:
			skill_not_played_same = card_skill_play_quarry()
	var player_not_played_same = check_rule_not_played_same(card_name)
	return skill_not_played_same or player_not_played_same

func check_skill_play_price(card_name: String) -> int:
	var data =  Data.get_card_info(card_name)
	var price = data['star']
	var color = data['kind']
	for built_name in $Player.built:
		if "Factory" in built_name:
			price = card_skill_play_factory(color, price)
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

 

func handle_resource_skill_reaction(required_color: String, gained: int, built: Array) -> void:
	for b in built:
		if "School of Magic" in b:
			card_skill_resource_skill_school_of_magic()
			var color = yield(Signal, "sgin_school_of_magic_color_selected")
			if color == required_color:
				gained += 1
	Signal.emit_signal("sgin_all_resource_skill_reaction_completed", gained)
			


func handle_play_skill_reaction(price: int, play_name: String, gold: int, built: Array) -> void:
	if "Necropolis" in play_name:
		card_skill_play_necropolis(play_name, price)
		price = yield(Signal, "sgin_necropolis_reaction_completed")
	for b in built:
		if price <= 0:
			break
		if "Framework" in b:
			card_skill_play_framework(play_name, price)
			price = yield(Signal, "sgin_framework_reaction_completed")
	print("After framework price; ", price)
	if "Thieves' Den" in play_name and price > 0:
		card_skill_play_thieves_den(play_name, price, gold)
		price = yield(Signal, "sgin_thieves_den_reaction_completed")
	print("After thieves den price; ", price)
	Signal.emit_signal("sgin_all_play_reaction_completed", price)
	
func skill_can_play(play_name: String, price: int) -> bool:
	if price < 0:
		return false
	var enough_money = $Player.has_enough_money(price)
	var not_played_same = check_skill_not_played_same(play_name)
	var not_ever_played = check_skill_has_ever_played(play_name)
	var playable = check_skill_playable(play_name, $Player.built.size())
	return (enough_money and not_played_same and not_ever_played and playable)
 
	
func on_sgin_card_played(play_name: String, from_pos: Vector2) -> void:
	if $Player.script_mode != Data.ScriptMode.PLAYING:
		return
	var price = check_skill_play_price(play_name)
	var wait = handle_play_skill_reaction(price, play_name, $Player.gold, $Player.built)
	if wait:
		price = yield(Signal, "sgin_all_play_reaction_completed")
	print("judge price: ", price)
	if not skill_can_play(play_name, price):
		print("cannot play")
		on_sgin_set_reminder("NOTE_CANNOT_PLAY")
		TimerGlobal.set_wait_time(0.5)
		TimerGlobal.start()
		yield(TimerGlobal, "timeout")
		on_sgin_enable_player_play()
		return
	print("success play")
	on_sgin_disable_player_play()
	var success_play = $Player.card_played(play_name, price)
	if success_play:
		yield(Signal, "sgin_card_played_finished")
	if $Player.built.size() == 7:
		city_finished.append($Player.player_num)
	on_sgin_enable_player_play()


func is_game_over() -> bool:
	var over = false
	for p in range(opponent_length + 1):
		var player_obj = select_obj_by_player_num(p)
		over = check_skill_can_end_game(player_obj.built)
		if over:
			break
		elif player_obj.can_end_game():
			over = true
			break
	return over


func on_sgin_one_round_finished() -> void:	
	if not is_game_over():
		current_turn_num += 1
		var crown_player_num = find_employee_4_pnum()
		$Employment.reset_available()
		$Employment.reset_discard_hidden()
		employee_reset()
		stolen = [Data.unfound, "Unchosen"]
		assassinated = [Data.unfound, "Unchosen"]
		destroyed = [Data.unfound, "Unchosen"]
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
	var player_hands = player_obj.hands
	var player_built = player_obj.built
	var score_coins = 0
	var score_color = 0
	var score_hand = 0
	var score_built = 0
	var hands_effect = []
	var built_effect = []
	var score_finished_7 = 0
	var red_num = 0
	var yellow_num = 0
	var blue_num = 0
	var green_num = 0
	var purple_num = 0
	var odd_num = 0
	
	var score_card = []
	
	for b in player_obj.built:
		var data = Data.get_card_info(b)
		var star = data['star']
		score_coins += star
		if star % 2:
			odd_num += 1		
		score_card.append(star)
		var color
		if "Haunted Quarter" in b:
			color = haunted_color
		else:
			color = data['kind']
		match color:
			"red":
				red_num += 1
			"yellow":
				yellow_num += 1
			"blue":
				blue_num += 1
			"green":
				green_num += 1
			"purple":
				purple_num += 1
	if red_num > 0 and yellow_num > 0 and blue_num > 0 and green_num > 0 and purple_num > 0:
		score_color = 3
	var finished_found = city_finished.find(player_num) 
	if finished_found == 0:
		score_finished_7 = 4
	elif finished_found == 1:
		score_finished_7 = 2
	for h in player_hands:
		if "Secret Vault" in h:
			var score_secret_vault = card_skill_game_over_secret_vault()
			if score_secret_vault > 0:
				hands_effect.append("Secret Vault")
				score_hand += score_secret_vault			
	for b in player_built:
		if "Map Room" in b:
			var score_map_room = card_skill_game_over_map_room(player_hands.size())
			if score_map_room > 0:
				built_effect.append("Map Room")
				score_built += score_map_room
		if "Ivory Tower" in b:
			var score_ivory = card_skill_game_over_ivory_tower(purple_num)
			if score_ivory > 0:
				built_effect.append("Ivory Tower")
				score_built += score_ivory
		if "Basilica" in b:
			var score_basilica = card_skill_game_over_basilica(odd_num)
			if score_basilica > 0:
				built_effect.append("Basilica")
				score_built += score_basilica
		if "Wishing Well" in b:
			var score_wishing_well = card_skill_game_over_wishing_well(purple_num)
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
		if "Capitol" in b:
			var score_capitol = card_skill_game_over_capitol(red_num, blue_num, green_num, yellow_num, purple_num)
			if score_capitol > 0:
				built_effect.append("Capitol")
				score_built += score_capitol
		if "Museum" in b:
			var score_museum = card_skill_game_over_museum(player_obj.museum_num)
			if score_museum > 0:
				built_effect.append("Museum")
				score_built += score_museum
		
				
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
	
func check_skill_has_ever_played(play_name: String) -> bool:
	var skill_ever_played = false
	if $Player.employee == "Architect":
		skill_ever_played = $Player.played_this_turn.size() < 3
	if "Stables" in play_name:
		skill_ever_played = card_skill_play_stables()
	var player_ever_played = check_rule_has_ever_played()
	return skill_ever_played or player_ever_played
	
func check_rule_has_ever_played() -> bool:
	return $Player.has_ever_played()
	
func check_skill_playable(play_name: String, built_num: int) -> bool:
	if "Monument" in play_name:
		return card_skill_can_build_monument(built_num)
	if "Secret Vault" in play_name:
		return card_skill_can_build_secret_vault()
	return true
	
func check_skill_can_end_game(player_built: Array) -> bool:
	if "Monument" in player_built:
		return card_skill_can_end_game_monument(player_built.size())
	return false
	

func on_sgin_disable_player_play() -> void:
	$Employment.hide_discard_hidden()
	$AnyCardEnlarge.reset_cards()
	$AnyCardEnlarge.reset_characters()
	$AnyCardEnlarge.set_mode(Data.CardMode.STATIC)
	$Player.hide_scripts()
	$Player.disable_play()
	
func on_sgin_enable_player_play() -> void:
	$AnyCardEnlarge.set_mode(Data.CardMode.ENLARGE)
	on_sgin_set_reminder("NOTE_PLAY")
	$Player.enable_play()


func assassin_wait() -> void:
	on_sgin_disable_player_play()	
	$Player.set_script_mode(Data.ScriptMode.ASSASSIN)
	$Employment.wait_assassin(get_assassinable_characters())


func on_sgin_assassin_once_finished(char_num: int, char_name: String) -> void:
	on_sgin_disable_player_play()
	on_sgin_set_reminder("NOTE_PLAY")
	assassinate(char_num, char_name)
	$AnyCardEnlarge.assassinate(char_name)
	yield(TweenMove, "tween_all_completed")
	$Player.set_assassinated(char_name)
	on_sgin_enable_player_play()


func on_sgin_thief_once_finished(char_num: int, char_name: String) -> void:
	on_sgin_disable_player_play()
	on_sgin_set_reminder("NOTE_PLAY")
	steal(char_num, char_name)
	$AnyCardEnlarge.steal(char_name)
	yield(TweenMove, "tween_all_completed")
	$Player.set_stolen(char_name)
	on_sgin_enable_player_play()


func thief_wait():
	on_sgin_disable_player_play()
	$Player.set_script_mode(Data.ScriptMode.THIEF)
	$Employment.wait_thief(get_stealable_characters())


func on_sgin_thief_stolen():
	var thief_obj = select_player_obj_by(Data.FindPlayerObjBy.EMPLOYEE, "Thief")
	gold_move($Player.player_num, thief_obj.player_num, $Player.gold, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	

func magician_wait():
	$Player.wait_magician()


func magician_select_deck() -> void:
	on_sgin_disable_player_play()
	for c in $Player.get_handscript_children():
		TweenMove.animate(
			[
				[c, "global_position", c.global_position, Data.DECK_POSITION, 1],
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
	on_sgin_enable_player_play()


func magician_select_player() -> void:
	$Player.hide_scripts()
	for i in range(1, opponent_length + 1):
		var opponent = select_obj_by_relative_to_first_person(i)
		opponent.set_opponent_state(Data.OpponentState.MAGICIAN_CLICKABLE)
	on_sgin_set_reminder("NOTE_MAGICIAN_SELECT_CHARACTER")
	


func on_sgin_magician_switch(switch):
	if switch == Data.MagicianSwitch.DECK:
		magician_select_deck()
	else:
		magician_select_player()


func on_sgin_magician_opponent_selected(player_num: int) -> void:
	on_sgin_disable_player_play()
	for i in range(1, opponent_length + 1):
		var opponent = select_obj_by_relative_to_first_person(i)
		opponent.set_opponent_state(Data.OpponentState.IDLE)

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
			Data.CARD_SIZE_SMALL
		)
		switch_opponent.remove_hand(card_name)

	for _i in range(switch_hands_name.size()):
		yield(Signal, "sgin_player_draw_ready")

	on_sgin_enable_player_play()

func charskill_play_passive_queen(in_turn: bool=true) -> void:
	var four_player = find_employee_4_player()
	if is_assassinated(four_player.employee_num, four_player.employee) and in_turn:
		return
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
		gold_move(Data.bank_num, first_person_num, 3, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")

func charskill_play_passive_king() -> void:
	var crown_pnum = find_crown_pnum()
	var emoloyee_4_pnum = find_employee_4_pnum()	
	var original_crown_owner = select_obj_by_player_num(crown_pnum)
	var from_pos = original_crown_owner.get_node("Crown").global_position
	
	var emoloyee_4 = select_obj_by_player_num(emoloyee_4_pnum)
	var to_pos = emoloyee_4.get_node("Crown").global_position
	var start_scale = (
		Data.CROWN_SIZE_MEDIUM
		if crown_pnum == $Player.player_num
		else Data.CROWN_SIZE_SMALL
	)
	var end_scale = (
		Data.CROWN_SIZE_MEDIUM
		if emoloyee_4_pnum == $Player.player_num
		else Data.CROWN_SIZE_SMALL
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
	var start_scale = Data.GOLD_SIZE_MEDIUM if from_pnum == $Player.player_num else Data.GOLD_SIZE_SMALL
	var end_scale = Data.GOLD_SIZE_MEDIUM if to_pnum == $Player.player_num else Data.GOLD_SIZE_SMALL
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
	if mode == Data.MerchantGold.ONE:
		$Player.disable_play()
		gold_move(Data.bank_num, $Player.player_num, 1, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")
	else:
		var gained = gain_gold_by_color("green")
		var wait = handle_resource_skill_reaction("green", gained, $Player.built)
		if wait:
			gained = yield(Signal, "sgin_all_resource_skill_reaction_completed")
		gold_move(Data.bank_num, $Player.player_num, gained, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")
		if gained == 0:
			$Player.set_employee_activated_this_turn(Data.ActivateMode.SKILL2, false)
	on_sgin_enable_player_play()


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


func on_sgin_cancel_skill(components: Array, activate_key: String="", activate_mode: int=-1, phase: int=Data.Phase.TURN) -> void:
	for component in components:
		if component == "employment":
			$Employment.hide()
		elif component == "opponent":
			for p in range(opponent_length + 1):
				var opponent = select_obj_by_relative_to_first_person(p)
				opponent.set_opponent_state(Data.OpponentState.IDLE)
		elif component == "scripts":
			$Player.hide_scripts()
		elif component == "opponent_built":
			$Player.set_opponent_built_mode(Data.OpponentBuiltMode.SHOW)
			$Player.hide_opponent_built()
		elif component == "selected":
			$Player.selected = []
		elif component == "destroy":
			destroyed = [Data.unfound, "Unchosen"]
		elif component == "built":
			$Player.rearrange_built()
			yield(TweenMove, "tween_all_completed")
		elif component == "hands":
			$Player.rearrange_hands()
			yield(TweenMove, "tween_all_completed")

		if not activate_key:
			pass
		elif activate_key == "Character":
			$Player.set_employee_activated_this_turn(activate_mode, false)
		else:
			$Player.set_card_skill_activated(activate_key, activate_mode)
	if phase == Data.Phase.TURN:
		on_sgin_enable_player_play()


func is_stolen(employee_num: int, employee_name: String) -> bool:
	return [employee_num, employee_name] == stolen


func check_reveal(employee_num: int, employee_name: String, _player_num: int) -> String:
	var sig = ""
	if is_stolen(employee_num, employee_name):
		on_sgin_thief_stolen()
		sig = "sgin_reveal_done"
	if is_number_four(employee_num) and (not is_assassinated(employee_num, employee_name)):
		charskill_play_passive_king()
	if employee_name == "Queen" and (not is_assassinated(employee_num, employee_name)):
		charskill_play_passive_queen(true)
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
	var wait = handle_resource_skill_reaction("yellow", gained, $Player.built)
	if wait:
		gained = yield(Signal, "sgin_all_resource_skill_reaction_completed")	
	gold_move(Data.bank_num, first_person_num, gained, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	if gained == 0:
		$Player.set_employee_activated_this_turn(Data.ActivateMode.ALL, false)
	on_sgin_enable_player_play()

func charskill_play_active_bishop() -> void:
	$Player.disable_play()
	var gained = gain_gold_by_color("blue")
	var wait = handle_resource_skill_reaction("blue", gained, $Player.built)
	if wait:
		gained = yield(Signal, "sgin_all_resource_skill_reaction_completed")
	gold_move(Data.bank_num, first_person_num, gained, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	if gained == 0:
		$Player.set_employee_activated_this_turn(Data.ActivateMode.ALL, false)
	on_sgin_enable_player_play()
	

func gain_gold_by_color(color: String) -> int:
	var built_color_num = $Player.built_color_num(color)	  
	return built_color_num
	

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
			opponent.set_opponent_state(Data.OpponentState.ARMORY_CLICKABLE)
		else:
			opponent.set_opponent_state(Data.OpponentState.SILENT)
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
	gold_move(first_person_num, Data.bank_num, 2, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	card_gain(first_person_num, 3, "sgin_player_draw_ready")
	yield(Signal, "sgin_player_draw_ready")
	on_sgin_enable_player_play()
	

func card_skill_play_laboratory() -> void:
	if $Player.get_card_skill_activated("Laboratory"):
		return
	$Player.wait_laboratory()


func card_skill_game_over_basilica(odd_size: int) -> int:
	return odd_size


func card_skill_game_over_wishing_well(purple_num: int) -> int:
	return purple_num


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
		gold_move(Data.bank_num, first_person_num, 1, "sgin_player_gold_ready")
		yield(Signal, "sgin_player_gold_ready")


func card_skill_game_over_haunted_quarter(player_num: int) -> void:
	hide()
	hand_over_control(player_num)
	yield(Signal, "uncover")
	show()	
	on_sgin_disable_player_play()
	on_sgin_set_reminder("NOTE_HAUNTED_QUARTER")
	$Player.wait_haunted_quarter_color()


func card_skill_play_framework(play_name: String, price: int) -> void:
	on_sgin_disable_player_play()
	on_sgin_set_reminder("NOTE_FRAMEWORK")
	$Player.set_script_mode(Data.ScriptMode.FRAMEWORK)
	$Player.show_scripts()
	var remove_framework = yield(Signal, "sgin_framework_choice")
	$Player.hide_scripts()
	if remove_framework == "yes":
		if skill_can_play(play_name, 0):
			on_sgin_disable_player_play()
			var frame_obj = $Player.get_built_obj("Framework")
			var frame_scale = frame_obj.scale
			var frame_pos = frame_obj.global_position
			card_enlarge_to_center(frame_obj, frame_pos)
			yield(Signal, "sgin_card_move_done")
			frame_obj.global_position = Data.CENTER
			center_card_shrink_to_away(frame_obj, frame_scale)
			yield(Signal, "sgin_card_move_done")
			$Player.remove_built("Framework")
			$Player.rearrange_built()
			$Deck.append("Framework")
			price = 0		
	elif remove_framework == "cancel":
		price = -1
	on_sgin_set_reminder("NOTE_PLAY")
	Signal.emit_signal("sgin_framework_reaction_completed", price)
	

func card_skill_play_thieves_den(play_name: String, price: int, gold: int) -> void:
	on_sgin_disable_player_play()
	on_sgin_set_reminder("NOTE_THIEVES_DEN")
	$Player.set_script_mode(Data.ScriptMode.THIEVES_DEN)
	$Player.show_script1()
	$Player.wait_thieves_den()
	var res = yield(Signal, "sgin_thieves_den_choice")
	var remove_hands = res[0]
	var cancel = res[1]	
	$Player.hide_scripts()
	var real_price = max(0, price - remove_hands.size())
	if cancel:
		real_price = -1
	if not skill_can_play(play_name, real_price):
		on_sgin_set_reminder("NOTE_PLAY")
		on_sgin_cancel_skill(["scripts", "hands", "selected"], "Thieves' Den", false, Data.Phase.TURN)
		Signal.emit_signal("sgin_thieves_den_reaction_completed", price)
		return 
	on_sgin_disable_player_play()
	var real_remove = min(remove_hands.size(), price)
	$Player.hide_script1()
	for i in range(real_remove):
		var h = remove_hands[i]
		var hand_obj = $Player.get_hand_obj(h)
		var hand_scale = hand_obj.scale
		var hand_pos = hand_obj.global_position
		card_enlarge_to_center(hand_obj, hand_pos)
		yield(Signal, "sgin_card_move_done")
		hand_obj.global_position = Data.CENTER
		center_card_shrink_to_away(hand_obj, hand_scale)
		yield(Signal, "sgin_card_move_done")
		$Player.remove_hand(h)
		$Deck.append(h)
	$Player.rearrange_hands()
	yield(TweenMove, "tween_all_completed")
	on_sgin_set_reminder("NOTE_PLAY")
	Signal.emit_signal("sgin_thieves_den_reaction_completed", real_price)
		
	


func card_skill_play_necropolis(_card_name: String, price: int) -> void:
	on_sgin_disable_player_play()
	on_sgin_set_reminder("NOTE_NECROPOLIS")
	$Player.set_script_mode(Data.ScriptMode.NECROPOLIS)
	$Player.show_scripts()
	var wait_remove_hand = yield(Signal, "sgin_necropolis_choice")
	$Player.hide_scripts()
	if wait_remove_hand == "yes":
		on_sgin_set_reminder("NOTE_NECROPOLIS_WAIT")
		var remove_selected = yield(Signal, "sgin_card_necropolis_selected")
		var card_obj = $Player.get_built_obj(remove_selected[0])
		var card_scale = card_obj.scale
		var card_pos = remove_selected[1]
		card_enlarge_to_center(card_obj, card_pos)
		yield(Signal, "sgin_card_move_done")
		card_obj.global_position = Data.CENTER
		center_card_shrink_to_away(card_obj, card_scale)
		yield(Signal, "sgin_card_move_done")
		$Player.remove_built(remove_selected[0])
		$Player.rearrange_built()
		$Deck.append(remove_selected[0])
		price = 0
	elif wait_remove_hand == "cancel":
		price = -1
	on_sgin_set_reminder("NOTE_PLAY")
	Signal.emit_signal("sgin_necropolis_reaction_completed", price)

func card_skill_game_over_map_room(hand_num: int) -> int:
	return hand_num


func card_skill_can_build_monument(built_num: int) -> bool:
	return built_num <= 5


func card_skill_can_end_game_monument(built_num: int) -> bool:
	return built_num >= 6


func card_skill_can_build_secret_vault() -> bool:
	return false


func card_skill_game_over_secret_vault() -> int:
	return 3


func card_skill_resource_skill_school_of_magic() -> void:
	on_sgin_set_reminder("NOTE_SCHOOL_OF_MAGIC")
	$Player.wait_school_of_magic_color()


func card_skill_game_over_capitol(
	red_num: int, blue_num: int, green_num: int, yellow_num: int, purple_num: int
) -> int:
	if red_num >= 3 or blue_num >= 3 or green_num >= 3 or yellow_num >= 3 or purple_num >= 3:
		return 3
	return 0


func card_skill_selection_theater(player_num: int) -> void:
	$Player.hide_scripts()
	hide()
	hand_over_control(player_num)
	yield(Signal, "uncover")
	show()
	on_sgin_set_reminder("NOTE_THEATER_ASK")
	$Player.wait_theater()
	var use_theater = yield(Signal, "sgin_theater_choice")
	if use_theater:
		for i in range(1, opponent_length + 1):
			var player_obj = select_obj_by_relative_to_first_person(i)
			player_obj.set_opponent_state(Data.OpponentState.THEATER_CLICKABLE)
		on_sgin_set_reminder("NOTE_THEATER")
		var selected_player = yield(Signal, "sgin_theater_opponent_selected")
		var my_employee = $Player.employee
		var my_employ_num = $Player.employee_num
		var switch_player = select_obj_by_player_num(selected_player)
		var his_employee = switch_player.employee
		var his_employ_num = switch_player.employee_num
		var temp = [my_employ_num, my_employee]
		$Player.set_employee(his_employ_num, his_employee)
		switch_player.set_employee(temp[0], temp[1])
		$AnyCardEnlarge.char_enter(temp[1], $Player/Employee.global_position, Data.CENTER, Data.CHAR_SIZE_SMALL, Data.CHAR_SIZE_BIG)
		yield(TweenMove, "tween_all_completed")
		$AnyCardEnlarge.char_enter(temp[1], Data.CENTER, switch_player.get_node("Employee").global_position, Data.CHAR_SIZE_BIG, Data.CHAR_SIZE_TINY)
		yield(TweenMove, "tween_all_completed")
		$AnyCardEnlarge.char_enter(his_employee, switch_player.get_node("Employee").global_position, Data.CENTER, Data.CHAR_SIZE_TINY, Data.CHAR_SIZE_BIG)
		yield(TweenMove, "tween_all_completed")
		$AnyCardEnlarge.char_enter(his_employee, Data.CENTER, $Player/Employee.global_position, Data.CHAR_SIZE_BIG, Data.CHAR_SIZE_SMALL)
		yield(TweenMove, "tween_all_completed")
	Signal.emit_signal("sgin_theater_reaction_completed")
	
	
	
func card_skill_play_stables() -> bool:
	return false


func card_skill_play_museum() -> void:
	if $Player.get_card_skill_activated("Museum"):
		return
	on_sgin_set_reminder("NOTE_MUSEUM")
	$Player.set_script_mode(Data.ScriptMode.MUSEUM)
	for h in $Player/HandScript.get_children():
		h.set_card_mode(Data.CardMode.MUSEUM_SELECTING)
		
func card_skill_game_over_museum(museum_num: int) -> int:
	return museum_num


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
	on_sgin_enable_player_play()

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
	if mode == Data.WarlordChoice.DESTROY:
		for p in range(opponent_length + 1):
			var opponent = select_obj_by_relative_to_first_person(p)
			if warlord_destructable(opponent.player_num, opponent.employee):
				opponent.set_opponent_state(Data.OpponentState.WARLORD_CLICKABLE)
			else:
				opponent.set_opponent_state(Data.OpponentState.SILENT)
	else:
		var gained = gain_gold_by_color("red")
		var wait = handle_resource_skill_reaction("red", gained, $Player.built)
		if wait:
			gained = yield(Signal, "sgin_all_resource_skill_reaction_completed")
		gold_move(Data.bank_num, first_person_num, gained, "sgin_player_gold_ready")
		if gained == 0:
			$Player.set_employee_activated_this_turn(Data.ActivateMode.SKILL2, false)
		on_sgin_enable_player_play()

func on_sgin_warlord_opponent_selected(player_num: int, player_employee: String, opponent_name: String, built: Array) -> void:
	$Player.set_opponent_built_mode(Data.OpponentBuiltMode.WARLORD_SHOW)
	var shown = []
	var warlord_gold = $Player.gold
	var war_opponent = select_obj_by_player_num(player_num)
	for card_name in built:
		if warlord_destructable_card(war_opponent.built, warlord_gold, card_name):
			shown.append(card_name)
	destroyed = [player_num, player_employee]
	$Player.show_opponent_built(opponent_name, shown)
	
func on_sgin_armory_opponent_selected(player_num: int, player_employee: String, opponent_name: String, built: Array) -> void:
	$Player.set_opponent_built_mode(Data.OpponentBuiltMode.ARMORY_SHOW)
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
#	var original_scale = card_obj.scale
#	card_enlarge_to_center(card_obj, from_pos)
#	yield(Signal, "sgin_card_move_done")
#	card_obj.global_position = Data.CENTER
#	center_card_shrink_to_away(card_obj, original_scale)
#	yield(Signal, "sgin_card_move_done")	
	TweenMotion.ani_card_move_center_then_away(card_obj)
#	yield(Signal, "all_ani_completed")

	$Player.remove_hand(card_name)
	$Player.rearrange_hands()
#	yield(TweenMove, "tween_all_completed")
	gold_move(Data.bank_num, first_person_num, 2, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	$Deck.append(card_name)
	$Player.set_card_skill_activated("Laboratory", true)
	on_sgin_enable_player_play()

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
	gold_move(first_person_num, Data.bank_num, price, "sgin_player_gold_ready")
	yield(Signal, "sgin_player_gold_ready")
	card_obj.on_mouse_exited()
	var original_scale = card_obj.scale
	if destroyed[0] == first_person_num:
		var c = $Player.get_built_obj(card_name)
		if c != null:
			card_move(c, c.global_position, from_pos, c.scale, original_scale, "sgin_card_move_done")
			yield(Signal, "sgin_card_move_done")
			c.set_visible(false)
#	card_enlarge_to_center(card_obj, from_pos)
#	yield(Signal, "sgin_card_move_done")
#	card_obj.global_position = Data.CENTER
#	center_card_shrink_to_away(card_obj, original_scale)
#	yield(Signal, "sgin_card_move_done")
	TweenMotion.ani_card_move_center_then_away(card_obj)
	yield(Signal, "all_ani_completed")


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
	elif "Museum" in card_name:
		card_skill_play_museum()
		

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
	card_move(card_obj, start_pos, Data.CENTER, card_obj.scale, Data.CARD_SIZE_BIG, done_signal)

func center_card_shrink_to_away(card_obj: Node, end_scale: Vector2, done_signal: String = "sgin_card_move_done") -> void:
	card_move(card_obj, Data.CENTER, Vector2(Data.CARD_END, Data.CENTER.y), Data.CARD_SIZE_BIG, end_scale, done_signal)
	




func on_sgin_card_armory_selected(card_name: String, from_pos: Vector2) -> void:	
	$AnyCardEnlarge.reset_cards()
	$AnyCardEnlarge.reset_characters()
	var card_obj = $Player.get_opponent_built_obj(card_name)
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
	
#	card_enlarge_to_center(card_obj, from_pos)
#	yield(Signal, "sgin_card_move_done")
#	center_card_shrink_to_away(card_obj, card_obj.scale)
#	yield(Signal, "sgin_card_move_done")
	
	TweenMotion.ani_card_move_center_then_away(card_obj)
	yield(Signal, "all_ani_completed")

	war_opponent.remove_built(card_name)
	$Deck.append(card_name)
	
	# remove armory
	var armory_obj = $Player.get_built_obj("Armory")
#	var armory_scale = armory_obj.scale
#	card_enlarge_to_center(armory_obj, armory_obj.global_position)
#	yield(Signal, "sgin_card_move_done")
#	armory_obj.global_position = Data.CENTER
#	center_card_shrink_to_away(armory_obj, armory_scale)

	TweenMotion.ani_card_move_center_then_away(armory_obj)
	yield(Signal, "all_ani_completed")
	
#	TweenMotion.ani_card_move_center_then_away(armory_obj)



#	yield(Signal, "sgin_card_move_done")
	$Player.remove_built("Armory")
	$Player.rearrange_built()
	$Deck.append("Armory")
#	if TweenMove.is_active():
#		yield(TweenMove, "tween_all_completed")
	
	# reset
	on_sgin_cancel_skill(["opponent", "opponent_built", "destroyed"])


func on_sgin_card_thieves_den_selected(card_name: String, _global_pos: Vector2) -> void:
	if card_name in $Player.selected:
		$Player.selected.erase(card_name)
		$Player.get_hand_obj(card_name).global_position.y += 20
	else:
		$Player.selected.append(card_name)
		$Player.get_hand_obj(card_name).global_position.y -= 20
	

func on_sgin_card_museum_selected(card_name: String, _global_position: Vector2) -> void:
	var card_obj = $Player.get_hand_obj(card_name)
	var museum_obj = $Player.get_built_obj("Museum")
	var museum_text_pos = museum_obj.global_position
	card_move(card_obj, card_obj.global_position, museum_text_pos, card_obj.scale, Data.CHAR_SIZE_TINY, "sgin_card_move_done")
	yield(Signal, "sgin_card_move_done")
	$Player.remove_hand(card_name)
	$Player.rearrange_hands()
	yield(TweenMove, "tween_all_completed")
	$Player.add_museum_num()
	museum_obj.add_museum_num()
	$Player.set_card_skill_activated("Museum", true)
	on_sgin_enable_player_play()
