extends "res://BasePlayer.gd"
enum OpponentState { IDLE, SILENT, MAGICIAN_CLICKABLE, WARLORD_CLICKABLE, ARMORY_CLICKABLE, THEATER_CLICKABLE}

const Card = preload("res://Card.tscn")
const Gold = preload("res://Money.tscn")
onready var Signal = get_node("/root/Main/Signal")
onready var TweenMove = get_node("/root/Main/Tween")
onready var Data = get_node("/root/Main/Data")

onready var opponent_state = OpponentState.IDLE
onready var bank_position = Vector2(-9999, -9999)
onready var deck_position = Vector2(-9999, -9999)
onready var original_position = Vector2(-9999, -9999)


func _ready() -> void:
	$Crown.hide()


func set_opponent_state(state: int) -> void:
	opponent_state = state


func set_bank_position(pos: Vector2) -> void:
	bank_position = pos


func set_deck_position(pos: Vector2) -> void:
	deck_position = pos


# Data : {"player_num": 1, "username": "username", "money": 0, "employee": "unknown", "hand": ["<建筑名>"], "built": ["<建筑名>"]}


func remove_built(card_name: String) -> void:
	built.erase(card_name)
	$Built/BuiltNum.text = str(built.size())


func remove_hand(card_name: String) -> void:
	hands.erase(card_name)
	$HandsInfo/HandNum.text = str(hands.size())


func draw(
	card_name: String,
	_face_is_up: bool,
	from_pos: Vector2,
	animation_time: float,
	start_scale: Vector2 = Vector2(0.175, 0.175),
	end_scale: Vector2 = Vector2(0.03, 0.03)
) -> void:
#	var card_info = Data.get_card_info(card_name)
	var incoming_card = Card.instance()
	Signal.emit_signal("sgin_opponent_draw_not_ready", incoming_card)
	var my_card_back_pos = $HandsInfo/HandBack.global_position
	add_child(incoming_card)
	incoming_card.init_card(
		"Unknown", 0, start_scale, from_pos, false, incoming_card.CardMode.ENLARGE
	)
	TweenMove.animate(
		[
			[incoming_card, "global_position", from_pos, my_card_back_pos, animation_time],
			[incoming_card, "scale", start_scale, end_scale, animation_time]
		]
	)
	hands.append(card_name)
	$HandsInfo/HandNum.text = str(hands.size())
	yield(TweenMove, "tween_all_completed")
	remove_child(incoming_card)
	incoming_card.queue_free()
	Signal.emit_signal("sgin_opponent_draw_ready", incoming_card)


#
#func on_draw_gold(from_pos: Vector2) -> void:
#	var incoming_gold = Gold.instance()
#	var my_card_back_pos = Vector2(
#		$MoneyIcon.global_position.x - 61, $MoneyIcon.global_position.y - 4
#	)
#	incoming_gold.to_coin(Vector2(1, 1), from_pos)
#	add_child(incoming_gold)
#	TweenMove.animate(
#		[
#			[
#				incoming_gold,
#				"global_position",
#				from_pos,
#				my_card_back_pos,
#			],
#			[
#				incoming_gold,
#				"scale",
#				Vector2(1, 1),
#				Vector2(1, 1),
#			],
#		]
#	)
#	gold += 1
#	$MoneyIcon/MoneyNum.text = str(gold)
#	yield(TweenMove, "tween_all_completed")
#	remove_child(incoming_gold)
#	incoming_gold.queue_free()
#	Signal.emit_signal("sgin_opponent_gold_ready")


func set_gold(money: int) -> void:
	gold = money
	$MoneyIcon/MoneyNum.text = str(money)


func on_player_info(data: Dictionary) -> void:
	player_num = data.get("player_num", -1)
	$IconUsername/Icon.animation = str("Player", player_num)
	username = data.get("username", "Unknown")
	var username_shown = "Unknown"
	if username.length() > 8:
		username_shown = username.substr(0, 8) + "..."
	else:
		username_shown = username
	$IconUsername/Username.text = username_shown
	set_gold(data.get("money", 0))
	hands = data.get("hands", hands)
	$HandsInfo/HandNum.text = str(data.get("hand_num", hands.size()))
	set_employee(data.get("employee_num", employee_num), data.get("employee", employee))
	set_hide_employee(data.get("hide_employee", hide_employee))
	var shown_employee = "Chosen" if hide_employee and employee != "Unchosen" else employee
	$Employee/Pic.animation = shown_employee
	built = data.get("built", built)
	$Built/BuiltNum.text = str(built.size())
	has_crown = data.get("has_crown", has_crown)
	set_crown(has_crown)
	if original_position == Vector2(-9999, -9999):
		original_position = position


func set_hide_employee(hide: bool) -> void:
	hide_employee = hide
	$Employee.hide_employee = hide


func set_employee(num: int, employ: String) -> void:
	employee = employ
	employee_num = num
	$Employee.employee = employ


func set_crown(with_crown: bool) -> void:
	has_crown = with_crown
	$Crown.set_visible(has_crown)


func get_my_player_info() -> Dictionary:
	return {
		"player_num": player_num,
		"username": username,
		"money": gold,
		"employee": employee,
		"employee_num": employee_num,
		"hands": hands,
		"built": built,
		"has_crown": has_crown,
		"hide_employee": hide_employee
	}


func show_employee() -> void:
	hide_employee = false
	$Employee.hide_employee = false
	$Employee/Pic.set_animation(employee)


func can_end_game() -> bool:
	return built.size() >= 7


func on_mouse_entered() -> void:
	if opponent_state in [OpponentState.MAGICIAN_CLICKABLE, OpponentState.WARLORD_CLICKABLE, OpponentState.ARMORY_CLICKABLE, OpponentState.THEATER_CLICKABLE]:
		set_position(Vector2(original_position.x, original_position.y - 20))


func on_mouse_exited() -> void:
	if opponent_state in [OpponentState.MAGICIAN_CLICKABLE, OpponentState.WARLORD_CLICKABLE, OpponentState.ARMORY_CLICKABLE, OpponentState.THEATER_CLICKABLE]:
		set_position(original_position)


func on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		on_mouse_exited()
		match opponent_state:
			OpponentState.MAGICIAN_CLICKABLE:
				Signal.emit_signal("sgin_magician_opponent_selected", player_num)
			OpponentState.WARLORD_CLICKABLE:
				Signal.emit_signal(
					"sgin_warlord_opponent_selected", player_num, employee, username, built
				)
			OpponentState.ARMORY_CLICKABLE:
				Signal.emit_signal(
					"sgin_armory_opponent_selected", player_num, employee, username, built
				)
			OpponentState.THEATER_CLICKABLE:
				Signal.emit_signal("sgin_theater_opponent_selected", player_num)


func add_gold(num: int) -> void:
	gold += num
	$MoneyIcon/MoneyNum.text = str(gold)


func on_Built_mouse_exited():
	Signal.emit_signal("sgin_hide_built")


func on_Built_input_event(_viewport, event, _shape_idx):
	if opponent_state == OpponentState.IDLE and event is InputEventMouseButton:
		Signal.emit_signal("sgin_show_built", player_num)
