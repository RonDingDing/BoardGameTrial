extends Node2D

const Card = preload("res://Card.tscn")
const Gold = preload("res://Money.tscn")
onready var Signal = get_node("/root/Main/Signal")
onready var TweenMove = get_node("/root/Main/Tween")
onready var Data = get_node("/root/Main/Data")

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
onready var center = get_viewport_rect().size / 2


func set_bank_position(pos: Vector2) -> void:
	bank_position = pos


func set_deck_position(pos: Vector2) -> void:
	deck_position = pos

func player_draw_built(mode: String, card_name: String, from_pos: Vector2, face_is_up: bool, animation_time: float) -> void:
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
	incoming_card.init_card(
		card_name, card_info["up_offset"], Vector2(0.175, 0.175), from_pos, true, false
	)
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
		[
			incoming_card.get_node("Back"),
			"visible",
			true,
			not face_is_up,
			animation_time
		],
		[
			incoming_card.get_node("Face"),
			"visible",
			false,
			face_is_up,
			animation_time
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

	rearrange(node, positions, animation_time + 0.01)
	yield(TweenMove, "tween_all_completed")
	Signal.emit_signal(ready_signal, incoming_card)



func draw(card_name: String, face_is_up: bool, from_pos: Vector2, animation_time: float) -> void:
	player_draw_built("hands", card_name, from_pos, face_is_up, animation_time)
	 

func rearrange(node: Node, positions: Array, animation_time: float) -> void:
	var hands_obj = node.get_children()
	for index in range(hands_obj.size()):
		var each_card = hands_obj[index]
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


func gold_transfer(
	from_pos: Vector2,
	to_pos: Vector2,
	start_scale: Vector2,
	end_scale: Vector2,
	callback_signal: String,
	add_num: int
) -> void:
	var incoming_gold = Gold.instance()
	incoming_gold.to_coin(start_scale, from_pos)
	add_child(incoming_gold)
	TweenMove.animate(
		[
			[
				incoming_gold,
				"global_position",
				from_pos,
				to_pos,
			],
			[
				incoming_gold,
				"scale",
				start_scale,
				end_scale,
			],
		]
	)
	TweenMove.start()
	gold += add_num
	$MoneyNum.text = str(gold)
	yield(TweenMove, "tween_all_completed")
	remove_child(incoming_gold)
	incoming_gold.queue_free()
	Signal.emit_signal(callback_signal)


func on_sgout_player_obj_pay(to_pos: Vector2) -> void:
	gold_transfer(
		$GoldImg.global_position, to_pos, Vector2(2, 2), Vector2(1, 1), "sgin_player_pay_ready", -1
	)


func on_draw_gold(from_pos: Vector2) -> void:
	gold_transfer(
		from_pos,
		$GoldImg.global_position,
		Vector2(1, 1),
		Vector2(2, 2),
		"sgin_player_gold_ready",
		1
	)


func disable_enlarge() -> void:
	for a in $HandScript.get_children():
		a.set_mode(a.Mode.STATIC)
	for a in $BuiltScript.get_children():
		a.set_mode(a.Mode.STATIC)


func enable_enlarge() -> void:
	for a in $HandScript.get_children():
		a.set_mode(a.Mode.ENLARGE)
	for a in $BuiltScript.get_children():
		a.set_mode(a.Mode.ENLARGE)


func enable_enlarge_play() -> void:
	for a in $HandScript.get_children():
		a.set_mode(a.Mode.PLAY)
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
	gold = data.get("money", 0)
	$MoneyNum.text = str(gold)
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


func build(card_name: String, from_pos: Vector2, animation_time:float  ) -> void:
	player_draw_built("built", card_name, from_pos, true, animation_time)


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
	var enough_money = gold >= price
	return enough_money


func has_not_played(card_name: String) -> bool:
	var not_played = not card_name in played_this_turn
	return not_played

func has_ever_played()-> bool:
	return played_this_turn.size() < 1

func on_sgin_card_played(card_name: String, from_pos: Vector2) -> void:
	var card_info = Data.get_card_info(card_name)
	var _suceeded = false
	var price = card_info["star"]
	var enough_money = has_enough_money(price)
	var not_played = has_not_played(card_name)
	var not_ever_played = has_ever_played()
	if not (enough_money and not_played and not_ever_played):
		return
	_suceeded = true
	played_this_turn.append(card_name)
	var card_obj
	for c in $HandScript.get_children():
		if c.card_name == card_name and c.global_position == from_pos:
			card_obj = c
			break

	if card_obj == null:
		return

	for _i in range(price):
		on_sgout_player_obj_pay(bank_position)
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
	enable_enlarge_play()
	rearrange($HandScript, get_hand_positions_with_new_card(),1)
	rearrange($BuiltScript, get_built_positions_with_new_card(),1)
	yield(TweenMove, "tween_all_completed")


func after_end_turn() -> void:
	played_this_turn = []
	
func can_end_game() -> bool:
	return built.size() >= 7
