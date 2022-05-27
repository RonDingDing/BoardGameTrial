extends Sprite

onready var Signal = get_node("/root/Main/Signal")


#func draw_gold(relative_to_me: int, pos: Vector2) -> void:
#	Signal.emit_signal("sgin_gold", relative_to_me, pos)


#func on_sgin_card_dealt(all_player_length: int) -> void:
#	# 每人发2个金币
#	for relative_to_me in range(all_player_length):
#		for _i in range(2):
#			draw_gold(relative_to_me, global_position)
#			if relative_to_me == 0:
#				yield(Signal, "sgin_player_gold_ready")
#			else:
#				yield(Signal, "sgin_opponent_gold_ready")
#	Signal.emit_signal("sgin_ready_game")
