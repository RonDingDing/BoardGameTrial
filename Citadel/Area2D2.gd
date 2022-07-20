extends Area2D

onready var mouse_collided = false

func is_on_top() -> bool:
	var areas = get_overlapping_areas()
	var is_on_top = true
	if areas.size() > 0:
		for area in areas:
			if "card_name" in area:
				print(area.card_name, " ",  "mouse_collided" in area and area.mouse_collided , " ", (not is_greater_than(area)), " ", area.is_visible_in_tree())
				print()
			if "mouse_collided" in area and area.mouse_collided and (not is_greater_than(area)) and area.is_visible_in_tree():
				is_on_top = false
				break
	return is_on_top
