extends "res://BasePlayer.gd"
const Card = preload("res://Card.tscn")
const Gold = preload("res://Money.tscn")
onready var Signal = get_node("/root/Main/Signal")
#onready var TweenMove = get_node("/root/Main/Tween")
onready var TweenMotion = get_node("/root/Main/TweenMotion")
onready var TimerGlobal = get_node("/root/Main/Timer")
onready var Data = get_node("/root/Main/Data")

onready var played_this_turn = []
onready var selected = []


onready var script1_pos = $Script1.rect_position
onready var script2_pos = $Script2.rect_position
onready var end_turn_pos = $Script3.rect_position
onready var built_script_pos = $BuiltScript.global_position
onready var script_mode = Data.ScriptMode.RESOURCE
onready var opponent_built_mode = Data.OpponentBuiltMode.SHOW
onready var opponent_state = Data.OpponentState.IDLE
onready var color_mode = Data.ColorMode.HAUNTED_QUARTER_SELECTABLE
onready var card_skill_activated = {"Smithy": false, "Laboratory": false, "Museum": false}


func _ready() -> void:
	hide_scripts()
	hide_script3()
	hide_kill_steal_info()
	hide_opponent_built()
	hide_color_choose()
	$Script1.rect_position = script1_pos
	$Script1Label.rect_position = Vector2(script1_pos.x + 25, script1_pos.y + 28)
	$Script2.rect_position = script2_pos
	$Script2Label.rect_position = Vector2(script2_pos.x + 25, script2_pos.y + 28)
	$Script3.rect_position = end_turn_pos
	$Script3Label.rect_position = Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28)


func get_card_skill_activated(skill_name: String) -> bool:
	return card_skill_activated[skill_name]


func set_card_skill_activated(skill_name: String, val: bool) -> void:
	card_skill_activated[skill_name] = val


func reset_all_card_skill_activated() -> void:
	for k in card_skill_activated.keys():
		card_skill_activated[k] = false


func set_opponent_state(state: int) -> void:
	opponent_state = state


func set_script_mode(mode: int) -> void:
	var color1 = Data.WHITE
	var color2 = Data.WHITE
	var color3 = Data.WHITE
	script_mode = mode
	match mode:
		Data.ScriptMode.RESOURCE:
			$Script1Label.text = "NOTE_NEED_GOLD"
			$Script2Label.text = "NOTE_NEED_CARD"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.WHITE
			color2 = Data.WHITE
			color3 = Data.WHITE
		Data.ScriptMode.ASSASSIN:
			$Script1Label.text = "NOTE_NEED_GOLD"
			$Script2Label.text = "NOTE_NEED_CARD"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.WHITE_SMOKE
			color2 = Data.WHITE_SMOKE
			color3 = Data.WHITE_SMOKE
		Data.ScriptMode.THIEF:
			$Script1Label.text = "NOTE_NEED_GOLD"
			$Script2Label.text = "NOTE_NEED_CARD"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.BASKET_BALL_ORANGE
			color2 = Data.BASKET_BALL_ORANGE
			color3 = Data.BASKET_BALL_ORANGE
		Data.ScriptMode.MAGICIAN:
			$Script1Label.text = "NOTE_FROM_DECK"
			$Script2Label.text = "NOTE_FROM_PLAYER"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.PALATINATE_PURPLE
			color2 = Data.DARK_LILAC
			color3 = Data.GRAPE_PURPLE
		Data.ScriptMode.MERCHANT:
			$Script1Label.text = "NOTE_GAIN_1"
			$Script2Label.text = "NOTE_GAIN_GREEN"
			$Script3Label.text = "NOTE_CANCEL"
			if $Employee.skill_1_activated_this_turn:
				color1 = Data.GRAY
			else:
				color1 = Data.SHAMROCK_GREEN
			if $Employee.skill_2_activated_this_turn:
				color2 = Data.GRAY
			else:
				color2 = Data.GREEN_TEAL
			color3 = Data.GREEN
		Data.ScriptMode.WARLORD:
			$Script1Label.text = "NOTE_WARLORD_DESTROY"
			$Script2Label.text = "NOTE_GAIN_RED"
			$Script3Label.text = "NOTE_CANCEL"
			if $Employee.skill_1_activated_this_turn:
				color1 = Data.GRAY
			else:
				color1 = Data.VENETIAN_RED
			if $Employee.skill_2_activated_this_turn:
				color2 = Data.GRAY
			else:
				color2 = Data.CHERRY
			color3 = Data.RED
		Data.ScriptMode.PLAYING:
			$Script1Label.text = "NOTE_NEED_GOLD"
			$Script2Label.text = "NOTE_NEED_CARD"
			$Script3Label.text = "NOTE_END_TURN"
			color1 = Data.WHITE_LILAC
			color2 = Data.WHITE_LILAC
			color3 = Data.WHITE_LILAC
		Data.ScriptMode.NOT_PLAYING:
			$Script1Label.text = "NOTE_NEED_GOLD"
			$Script2Label.text = "NOTE_NEED_CARD"
			$Script3Label.text = "NOTE_END_TURN"
			color1 = Data.WHITE_LILAC
			color2 = Data.WHITE_LILAC
			color3 = Data.GRAY
		Data.ScriptMode.ARMORY:
			$Script1Label.text = "NOTE_NEED_GOLD"
			$Script2Label.text = "NOTE_NEED_CARD"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.WHITE_LILAC
			color2 = Data.WHITE_LILAC
			color3 = Data.RED
		Data.ScriptMode.LABORATORY:
			$Script1Label.text = "NOTE_NEED_GOLD"
			$Script2Label.text = "NOTE_NEED_CARD"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.WHITE_LILAC
			color2 = Data.WHITE_LILAC
			color3 = Data.DARK_LILAC
		Data.ScriptMode.FRAMEWORK:
			$Script1Label.text = "NOTE_YES"
			$Script2Label.text = "NOTE_NO"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.WHITE_LILAC
			color2 = Data.WHITE_LILAC
			color3 = Data.RED
		Data.ScriptMode.NECROPOLIS:
			$Script1Label.text = "NOTE_YES"
			$Script2Label.text = "NOTE_NO"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.WHITE_LILAC
			color2 = Data.WHITE_LILAC
			color3 = Data.RED
		Data.ScriptMode.THIEVES_DEN:
			$Script1Label.text = "NOTE_YES"
			$Script2Label.text = "NOTE_NO"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.BASKET_BALL_ORANGE
			color2 = Data.BASKET_BALL_ORANGE
			color3 = Data.BASKET_BALL_ORANGE
		Data.ScriptMode.THEATER:
			$Script1Label.text = "NOTE_YES"
			$Script2Label.text = "NOTE_NO"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.BLUE_KOI
			color2 = Data.BLUE_KOI
			color3 = Data.BLUE_KOI
		Data.ScriptMode.MUSEUM:
			$Script1Label.text = "NOTE_YES"
			$Script2Label.text = "NOTE_NO"
			$Script3Label.text = "NOTE_CANCEL"
			color1 = Data.YELLOW
			color2 = Data.YELLOW
			color3 = Data.YELLOW

	$Script1Label.set("custom_colors/font_color", color1)
	$Script2Label.set("custom_colors/font_color", color2)
	$Script3Label.set("custom_colors/font_color", color3)


func set_assassinated(char_name: String) -> void:
	$KillStealInfo/KillChar/Pic.animation = char_name
	if char_name == "Unchosen":
		$KillStealInfo.hide()
		$KillStealInfo/KillChar.hide()
		$KillStealInfo/KillSword.hide()
	else:
		$KillStealInfo.show()
		$KillStealInfo/KillChar.show()
		$KillStealInfo/KillSword.show()


func set_stolen(char_name: String) -> void:
	$KillStealInfo/StealChar/Pic.animation = char_name
	if char_name == "Unchosen":
		$KillStealInfo.hide()
		$KillStealInfo/StealChar.hide()
		$KillStealInfo/StealPocket.hide()
	else:
		$KillStealInfo.show()
		$KillStealInfo/StealChar.show()
		$KillStealInfo/StealPocket.show()


func set_reminder_text(string: String) -> void:
	$ReminderLabel.text = string


func hide_kill_steal_info() -> void:
	$KillStealInfo.hide()
	$KillStealInfo/StealChar.hide()
	$KillStealInfo/StealPocket.hide()
	$KillStealInfo/KillChar.hide()
	$KillStealInfo/KillSword.hide()


func show_reminder() -> void:
	$ReminderBackground.show()
	$ReminderLabel.show()


func hide_reminder() -> void:
	$ReminderBackground.hide()
	$ReminderLabel.hide()


func show_script3() -> void:
	$Script3.show()
	$Script3Label.show()


func hide_script3() -> void:
	$Script3.hide()
	$Script3Label.hide()


func show_script1() -> void:
	$Script1.show()
	$Script1Label.show()


func hide_script1() -> void:
	$Script1.hide()
	$Script1Label.hide()


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


func on_script1_pressed() -> void:
	hide_opponent_built()
	match script_mode:
		Data.ScriptMode.RESOURCE:
			Signal.emit_signal("sgin_resource_need", Data.Need.GOLD)
		Data.ScriptMode.MAGICIAN:
			Signal.emit_signal("sgin_magician_switch", Data.MagicianSwitch.DECK)
		Data.ScriptMode.MERCHANT:
			if not $Employee.skill_1_activated_this_turn:
				$Employee.set_activated_this_turn(Data.ActivateMode.SKILL1, true)
				Signal.emit_signal("sgin_merchant_gold", Data.MerchantGold.ONE)
		Data.ScriptMode.WARLORD:
			if not $Employee.skill_1_activated_this_turn:
				$Employee.set_activated_this_turn(Data.ActivateMode.SKILL1, true)
				Signal.emit_signal("sgin_warlord_choice", Data.WarlordChoice.DESTROY)
		Data.ScriptMode.FRAMEWORK:
			Signal.emit_signal("sgin_framework_choice", "yes")
		Data.ScriptMode.NECROPOLIS:
			for b in $BuiltScript.get_children():
				b.set_card_mode(Data.CardMode.NECROPOLIS_SELECTING)
			Signal.emit_signal("sgin_necropolis_choice", "yes")
		Data.ScriptMode.THIEVES_DEN:
			Signal.emit_signal("sgin_thieves_den_choice", selected, false)
		Data.ScriptMode.THEATER:
			Signal.emit_signal("sgin_theater_choice", true)

	$Script1.rect_position = script1_pos
	$Script1Label.rect_position = Vector2(script1_pos.x + 25, script1_pos.y + 28)


func on_script2_pressed() -> void:
	hide_opponent_built()
	match script_mode:
		Data.ScriptMode.RESOURCE:
			Signal.emit_signal("sgin_resource_need", Data.Need.CARD)
		Data.ScriptMode.MAGICIAN:
			Signal.emit_signal("sgin_magician_switch", Data.MagicianSwitch.PLAYER)
		Data.ScriptMode.MERCHANT:
			if not $Employee.skill_2_activated_this_turn:
				$Employee.set_activated_this_turn(Data.ActivateMode.SKILL2, true)
				Signal.emit_signal("sgin_merchant_gold", Data.MerchantGold.GREEN)
		Data.ScriptMode.WARLORD:
			if not $Employee.skill_2_activated_this_turn:
				$Employee.set_activated_this_turn(Data.ActivateMode.SKILL2, true)
				Signal.emit_signal("sgin_warlord_choice", Data.WarlordChoice.RED)
		Data.ScriptMode.FRAMEWORK:
			Signal.emit_signal("sgin_framework_choice", "no")
		Data.ScriptMode.NECROPOLIS:
			Signal.emit_signal("sgin_necropolis_choice", "no")
		Data.ScriptMode.THEATER:
			Signal.emit_signal("sgin_theater_choice", false)
	$Script2.rect_position = script2_pos
	$Script2Label.rect_position = Vector2(script2_pos.x + 25, script2_pos.y + 28)


func on_script1_mouse_entered() -> void:
	if script_mode == Data.ScriptMode.MERCHANT and $Employee.skill_1_activated_this_turn:
		return
	$Script1.set_position(Vector2(script1_pos.x, script1_pos.y - 20))
	$Script1Label.set_position(Vector2(script1_pos.x + 25, script1_pos.y + 8))


func on_script1_mouse_exited() -> void:
	if script_mode == Data.ScriptMode.MERCHANT and $Employee.skill_1_activated_this_turn:
		return
	$Script1.set_position(script1_pos)
	$Script1Label.set_position(Vector2(script1_pos.x + 25, script1_pos.y + 28))


func on_script2_mouse_entered() -> void:
	if script_mode == Data.ScriptMode.MERCHANT and $Employee.skill_2_activated_this_turn:
		return

	$Script2.set_position(Vector2(script2_pos.x, script2_pos.y - 20))
	$Script2Label.set_position(Vector2(script2_pos.x + 25, script2_pos.y + 8))


func on_script2_mouse_exited() -> void:
	if script_mode == Data.ScriptMode.MERCHANT and $Employee.skill_2_activated_this_turn:
		return
	$Script2.set_position(script2_pos)
	$Script2Label.set_position(Vector2(script2_pos.x + 25, script2_pos.y + 28))


func on_script3_pressed() -> void:
	hide_opponent_built()
	match script_mode:
		Data.ScriptMode.PLAYING:
			Signal.emit_signal("sgin_end_turn")
		Data.ScriptMode.ASSASSIN, Data.ScriptMode.THIEF:
			Signal.emit_signal("sgin_cancel_skill", ["employment"], "Character", Data.ActivateMode.ALL, Data.Phase.TURN)
		Data.ScriptMode.MERCHANT:
			Signal.emit_signal("sgin_cancel_skill", ["scripts"], "Character", Data.ActivateMode.SKILL2, Data.Phase.TURN)
		Data.ScriptMode.MAGICIAN:
			Signal.emit_signal("sgin_cancel_skill", ["opponent", "scripts"], "Character", Data.ActivateMode.ALL, Data.Phase.TURN)
		Data.ScriptMode.WARLORD:
			Signal.emit_signal("sgin_cancel_skill", ["opponent", "scripts", "opponent_built"], "Character", Data.ActivateMode.SKILL1, Data.Phase.TURN)
		Data.ScriptMode.ARMORY:
			Signal.emit_signal("sgin_cancel_skill", ["opponent", "scripts", "opponent_built"], "", false, Data.Phase.TURN)
		Data.ScriptMode.LABORATORY:
			Signal.emit_signal("sgin_cancel_skill", [], "Laboratory", false, Data.Phase.TURN)
		Data.ScriptMode.FRAMEWORK:
			Signal.emit_signal("sgin_framework_choice", "cancel")
		Data.ScriptMode.NECROPOLIS:
			Signal.emit_signal("sgin_necropolis_choice", "cancel")
		Data.ScriptMode.THIEVES_DEN:
			Signal.emit_signal("sgin_thieves_den_choice", [], true)
		Data.ScriptMode.THEATER:
			Signal.emit_signal("sgin_cancel_skill", ["scripts", "opponent"], "Theater", false, Data.Phase.RESOURCE)
		Data.ScriptMode.MUSEUM:
			Signal.emit_signal("sgin_cancel_skill", ["scripts", "hands", "built"], "Museum", false, Data.Phase.TURN)
	$Script3.rect_position = end_turn_pos
	$Script3Label.rect_position = Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28)


func on_script3_mouse_entered() -> void:
	if script_mode != Data.ScriptMode.NOT_PLAYING:
		$Script3.set_position(Vector2(end_turn_pos.x, end_turn_pos.y - 20))
		$Script3Label.set_position(Vector2(end_turn_pos.x + 25, end_turn_pos.y + 8))


func on_script3_mouse_exited() -> void:
	if script_mode != Data.ScriptMode.NOT_PLAYING:
		$Script3.set_position(end_turn_pos)
		$Script3Label.set_position(Vector2(end_turn_pos.x + 25, end_turn_pos.y + 28))


func wait_magician() -> void:
	disable_play()
	set_script_mode(Data.ScriptMode.MAGICIAN)
	Signal.emit_signal("sgin_set_reminder", "NOTE_MAGICIAN")
	show_scripts()


func wait_merchant() -> void:
	disable_play()
	set_script_mode(Data.ScriptMode.MERCHANT)
	Signal.emit_signal("sgin_set_reminder", "NOTE_MERCHANT")
	show_scripts()


func wait_warlord() -> void:
	disable_play()
	set_script_mode(Data.ScriptMode.WARLORD)
	Signal.emit_signal("sgin_set_reminder", "NOTE_WARLORD")
	show_scripts()


func wait_armory() -> void:
	disable_play()
	set_script_mode(Data.ScriptMode.ARMORY)
	Signal.emit_signal("sgin_set_reminder", "NOTE_ARMORY")


func wait_laboratory() -> void:
	disable_play()
	set_script_mode(Data.ScriptMode.LABORATORY)
	Signal.emit_signal("sgin_set_reminder", "NOTE_LABORATORY")
	for h in $HandScript.get_children():
		h.set_card_mode(Data.CardMode.LABORATORY_SELECTING)






#
#func player_draw_built(mode: String, card_name: String, from_pos: Vector2, end_face_up: bool, animation_time: float, start_scale: Vector2, end_scale: Vector2) -> void:
#	var list
#	var node
#	var not_ready_signal
#	var ready_signal
#	if mode == "hands":
#		list = hands
#		node = $HandScript
#		not_ready_signal = "sgin_player_draw_not_ready"
#		ready_signal = "sgin_player_draw_ready"
#	else:
#		list = built
#		node = $BuiltScript
#		not_ready_signal = "sgin_player_built_not_ready"
#		ready_signal = "sgin_player_built_ready"
#
##	var card_info = Data.get_card_info(card_name)
#	var incoming_card = Card.instance()
#	list.append(card_name)
#	node.add_child(incoming_card)
#	incoming_card.init_card(card_name, start_scale, from_pos, true, Data.CardMode.ENLARGE)
#	Signal.emit_signal(not_ready_signal, incoming_card)
#	var positions = get_positions_with_new_card(node)
#	var action_list = [
#		[incoming_card, "global_position", from_pos, positions[-1] + $HandScript.global_position, animation_time],
#		[incoming_card, "scale", start_scale, end_scale, animation_time],
#		[incoming_card.get_node("Back"), "visible", true, not end_face_up, animation_time],
#		[incoming_card.get_node("Face"), "visible", false, end_face_up, animation_time],
#	]
#
#
#	if end_face_up:
#		action_list.insert(
#			1,
#			[
#				incoming_card,
#				"scale:y",
#				incoming_card.scale.y,
#				0.01,
#				animation_time / 2,
#			]
#		)
#		action_list.insert(
#			2,
#			[
#				incoming_card,
#				"scale:y",
#				0.01,
#				incoming_card.scale.y,
#				animation_time / 2,
#			]
#		)
#	TweenMove.animate(action_list)
#	#TweenMotion.ani_flip_to_face_up_move(incoming_card, end_face_up, positions[-1] + $HandScript.global_position, end_scale)
#	#yield(Signal, "all_ani_completed")
#	rearrange(node, positions, animation_time + 0.01)
#	yield(TweenMove, "tween_all_completed")
#	Signal.emit_signal(ready_signal, incoming_card)


func draw(card_name: String, face_is_up: bool, from_pos: Vector2, animation_time: float, start_scale: Vector2 = Data.CARD_SIZE_MEDIUM, end_scale: Vector2 = Data.CARD_SIZE_MEDIUM) -> void:
	hands.append(card_name)
	var incoming_card = Card.instance()
	$HandScript.add_child(incoming_card)
	incoming_card.init_card(card_name, start_scale, from_pos, false, Data.CardMode.ENLARGE)
#	var positions = get_hand_positions_with_new_card()
#	var card_position = positions[-1] + $HandScript.global_position
#	if animation_time > 0:
#		TweenMotion.ani_flip_move(incoming_card, card_position, end_scale, true, face_is_up)
#	else:
#		incoming_card.set_global_position(card_position)
#		incoming_card.set_face_up(face_is_up)
#	yield(Signal, "all_ani_completed")
#	rearrange_hands(animation_time)
	
func rearrange(node: Node, positions: Array, animation_time: float) -> void:
	var hands_obj = node.get_children()
	for index in range(hands_obj.size()):
		var each_card = hands_obj[index]
		var card_position = positions[index] + node.global_position
		if animation_time > 0:
			TweenMotion.ani_flip_move(each_card, card_position, each_card.scale, true, each_card.face_up)
		else:
			each_card.set_global_position(card_position)


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


func disable_enlarge() -> void:
	for a in $HandScript.get_children():
		a.set_card_mode(Data.CardMode.STATIC)
	for a in $BuiltScript.get_children():
		a.set_card_mode(Data.CardMode.STATIC)


func enable_enlarge() -> void:
	for a in $HandScript.get_children():
		a.set_card_mode(Data.CardMode.ENLARGE)
	for a in $BuiltScript.get_children():
		a.set_card_mode(Data.CardMode.ENLARGE)


func disable_play() -> void:
	$Employee.set_can_skill(false)
	for a in $HandScript.get_children():
		a.set_card_mode(Data.CardMode.STATIC)
	for a in $BuiltScript.get_children():
		a.set_card_mode(Data.CardMode.STATIC)
	set_script_mode(Data.ScriptMode.NOT_PLAYING)
#	$Employee.set_employee_mode(Data.ScriptMode.NOT_PLAYING)
	$Script3Label.set("custom_colors/font_color", Data.GRAY)


func enable_play() -> void:
	$Employee.set_can_skill(true)
	for a in $HandScript.get_children():
		a.set_card_mode(Data.CardMode.PLAY)
	for a in $BuiltScript.get_children():
		if "Armory" in a.card_name or "Smithy" in a.card_name or "Laboratory" in a.card_name or "Museum" in a.card_name:
			a.set_card_mode(Data.CardMode.BUILT_CLICKABLE)
		else:
			a.set_card_mode(Data.CardMode.ENLARGE)

#	$Employee.set_employee_mode(Data.ScriptMode.PLAYING)
	set_script_mode(Data.ScriptMode.PLAYING)


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
	set_employee(data.get("employee_num", employee_num), data.get("employee", employee))
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
		draw(c, true, Data.DECK_POSITION, 0)
	enable_enlarge()
	for b in data.get("built", []):
		build(b, Data.DECK_POSITION, 0)
	set_museum_num(data.get("museum_num", 0))


func set_museum_num(num: int) -> void:
	museum_num = num
	var museum = get_built_obj("Museum")
	if museum != null:
		museum.set_museum_num(museum_num)


func build(card_name: String, from_pos: Vector2, animation_time: float, start_scale: Vector2 = Data.CARD_SIZE_MEDIUM, end_scale: Vector2 = Data.CARD_SIZE_MEDIUM) -> void:
	built.append(card_name)
	var incoming_card = Card.instance()
	$BuiltScript.add_child(incoming_card)
	incoming_card.init_card(card_name, start_scale, from_pos, false, Data.CardMode.ENLARGE)
	var positions = get_hand_positions_with_new_card()
	var card_position = positions[-1] + $BuiltScript.global_position
	if animation_time > 0:
		TweenMotion.ani_flip_move(incoming_card, card_position, end_scale, true, true)
	else:
		incoming_card.set_global_position(card_position)
		incoming_card.set_face_up(true)
	rearrange_built()
	

func set_hide_employee(hide: bool) -> void:
	hide_employee = hide
	$Employee.hide_employee = hide


func set_employee(num: int, employ: String) -> void:
	employee = employ
	employee_num = num
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
	var not_played = not card_name in built
	return not_played


func has_ever_played() -> bool:
	return played_this_turn.size() < 1


func card_played(card_name: String, price: int) -> void:
	disable_play()
	var card_obj = get_hand_obj(card_name)
	if card_obj == null:
		enable_play()
		return false
	var from_pos = card_obj.global_position
	Signal.emit_signal("sgin_gold_move", player_num, Data.bank_num, price, "sgin_player_pay_ready")
	yield(Signal, "sgin_player_pay_ready")
	hands.erase(card_name)
	built.append(card_name)
	card_obj.on_mouse_exited()
	var z_index = card_obj.z_index
	card_obj.z_index = 4096
	var original_scale = card_obj.scale
	disable_enlarge()
	# TweenMove.animate(
	# 	[
	# 		[card_obj, "global_position", from_pos, Data.CENTER],
	# 		[card_obj, "scale", original_scale, Data.CARD_SIZE_BIG],
	# 	]
	# )
	# yield(TweenMove, "tween_all_completed")

	TweenMotion. ani_flip_move(card_obj, Data.CENTER, Data.CARD_SIZE_BIG)
	yield(Signal, "all_ani_completed")
	$HandScript.remove_child(card_obj)
	$BuiltScript.add_child(card_obj)
	card_obj.global_position = Data.CENTER
	# TweenMove.animate(
	# 	[
	# 		[card_obj, "global_position", Data.CENTER, $BuiltScript.global_position + get_built_positions_with_new_card()[-1]],
	# 		[card_obj, "scale", Data.CARD_SIZE_BIG, original_scale],
	# 	]
	# )
	# yield(TweenMove, "tween_all_completed")
	TweenMotion. ani_flip_move(card_obj, $BuiltScript.global_position + get_built_positions_with_new_card()[-1], original_scale)
	yield(Signal, "all_ani_completed")
	card_obj.z_index = z_index
	rearrange($HandScript, get_hand_positions_with_new_card(), 1)
	rearrange($BuiltScript, get_built_positions_with_new_card(), 1)
	# yield(TweenMove, "tween_all_completed")
	yield(Signal, "all_ani_completed")
	enable_play()
	played_this_turn.append(card_name)
	Signal.emit_signal("sgin_card_played_finished", card_name)


func rearrange_built(ani_time: int = 1) -> void:
	rearrange($BuiltScript, get_built_positions_with_new_card(), ani_time)
	# yield(TweenMove, "tween_all_completed")
	yield(Signal, "all_ani_completed")
	$BuiltScript.global_position = built_script_pos

func rearrange_hands(ani_time: int = 1) -> void:
	rearrange($HandScript, get_hand_positions_with_new_card(), ani_time)
	# yield(TweenMove, "tween_all_completed")
	yield(Signal, "all_ani_completed")


func after_end_turn() -> void:
	hide_script3()
	played_this_turn = []


func can_end_game() -> bool:
	return built.size() >= 7


func clear_hands() -> void:
	hands = []
	for c in $HandScript.get_children():
		$HandScript.remove_child(c)
		c.queue_free()


func shuffle_hands() -> void:
	hands.shuffle()


func remove_hand(card_name: String) -> void:
	var card_obj
	for c in $HandScript.get_children():
		if c.card_name == card_name:
			card_obj = c
			$HandScript.remove_child(card_obj)
	if card_obj == null:
		return
	card_obj.queue_free()
	hands.erase(card_name)


func remove_built(card_name: String) -> void:
	var card_obj
	for c in $BuiltScript.get_children():
		if c.card_name == card_name:
			card_obj = c
			$BuiltScript.remove_child(card_obj)
			break
	if card_obj == null:
		return
	card_obj.queue_free()
	built.erase(card_name)


func add_gold(num: int) -> void:
	gold += num
	$MoneyNum.text = str(gold)


func built_color_num(color: String) -> int:
	var number = 0
	for card_name in built:
		if color == Data.get_card_info(card_name)["kind"]:
			number += 1
	return number


func set_opponent_built_mode(mod: int) -> void:
	opponent_built_mode = mod


func show_opponent_built(name: String, cards: Array) -> void:
	if opponent_built_mode in [Data.OpponentBuiltMode.SHOW, Data.OpponentBuiltMode.WARLORD_SHOW, Data.OpponentBuiltMode.ARMORY_SHOW]:
		for c in $OpponentBuilt.get_children():
			$OpponentBuilt.remove_child(c)
			c.queue_free()
		var start_scale = Data.CARD_SIZE_MEDIUM
		var from_pos = Data.ZERO

		for card_name in cards:
#			var card_info = Data.get_card_info(card_name)
			var incoming_card = Card.instance()
			var card_mode
			match opponent_built_mode:
				Data.OpponentBuiltMode.SHOW, Data.OpponentBuiltMode.SILENT:
					card_mode = Data.CardMode.ENLARGE
				Data.OpponentBuiltMode.WARLORD_SHOW:
					card_mode = Data.CardMode.WARLORD_SELECTING
				Data.OpponentBuiltMode.ARMORY_SHOW:
					card_mode = Data.CardMode.ARMORY_SELECTING
			$OpponentBuilt.add_child(incoming_card)
			incoming_card.init_card(card_name, start_scale, from_pos, true, card_mode)
		var positions = get_positions_with_new_card($OpponentBuilt)
		rearrange($OpponentBuilt, positions, 0)

		$OpponentBuilt.show()
		$OpponentBuiltName.show()
		$OpponentBuiltNameText.text = name
		$OpponentBuiltNameText.show()


func hide_opponent_built() -> void:
	if opponent_built_mode in [Data.OpponentBuiltMode.SHOW]:
		$OpponentBuilt.hide()
		$OpponentBuiltName.hide()
		$OpponentBuiltNameText.hide()


func get_employee_global_position() -> Vector2:
	return $Employee.global_position


func get_handscript_children() -> Array:
	return $HandScript.get_children()


func set_employee_activated_this_turn(mode: int, can: bool) -> void:
	$Employee.set_activated_this_turn(mode, can)


func set_employee_can_skill(can: bool) -> void:
	$Employee.set_can_skill(can)


func get_built_obj(card_name: String) -> Node:
	for c in $BuiltScript.get_children():
		if c.card_name == card_name:
			return c
	return null


func get_hand_obj(card_name: String) -> Node:
	for c in $HandScript.get_children():
		if c.card_name == card_name:
			return c
	return null


func get_opponent_built_obj(card_name: String) -> Node:
	for c in $OpponentBuilt.get_children():
		if c.card_name == card_name:
			return c
	return null


func on_FakeBulitScriptCollision_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if opponent_state == Data.OpponentState.WARLORD_CLICKABLE:
			on_FakeBulitScriptCollision_mouse_exited()
			Signal.emit_signal("sgin_warlord_opponent_selected", player_num, employee, username, built)
		elif opponent_state == Data.OpponentState.ARMORY_CLICKABLE:
			Signal.emit_signal("sgin_armory_opponent_selected", player_num, employee, username, built)


func on_FakeBulitScriptCollision_mouse_entered():
	if opponent_state in [Data.OpponentState.WARLORD_CLICKABLE, Data.OpponentState.ARMORY_CLICKABLE]:
		$BuiltScript.global_position = Vector2(built_script_pos.x, built_script_pos.y - 20)


func on_FakeBulitScriptCollision_mouse_exited():
	if opponent_state in [Data.OpponentState.WARLORD_CLICKABLE, Data.OpponentState.ARMORY_CLICKABLE]:
		$BuiltScript.global_position = built_script_pos


func hide_color_choose() -> void:
	$ColorChoose.hide()


func show_color_choose() -> void:
	$ColorChoose.show()


func set_color_choose_mode(mode: int) -> void:
	color_mode = mode


func wait_haunted_quarter_color() -> void:
	set_color_choose_mode(Data.ColorMode.HAUNTED_QUARTER_SELECTABLE)
	show_color_choose()


func wait_school_of_magic_color() -> void:
	set_color_choose_mode(Data.ColorMode.SCHOOL_OF_MAGIC_SELECTABLE)
	show_color_choose()


func wait_thieves_den() -> void:
	selected = []
	for hand_obj in $HandScript.get_children():
		print(hand_obj.card_name)
		if "Thieves' Den" in hand_obj.card_name:
			hand_obj.set_card_mode(Data.CardMode.ENLARGE)
		hand_obj.set_card_mode(Data.CardMode.THIEVES_DEN_SELECTING)


func wait_theater() -> void:
	set_script_mode(Data.ScriptMode.THEATER)
	show_scripts()


func on_ColorChoose_input_event(_viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var color_dic = {0: "yellow", 1: "blue", 2: "green", 3: "red", 4: "purple"}
		if color_mode == Data.ColorMode.HAUNTED_QUARTER_SELECTABLE:
			hide_color_choose()
			Signal.emit_signal("sgin_haunted_quarter_color_selected", color_dic[shape_idx])
		elif color_mode == Data.ColorMode.SCHOOL_OF_MAGIC_SELECTABLE:
			hide_color_choose()
			Signal.emit_signal("sgin_school_of_magic_color_selected", color_dic[shape_idx])


func add_museum_num() -> void:
	museum_num += 1
