extends "res://BasePlayer.gd"

const Card = preload("res://Card.tscn")
const Gold = preload("res://Money.tscn")
onready var Signal = get_node("/root/Main/Signal")
# onready var TweenMove = get_node("/root/Main/Tween")
onready var TweenMotion = get_node("/root/Main/TweenMotion")
onready var Data = get_node("/root/Main/Data")

onready var opponent_state = Data.OpponentState.IDLE
onready var original_position = Data.FAR_AWAY


func _ready() -> void:
	$Crown.hide()


func set_opponent_state(state: int) -> void:
	opponent_state = state


# Data : {"player_num": 1, "username": "username", "money": 0, "employee": "unknown", "hand": ["<建筑名>"], "built": ["<建筑名>"]}


func remove_built(card_name: String) -> void:
	built.erase(card_name)
	$Built/BuiltNum.text = str(built.size())


func remove_hand(card_name: String) -> void:
	hands.erase(card_name)
	$HandsInfo/HandNum.text = str(hands.size())


func draw(card_name: String, face_is_up: bool, from_pos: Vector2, animation_time: float, start_scale: Vector2 = Data.CARD_SIZE_MEDIUM, end_scale: Vector2 = Data.CARD_SIZE_SMALL) -> void:
	hands.append(card_name)
	var incoming_card = Card.instance()
	var my_card_back_pos = $HandsInfo/HandBack.global_position
	add_child(incoming_card)
	incoming_card.init_card("Unknown", start_scale, from_pos, false, Data.CardMode.ENLARGE)
	$HandsInfo/HandNum.text = str(hands.size())
	TweenMotion.ani_flip_move(incoming_card, my_card_back_pos, end_scale, true, face_is_up)
	remove_child(incoming_card)
	incoming_card.queue_free()


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
	if original_position == Data.FAR_AWAY:
		original_position = position
	set_museum_num(data.get("museum_num", 0))


func set_museum_num(num: int) -> void:
	museum_num = num


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


func show_employee() -> void:
	hide_employee = false
	$Employee.hide_employee = false
	$Employee/Pic.set_animation(employee)


func can_end_game() -> bool:
	return built.size() >= 7


func on_mouse_entered() -> void:
	if opponent_state in [Data.OpponentState.MAGICIAN_CLICKABLE, Data.OpponentState.WARLORD_CLICKABLE, Data.OpponentState.ARMORY_CLICKABLE, Data.OpponentState.THEATER_CLICKABLE]:
		set_position(Vector2(original_position.x, original_position.y - 20))


func on_mouse_exited() -> void:
	if opponent_state in [Data.OpponentState.MAGICIAN_CLICKABLE, Data.OpponentState.WARLORD_CLICKABLE, Data.OpponentState.ARMORY_CLICKABLE, Data.OpponentState.THEATER_CLICKABLE]:
		set_position(original_position)


func on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		on_mouse_exited()
		match opponent_state:
			Data.OpponentState.MAGICIAN_CLICKABLE:
				Signal.emit_signal("sgin_magician_opponent_selected", player_num)
			Data.OpponentState.WARLORD_CLICKABLE:
				Signal.emit_signal("sgin_warlord_opponent_selected", player_num, employee, username, built)
			Data.OpponentState.ARMORY_CLICKABLE:
				Signal.emit_signal("sgin_armory_opponent_selected", player_num, employee, username, built)
			Data.OpponentState.THEATER_CLICKABLE:
				Signal.emit_signal("sgin_theater_opponent_selected", player_num)


func add_gold(num: int) -> void:
	gold += num
	$MoneyIcon/MoneyNum.text = str(gold)


func on_Built_mouse_exited():
	Signal.emit_signal("sgin_hide_built")


func on_Built_input_event(_viewport, event, _shape_idx):
	if opponent_state == Data.OpponentState.IDLE and event is InputEventMouseButton:
		Signal.emit_signal("sgin_show_built", player_num)
