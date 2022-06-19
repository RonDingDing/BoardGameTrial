extends "res://BasePlayer.gd"
enum OpponentState { IDLE, CLICKABLE }

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

func set_clickable(able: bool) -> void:
	opponent_state = OpponentState.CLICKABLE if able else OpponentState.IDLE


func set_bank_position(pos: Vector2) -> void:
	bank_position = pos


func set_deck_position(pos: Vector2) -> void:
	deck_position = pos


# Data : {"player_num": 1, "username": "username", "money": 0, "employee": "unknown", "hand": ["<建筑名>"], "built": ["<建筑名>"]}


func remove_hand_name(card_name: String) -> void:
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
	incoming_card.init_card("Unknown", 0, start_scale, from_pos, false, false)
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
	set_employee(data.get("employee", employee))
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


func set_employee(employ: String) -> void:
	employee = employ
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
	if opponent_state == OpponentState.CLICKABLE:
		set_position(Vector2(original_position.x, original_position.y - 20))


func on_mouse_exited() -> void:
	if opponent_state == OpponentState.CLICKABLE:
		set_position(original_position)


func on_input_event(_viewport, event, _shape_idx):
	if opponent_state == OpponentState.CLICKABLE and event is InputEventMouseButton:
		on_mouse_exited()
		Signal.emit_signal("sgin_magician_opponent_selected", player_num)

func add_gold(num: int) -> void:
	gold += num
	$MoneyIcon/MoneyNum.text = str(gold)
