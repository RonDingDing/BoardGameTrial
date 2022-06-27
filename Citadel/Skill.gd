extends Node
onready var Signal = get_node("/root/Main/Signal")
onready var assassinated = [0, "Unchosen"]
onready var stolen = [0, "Unchosen"]
var full_num = 0
#### Skills - Cards
const deck_num = -1
const bank_num = -2
const unfound = -3
onready var first_person_num = 0

onready var player_built_color = {
	"red": 0,
	"yellow": 0,
	"blue": 0,
	"green": 0,
	"purple": 0
}



#func charskill_play_active_magician() -> void:
#	Signal.emit_signal("sgin_magician_wait")


#func gain_gold_by_color(color: String) -> void:
#	Signal.emit_signal("sgin_ask_built_num", color)
#	var built_yellow_num = player_built_color[color]
#	var add_num = card_type_change(color)
#	for _i in range(add_num + built_yellow_num):
#		Signal.emit_signal("sgin_gold_transfer", bank_num, first_person_num, "sgin_player_gold_ready")
#		yield(Signal, "sgin_player_gold_ready")


#### Regular functions









