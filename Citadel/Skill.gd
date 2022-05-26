extends Node
onready var Signal = get_node("/root/Main/Signal")

#### Skills - Cards


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


func cardskill_end_ivory_tower(unique_size: int) -> void:
	if unique_size == 1:
		Signal.emit_signal("sgin_add_point", 5)
		
func cardskill_resourcedraw_observatory() -> int:
	return 3
