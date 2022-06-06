extends Node
onready var Signal = get_node("/root/Main/Signal")
onready var assassinated = [0, "Unchosen"]
onready var stolen = [0, "Unchosen"]
var full_num = 0
#### Skills - Cards


func set_full_num(full: int) -> void:
	full_num = full


func cardskill_resourcedraw_library(card_to_gain: int) -> int:
	return card_to_gain


func cardskill_end_park(hand_size: int) -> void:
	if hand_size == 0:
		for _i in range(2):
			Signal.emit_signal("sgin_draw_card", 0, true)
			yield(Signal, "sgin_player_draw_ready")


func cardskill_play_quarry() -> bool:
	return false


func armory() -> void:
	pass


func cardskill_charskill8() -> bool:
	return false


func cardskill_gameover_ivory_tower(unique_size: int) -> void:
	if unique_size == 1:
		Signal.emit_signal("sgin_add_point", 5)


func cardskill_resourcedraw_observatory() -> int:
	return 3


func cardskill_play_factory(color: String, price: int) -> int:
	if color == "purple":
		return price - 1
	return price


func smithy():
	pass


func laboratory():
	pass


func cardskill_gameover_basilica(odd_size: int) -> void:
	Signal.emit_signal("sgin_add_point", odd_size)


func cardskill_gameover_wishing_well(purple_size: int) -> void:
	Signal.emit_signal("sgin_add_point", purple_size)


func cardskill_gameover_statue(has_crown: bool) -> void:
	if has_crown:
		Signal.emit_signal("sgin_add_point", 5)


func cardskill_gameover_imperial_treasury(gold: int) -> void:
	Signal.emit_signal("sgin_add_point", gold)


func great_wall():
	pass


func cardskill_resourcegold_gold_mine() -> int:
	return 3


func cardskill_gameover_dragon_gate() -> void:
	Signal.emit_signal("sgin_add_point", 2)


func cardskill_end_poor_house(gold: int) -> void:
	if gold == 0:
		Signal.emit_signal("sgin_gold", 0)


func haunted_quarter() -> void:
	pass


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


#### Skills - Character
func charskill_play_active_assassin() -> void:
	Signal.emit_signal("sgin_assassin_wait")


func get_assassinable_characters() -> Array:
	var char_array = []
	for num in range(2, full_num):
		char_array.append(num)
	return char_array


func charskill_play_active_thief() -> void:
	Signal.emit_signal("sgin_thief_wait")


func get_stealable_characters() -> Array:
	var char_array = []
	for num in range(3, full_num):
		if num != assassinated[0]:
			char_array.append(num)
	return char_array


func charskill_play_active_magician() -> void:
	Signal.emit_signal("sgin_magician_wait")


func charskill_play_passive_king() -> void:
	print("king")


func charskill_play_active_bishop() -> void:
	print("peach")


func charskill_play_active_merchant() -> void:
	print("sell")


func charskill_play_passive_architect() -> void:
	print("build")


func charskill_play_active_warlord() -> void:
	print("gain or destroy")


#### Regular functions
func assassinate(char_num: int, char_name: String) -> void:
	assassinated = [char_num, char_name]


func is_assassinated(char_num: int, char_name: String) -> bool:
	return [char_num, char_name] == assassinated


func steal(char_num: int, char_name: String) -> void:
	stolen = [char_num, char_name]


func is_stolen(char_num: int, char_name: String) -> bool:
	return [char_num, char_name] == stolen


func handle_stolen(_employee_name: String) -> void:
	Signal.emit_signal("sgin_thief_stolen")


func check_continue(employee_num: int, employee_name: String, player_is_null: int) -> bool:
	if player_is_null:
		return true
	elif is_assassinated(employee_num, employee_name):
		return true
	return false


func check_reveal(employee_num: int, employee_name: String, _player_is_null: int) -> bool:
	if is_stolen(employee_num, employee_name):
		handle_stolen(employee_name)
		return true
	return false
