extends "res://BasePlayer.gd"
const deck_num = -1
const bank_num = -2
const unfound = -3

const Card = preload("res://Card.tscn")
const Gold = preload("res://Money.tscn")
onready var Signal = get_node("/root/Main/Signal")
onready var TweenMove = get_node("/root/Main/Tween")
onready var TimerGlobal = get_node("/root/Main/Timer")
onready var Data = get_node("/root/Main/Data")

onready var played_this_turn = []

onready var bank_position = Vector2(-9999, -9999)
onready var deck_position = Vector2(-9999, -9999)
onready var center = get_viewport_rect().size / 2

enum Need { GOLD, CARD }
enum MagicianSwitch { DECK, PLAYER }
enum MerchantGold { ONE, GREEN }
enum ScriptMode { RESOURCE, MAGICIAN, MERCHANT }
enum OpponentBuiltMode { SHOW, WARLORD_SHOW }
onready var script1_pos = $Script1.rect_position
onready var script2_pos = $Script2.rect_position
onready var end_turn_pos = $EndTurn.rect_position
onready var can_end = false
onready var script_mode = ScriptMode.RESOURCE
onready var opponent_built_mode = OpponentBuiltMode.SHOW

const gray = Color(0.76171875, 0.76171875, 0.76171875)
const yellow = Color(1, 1, 0)
const white = Color(1, 1, 1)


func _ready() -> void:
	hide_scripts()
	hide_end_turn()
	hide_kill_steal_info()
	hide_opponent_built()
	$Script1.rect_position = script1_pos
	$Script1Label.rect_position = Vector2(script1_pos.x + 25, script1_pos.y + 28)
	$Script2.rect_position = script2_pos
	$Script2Label.rect_position = Vector2(script2_pos.x + 25, script2_pos.y + 28)
	$EndTurn.rect_position = end_turn_pos
	$EndTurnLabel.rect_position = Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28)


func set_script_mode(mode: int) -> void:
	script_mode = mode
	if mode == ScriptMode.RESOURCE:
		$Script1Label.text = "NOTE_NEED_GOLD"
		$Script2Label.text = "NOTE_NEED_CARD"
	elif mode == ScriptMode.MAGICIAN:
		$Script1Label.text = "NOTE_FROM_DECK"
		$Script2Label.text = "NOTE_FROM_PLAYER"
	elif mode == ScriptMode.MERCHANT:
		$Script1Label.text = "NOTE_GAIN_1"
		$Script2Label.text = "NOTE_GAIN_GREEN"
	elif mode == ScriptMode.WARLORD:
		$Script1Label.text = "NOTE_WARLORD_DESTROY"
		$Script2Label.text = "NOTE_GAIN_RED"


func set_assassinated(char_name: String) -> void:
	$KillStealInfo/KillChar/Pic.animation = char_name
	$KillStealInfo.show()
	$KillStealInfo/KillChar.show()
	$KillStealInfo/KillSword.show()


func set_stolen(char_name: String) -> void:
	$KillStealInfo/StealChar/Pic.animation = char_name
	$KillStealInfo.show()
	$KillStealInfo/StealChar.show()
	$KillStealInfo/StealPocket.show()


func set_reminder_text(string: String) -> void:
	$ReminderLabel.text = string


func hide_kill_steal_info() -> void:
	$KillStealInfo.hide()
	$KillStealInfo/StealChar.hide()
	$KillStealInfo/StealPocket.hide()


func show_reminder() -> void:
	$ReminderBackground.show()
	$ReminderLabel.show()


func hide_reminder() -> void:
	$ReminderBackground.hide()
	$ReminderLabel.hide()


func show_end_turn() -> void:
	$EndTurn.show()
	$EndTurnLabel.show()


func hide_end_turn() -> void:
	$EndTurn.hide()
	$EndTurnLabel.hide()


func show_scripts() -> void:
	$Script2.show()
	$Script2Label.show()
	$Script1.show()
	$Script1Label.show()


func hide_scripts() -> void:
	$Script1.hide()
	$Script1Label.hide()
	$Script2.hide()
	$Script2Label.hide()


func on_end_turn_pressed() -> void:
	if can_end:
		Signal.emit_signal("sgin_end_turn")
		$EndTurn.rect_position = end_turn_pos
		$EndTurnLabel.rect_position = Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28)


func on_script1_pressed() -> void:
	if script_mode == ScriptMode.RESOURCE:
		Signal.emit_signal("sgin_resource_need", Need.GOLD)
	elif script_mode == ScriptMode.MAGICIAN:
		Signal.emit_signal("sgin_magician_switch", MagicianSwitch.DECK)
	elif script_mode == ScriptMode.MERCHANT and not $Employee.skill_1_activated_this_turn:
		Signal.emit_signal("sgin_merchant_gold", MerchantGold.ONE)
		$Employee.set_activated_this_turn($Employee.ActivateMode.SKILL1, true)
	$Script1.rect_position = script1_pos
	$Script1Label.rect_position = Vector2(script1_pos.x + 25, script1_pos.y + 28)


func on_script2_pressed() -> void:
	if script_mode == ScriptMode.RESOURCE:
		Signal.emit_signal("sgin_resource_need", Need.CARD)
	elif script_mode == ScriptMode.MAGICIAN:
		Signal.emit_signal("sgin_magician_switch", MagicianSwitch.PLAYER)
	elif script_mode == ScriptMode.MERCHANT and not $Employee.skill_2_activated_this_turn:
		Signal.emit_signal("sgin_merchant_gold", MerchantGold.GREEN)
		$Employee.set_activated_this_turn($Employee.ActivateMode.SKILL2, true)
	$Script2.rect_position = script2_pos
	$Script2Label.rect_position = Vector2(script2_pos.x + 25, script2_pos.y + 28)


func on_end_turn_mouse_entered() -> void:
	if can_end:
		$EndTurn.set_position(Vector2(end_turn_pos.x, end_turn_pos.y - 20))
		$EndTurnLabel.set_position(Vector2(end_turn_pos.x + 25, end_turn_pos.y + 8))


func on_end_turn_mouse_exited() -> void:
	if can_end:
		$EndTurn.set_position(end_turn_pos)
		$EndTurnLabel.set_position(Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28))


func on_script2_mouse_entered() -> void:
	if script_mode == ScriptMode.MERCHANT and $Employee.skill_2_activated_this_turn:
		return

	$Script2.set_position(Vector2(script2_pos.x, script2_pos.y - 20))
	$Script2Label.set_position(Vector2(script2_pos.x + 25, script2_pos.y + 8))


func on_script2_mouse_exited() -> void:
	if script_mode == ScriptMode.MERCHANT and $Employee.skill_2_activated_this_turn:
		return
	$Script2.set_position(script2_pos)
	$Script2Label.set_position(Vector2(script2_pos.x + 25, script2_pos.y + 28))


func on_script1_mouse_entered() -> void:
	if script_mode == ScriptMode.MERCHANT and $Employee.skill_1_activated_this_turn:
		return
	$Script1.set_position(Vector2(script1_pos.x, script1_pos.y - 20))
	$Script1Label.set_position(Vector2(script1_pos.x + 25, script1_pos.y + 8))


func on_script1_mouse_exited() -> void:
	if script_mode == ScriptMode.MERCHANT and $Employee.skill_1_activated_this_turn:
		return
	$Script1.set_position(script1_pos)
	$Script1Label.set_position(Vector2(script1_pos.x + 25, script1_pos.y + 28))


func wait_magician() -> void:
	disable_play()
	set_script_mode(ScriptMode.MAGICIAN)
	Signal.emit_signal("sgin_set_reminder", "NOTE_MAGICIAN")
	show_scripts()


func wait_merchant() -> void:
	disable_play()
	set_script_mode(ScriptMode.MERCHANT)
	Signal.emit_signal("sgin_set_reminder", "NOTE_MERCHANT")
	show_scripts()
	var color
	if $Employee.skill_1_activated_this_turn:
		color = gray
	else:
		color = yellow
	$Script1Label.set("custom_colors/font_color", color)
	if $Employee.skill_2_activated_this_turn:
		color = gray
	else:
		color = white
	$Script2Label.set("custom_colors/font_color", color)


func set_bank_position(pos: Vector2) -> void:
	bank_position = pos


func set_deck_position(pos: Vector2) -> void:
	deck_position = pos


func player_draw_built(
	mode: String,
	card_name: String,
	from_pos: Vector2,
	face_is_up: bool,
	animation_time: float,
	start_scale: Vector2,
	end_scale: Vector2
) -> void:
	var list
	var node
	var not_ready_signal
	var ready_signal
	if mode == "hands":
		list = hands
		node = $HandScript
		not_ready_signal = "sgin_player_draw_not_ready"
		ready_signal = "sgin_player_draw_ready"
	else:
		list = built
		node = $BuiltScript
		not_ready_signal = "sgin_player_built_not_ready"
		ready_signal = "sgin_player_built_ready"

	var card_info = Data.get_card_info(card_name)
	var incoming_card = Card.instance()
	list.append(card_name)
	node.add_child(incoming_card)
	incoming_card.init_card(card_name, card_info["up_offset"], start_scale, from_pos, true, false)
	Signal.emit_signal(not_ready_signal, incoming_card)
	var positions = get_positions_with_new_card(node)
	var action_list = [
		[
			incoming_card,
			"global_position",
			from_pos,
			positions[-1] + $HandScript.global_position,
			animation_time
		],
		[incoming_card, "scale", start_scale, end_scale, animation_time],
		[incoming_card.get_node("Back"), "visible", true, not face_is_up, animation_time],
		[incoming_card.get_node("Face"), "visible", false, face_is_up, animation_time],
	]
	if face_is_up:
		action_list.insert(
			1,
			[
				incoming_card,
				"scale:y",
				incoming_card.scale.y,
				0.01,
				animation_time / 2,
			]
		)
		action_list.insert(
			2,
			[
				incoming_card,
				"scale:y",
				0.01,
				incoming_card.scale.y,
				animation_time / 2,
			]
		)
	TweenMove.animate(action_list)

	rearrange(node, positions, animation_time + 0.01)
	yield(TweenMove, "tween_all_completed")
	Signal.emit_signal(ready_signal, incoming_card)


func draw(
	card_name: String,
	face_is_up: bool,
	from_pos: Vector2,
	animation_time: float,
	start_scale: Vector2 = Vector2(0.175, 0.175),
	end_scale: Vector2 = Vector2(0.175, 0.175)
) -> void:
	player_draw_built(
		"hands", card_name, from_pos, face_is_up, animation_time, start_scale, end_scale
	)


func rearrange(node: Node, positions: Array, animation_time: float) -> void:
	var hands_obj = node.get_children()
	for index in range(hands_obj.size()):
		var each_card = hands_obj[index]
		if animation_time > 0:
			TweenMove.animate(
				[
					[
						each_card,
						"global_position",
						each_card.global_position,
						positions[index] + node.global_position,
						animation_time
					]
				]
			)
		else:
			each_card.global_position = positions[index] + node.global_position


func get_positions_with_new_card(obj: Node) -> Array:
	var positions = []
	var start = -200
	var end = 200
	var hands_obj = obj.get_children()
	var hand_num = hands_obj.size()

	if hand_num <= 4:
		for i in range(hand_num):
			positions.append(Vector2(start + 132 * i, 0))
	else:
		for i in range(hand_num):
			positions.append(Vector2(start + (end - start) / (hand_num - 1) * i, 0))
	return positions


func get_hand_positions_with_new_card() -> Array:
	return get_positions_with_new_card($HandScript)


func get_built_positions_with_new_card() -> Array:
	return get_positions_with_new_card($BuiltScript)


#func on_draw_gold(from_pos: Vector2) -> void:
#	gold_transfer(
#		from_pos,
#		$MoneyIcon.global_position,
#		Vector2(1, 1),
#		Vector2(2, 2),
#		"sgin_player_gold_ready",
#		1
#	)


func disable_enlarge() -> void:
	for a in $HandScript.get_children():
		a.set_card_mode(a.CardMode.STATIC)
	for a in $BuiltScript.get_children():
		a.set_card_mode(a.CardMode.STATIC)


func enable_enlarge() -> void:
	for a in $HandScript.get_children():
		a.set_card_mode(a.CardMode.ENLARGE)
	for a in $BuiltScript.get_children():
		a.set_card_mode(a.CardMode.ENLARGE)


func disable_play() -> void:
	$Employee.set_can_skill(false)
	for a in $HandScript.get_children():
		a.set_card_mode(a.CardMode.ENLARGE)
	for a in $BuiltScript.get_children():
		a.set_card_mode(a.CardMode.ENLARGE)
	can_end = false
	$EndTurnLabel.set("custom_colors/font_color", gray)


func enable_play() -> void:
	$Employee.set_can_skill(true)
	for a in $HandScript.get_children():
		a.set_card_mode(a.CardMode.PLAY)
	for a in $BuiltScript.get_children():
		a.set_card_mode(a.CardMode.ENLARGE)
	can_end = true
	var color = Color(1, 0, 0)
	$EndTurnLabel.set("custom_colors/font_color", color)


func set_gold(money: int) -> void:
	gold = money
	$MoneyNum.text = str(money)


func on_player_info(data: Dictionary) -> void:
	player_num = data.get("player_num", -1)
	$Icon.animation = str("Player", player_num)
	username = data.get("username", "Unknown")
	var username_shown = "Unknown"
	if username.length() > 8:
		username_shown = username.substr(0, 8) + "..."
	else:
		username_shown = username
	$Username.text = username_shown
	set_gold(data.get("money", 0))
	set_employee(data.get("employee", employee))
	set_hide_employee(data.get("hide_employee", hide_employee))
	has_crown = data.get("has_crown", has_crown)
	$Crown.set_visible(has_crown)

	hands = []
	built = []
	for i in $HandScript.get_children():
		$HandScript.remove_child(i)
		i.queue_free()
	for n in $BuiltScript.get_children():
		$BuiltScript.remove_child(n)
		n.queue_free()
	for c in data.get("hands", []):
		draw(c, true, deck_position, 0)
	enable_enlarge()
	for b in data.get("built", []):
		build(b, deck_position, 0)


func build(
	card_name: String,
	from_pos: Vector2,
	animation_time: float,
	start_scale: Vector2 = Vector2(0.175, 0.175),
	end_scale: Vector2 = Vector2(0.175, 0.175)
) -> void:
	player_draw_built("built", card_name, from_pos, true, animation_time, start_scale, end_scale)


func get_my_player_info() -> Dictionary:
	return {
		"player_num": player_num,
		"username": username,
		"money": gold,
		"employee": employee,
		"hands": hands,
		"built": built,
		"has_crown": has_crown,
		"hide_employee": hide_employee
	}


func set_hide_employee(hide: bool) -> void:
	hide_employee = hide
	$Employee.hide_employee = hide


func set_employee(employ: String) -> void:
	employee = employ
	$Employee.employee = employ
	$Employee/Pic.set_animation(employ)


func show_employee() -> void:
	hide_employee = false
	$Employee.hide_employee = false
	$Employee/Pic.set_animation(employee)


func set_crown(with_crown: bool) -> void:
	has_crown = with_crown
	$Crown.set_visible(has_crown)


func has_enough_money(price: int) -> bool:
	var enough_money = gold >= price
	return enough_money


func has_not_played_same(card_name: String) -> bool:
	var not_played = not card_name in played_this_turn
	return not_played


func has_ever_played() -> bool:
	return played_this_turn.size() < 1


func card_played(card_name: String, price: int, from_pos: Vector2) -> void:
	disable_play()
	played_this_turn.append(card_name)
	var card_obj
	for c in $HandScript.get_children():
		if c.card_name == card_name and c.global_position == from_pos:
			card_obj = c
			break

	if card_obj == null:
		enable_play()
		return false

	for _i in range(price):
		Signal.emit_signal("sgin_gold_transfer", player_num, bank_num, "sgin_player_pay_ready")
		yield(Signal, "sgin_player_pay_ready")

	hands.erase(card_name)
	built.append(card_name)
	$HandScript.remove_child(card_obj)
	$BuiltScript.add_child(card_obj)
	card_obj.on_mouse_exited()
	var z_index = card_obj.z_index
	card_obj.z_index = 4096
	var original_scale = card_obj.scale
	disable_enlarge()
	TweenMove.animate(
		[
			[card_obj, "global_position", from_pos, center],
			[card_obj, "scale", original_scale, Vector2(0.6, 0.6)],
		]
	)
	yield(TweenMove, "tween_all_completed")
	TweenMove.animate(
		[
			[
				card_obj,
				"global_position",
				center,
				$BuiltScript.global_position + get_built_positions_with_new_card()[-1]
			],
			[card_obj, "scale", Vector2(0.6, 0.6), original_scale],
		]
	)
	yield(TweenMove, "tween_all_completed")
	card_obj.z_index = z_index
	rearrange($HandScript, get_hand_positions_with_new_card(), 1)
	rearrange($BuiltScript, get_built_positions_with_new_card(), 1)
	yield(TweenMove, "tween_all_completed")
	enable_play()
	Signal.emit_signal("sgin_card_played_finished", card_name)


func after_end_turn() -> void:
	played_this_turn = []


func can_end_game() -> bool:
	return built.size() >= 7


func clear_hands() -> void:
	hands = []
	for c in $HandScript.get_children():
		$HandScript.remove_child(c)


func shuffle_hands() -> void:
	hands.shuffle()


func remove_hand(card_obj: Node) -> void:
	$HandScript.remove_child(card_obj)
	hands.erase(card_obj.card_name)


func set_all_activated_this_turn(can: bool) -> void:
	$Employee.set_activated_this_turn($Employee.ActivateMode.ALL, can)


func reset_script_color() -> void:
	$Script1Label.set("custom_colors/font_color", yellow)
	$Script2Label.set("custom_colors/font_color", white)


func add_gold(num: int) -> void:
	gold += num
	$MoneyNum.text = str(gold)


func built_color_num(color: String) -> int:
	var num = 0
	for card_name in built:
		if color == Data.get_card_info(card_name)["kind"]:
			num += 1
	return num

func show_opponent_built(name: String, cards: Array) -> void:
	if can_end:
		for c in $OpponentBuilt.get_children():
			$OpponentBuilt.remove_child(c)
		var start_scale = Vector2(0.175, 0.175)
		var from_pos = Vector2(0, 0)
		
		for card_name in cards:
			var card_info = Data.get_card_info(card_name)
			var incoming_card = Card.instance()
			$OpponentBuilt.add_child(incoming_card)
			incoming_card.init_card(card_name, card_info["up_offset"], start_scale, from_pos, true, false)
		var positions = get_positions_with_new_card($OpponentBuilt)
		rearrange($OpponentBuilt, positions, 0)
			
		$OpponentBuilt.show()
		$OpponentBuiltName.show()
		$OpponentBuiltNameText.text = name
		$OpponentBuiltNameText.show()

func hide_opponent_built() -> void:
	$OpponentBuilt.hide()
	$OpponentBuiltName.hide()
	$OpponentBuiltNameText.hide()
