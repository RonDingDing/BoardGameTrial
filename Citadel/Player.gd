extends Node2D

const Card = preload("res://Card.tscn")
const Gold = preload("res://Money.tscn")
onready var Signal = get_node("/root/Main/Signal")
onready var TweenMove = get_node("/root/Main/Tween")

onready var hands = []
onready var built = []
onready var player_num = -1
onready var gold = 0
onready var username = "Unknown"
onready var employee = "Unchosen"
onready var has_crown = false
onready var hide_employee = true
onready var played_this_turn = []

onready var bank_position = Vector2(-9999, -9999)
onready var deck_position = Vector2(-9999, -9999)


func set_bank_position(pos: Vector2) -> void:
	bank_position = pos


func set_deck_position(pos: Vector2) -> void:
	deck_position = pos


func on_sgout_player_draw(card_info: Dictionary, from_pos: Vector2, face_is_up: bool) -> void:
	var incoming_card = Card.instance()
	hands.append(card_info)
	$HandScript.add_child(incoming_card)
	incoming_card.init_card(
		card_info["card_name"], card_info["up_offset"], Vector2(0.175, 0.175), from_pos, true, false
	)
	Signal.emit_signal("sgin_player_draw_not_ready", incoming_card)
	var positions = get_hand_positions_with_new_card()
	var animation_time = 0.1

	var action_list = [
		[
			incoming_card,
			"global_position",
			from_pos,
			positions[-1] + $HandScript.global_position,
		],
		[
			incoming_card.get_node("Back"),
			"visible",
			true,
			not face_is_up,
		],
		[
			incoming_card.get_node("Face"),
			"visible",
			false,
			face_is_up,
		]
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
	var hands_obj = $HandScript.get_children()

	for index in range(hands_obj.size()):
		var each_card = hands_obj[index]
		TweenMove.animate(
			[
				[
					each_card,
					"global_position",
					each_card.global_position,
					positions[index] + $HandScript.global_position,
				]
			]
		)
	yield(TweenMove, "tween_all_completed")
	Signal.emit_signal("sgin_player_draw_ready", incoming_card)


func get_hand_positions_with_new_card() -> Array:
	var positions = []
	var start = -200
	var end = 200
	var hands_obj = $HandScript.get_children()
	var hand_num = hands_obj.size()

	if hand_num <= 4:
		for i in range(hand_num):
			positions.append(Vector2(start + 120 * i, 0))
	else:
		for i in range(hand_num):
			positions.append(Vector2(start + (end - start) / (hand_num - 1) * i, 0))
	return positions


func on_sgout_player_obj_gold(from_pos: Vector2) -> void:
	var incoming_gold = Gold.instance()
	var my_card_back_pos = $GoldImg.global_position
	incoming_gold.to_coin(Vector2(1, 1), Vector2(-9999999, -9999999))
	add_child(incoming_gold)
	TweenMove.animate(
		[
			[
				incoming_gold,
				"global_position",
				from_pos,
				my_card_back_pos,
			],
			[
				incoming_gold,
				"scale",
				Vector2(1, 1),
				Vector2(2, 2),
			],
		]
	)
	yield(TweenMove, "tween_all_completed")
	gold += 1
	$MoneyNum.text = str(gold)
	remove_child(incoming_gold)
	incoming_gold.queue_free()
	Signal.emit_signal("sgin_player_gold_ready")


func enable_enlarge() -> void:
	for a in $HandScript.get_children():
		a.set_mode(a.Mode.ENLARGE)
	for a in $BuiltScript.get_children():
		a.set_mode(a.Mode.ENLARGE)


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
	$MoneyNum.text = str(data.get("money", 0))
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
		on_sgout_player_draw(c, deck_position, true)
	enable_enlarge()
	for b in data.get("built", []):
		on_sgout_player_built(b, deck_position)


func on_sgout_player_built(_card_info: Dictionary, _from_pos: Vector2) -> void:
	pass


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


func enable_play() -> void:
	for a in $HandScript.get_children():
		a.set_mode(a.Mode.PLAY)


func has_enough_money(price: int) -> bool:
	var enough_money = (gold >= price)
	return enough_money


func has_not_played(card_name: String) -> bool:
	var not_played = (not card_name in played_this_turn)
	return not_played


func on_sgin_card_played(card_info: Dictionary) -> void:
	var card_name = card_info["card_name"]
	var _suceeded = false
	var enough_money = has_enough_money(card_info["star"])
	var not_played = has_not_played(card_name)
	if not(enough_money and not_played):
		return
	_suceeded = true
	played_this_turn.append(card_name)
	var card_obj
	for c in $HandScript.get_children():
		if c.card_name == card_name:
			card_obj = c
			break
	if card_obj == null:
		return
		
			
	print("xxx",$HandScript.find_node(card_name))
		 
