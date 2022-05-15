extends Node2D


func to_coin(to_scale: Vector2, global_pos: Vector2) -> void:
	$Money.position = Vector2(0, 0)
	$MoneyNum.visible = false
	scale = to_scale
	global_position = global_pos
