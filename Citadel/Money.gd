extends Node2D


func to_coin(to_scale: Vector2, global_pos: Vector2) -> void:
	$MoneyIcon.position = Vector2(0, 0)
	$MoneyNum.visible = false
	scale = to_scale
	global_position = global_pos
	z_index = 6
