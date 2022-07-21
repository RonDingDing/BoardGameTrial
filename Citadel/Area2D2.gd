extends Area2D

onready var mouse_collided = false
onready var can_be_top = true

func set_can_be_top(top: bool) -> void:
	can_be_top = top
	

func is_on_top() -> bool:
	if not is_visible_in_tree():
		return false
	elif not can_be_top:
		return false
	var areas = get_overlapping_areas()
	var im_on_top = true
	if areas.size() > 0:
		for area in areas:			
			if not "mouse_collided" in area:
				continue
			elif not area.mouse_collided:
				continue
			elif is_greater_than(area):
				continue
			elif not area.is_visible_in_tree():
				continue
			elif not area.can_be_top:
				continue
			else:
				im_on_top = false
				break
	return im_on_top
