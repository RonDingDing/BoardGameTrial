extends Area2D

onready var mouse_collided = false
onready var can_be_top = true

func set_can_be_top(top: bool) -> void:
	can_be_top = top
	

func is_on_top() -> bool:
	if not is_visible_in_tree():
		# print(0, " me: " ,self.get_path())
		return false
	elif not can_be_top:
		# print(1, " me: " ,self.get_path())
		return false
	var areas = get_overlapping_areas()
	var im_on_top = true
	if areas.size() > 0:
		for area in areas:
			if not "mouse_collided" in area:
				# print(1, ": " ,area.get("card_name")," ", area.get("char_name"))
				continue
			elif not area.mouse_collided:
				# print(2, ": " ,area.get("card_name")," ",  area.get("char_name"))
				continue
			elif is_greater_than(area):
				# print(3, ": " ,area.get("card_name")," ",  area.get("char_name"))
				continue
			elif not area.is_visible_in_tree():
				# print(4, ": " ,area.get("card_name")," ",  area.get("char_name"))
				continue
			elif not area.can_be_top:
				# print(5, ": " ,area.get("card_name")," ", area.get("char_name"))
				continue
			else:
				# print(6, "me: " ,self.get("card_name") ," ",  self.get("char_name"), " ", area.get("card_name") ," ",  area.get("char_name"))
				im_on_top = false
				break
		# print("me: ", self.get("card_name") ," ",  self.get("char_name"), " on top ", im_on_top)
		# print()
	return im_on_top


func find_top_most_card_collide_with_mouse() -> Node:
	var result = self
	if not is_visible_in_tree():
		result = null
		# print(5)
	elif not can_be_top:
		result = null
		# print(6)
	elif not self.mouse_collided:
		result = null
		# print(7)
	for area in get_overlapping_areas():
		if not ("mouse_collided" in area and area.mouse_collided):
			# print(1)
			continue
		elif not area.is_visible_in_tree():
			# print(2)
			continue
		elif not area.can_be_top:
			# print(3)
			continue
		elif result == null or area.is_greater_than(result):
			# print(4)
			result = area
	# if result == null:
	# 	print("null obj")
	# else:
	# 	print(result.get("card_name"), " ", result.get("char_name"))
	# print()
	return result

