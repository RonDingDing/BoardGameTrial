extends Node2D

onready var TimerGlobal = get_node("/root/Main/Timer")
onready var Data = get_node("/root/Main/Data")
onready var Signal = get_node("/root/Main/Signal")

class Trans:
	var node: Node
	var animation_time: float
	var wait_till_finish: bool
	var motion_list: Array
	
	func _init(n: Node, ani_time: float=1, wait: bool=true) -> void:
		node = n
		animation_time = ani_time
		wait_till_finish = wait
		motion_list = []
		
	func add(prop_name: String, start_val, end_val):
		motion_list.append([prop_name, start_val, end_val])
		

class Interval:
	var wait_time: float
	
	func _init(times: float) -> void:
		wait_time = times
		
		

func animate(action_list: Array) -> void:
	var _useless
	var tween = Tween.new()
	add_child(tween)
	for action in action_list:
		if action is Trans:
			for motion in action.motion_list:
				var prop_name = motion[0]
				var start_val = motion[1]
				var end_val = motion[2]
				_useless = tween.interpolate_property(
					action.node, prop_name, start_val, end_val, action.animation_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
				)
			_useless = tween.start()
			if action.wait_till_finish:
				yield(tween, "tween_all_completed")
		elif action is Interval:
			TimerGlobal.set_wait_time(action.wait_time)
			TimerGlobal.start()
			yield(TimerGlobal, "timeout")
	if tween.is_active():
		yield(tween, "tween_all_completed")
	remove_child(tween)
	tween.queue_free()
	Signal.emit_signal("all_ani_completed")


func ani_card_move_center_then_away(card_obj: Node) -> void:
	if is_instance_valid(card_obj):
		card_obj.set_visible(false)
	var copy = card_obj.duplicate(DUPLICATE_USE_INSTANCING)
	copy.set_scale(card_obj.scale)
	copy.set_global_position(card_obj.global_position)
	copy.set_visible(true)
	add_child(copy)
	var z_index = copy.z_index
	copy.z_index = 1000
	
	var a1 = Trans.new(copy)
	a1.add("global_position", copy.global_position, Data.CENTER)
	a1.add("scale", copy.scale, Data.CARD_SIZE_BIG)
	a1.add("z_index", 1000, 1000)
	
	var a2 = Trans.new(copy)
	a2.add("global_position", Data.CENTER,  Data.CARD_END2)
	a2.add("z_index", 1000, z_index)
	
	animate([a1, a2])
	yield(Signal, "all_ani_completed")
	copy.queue_free()
	if is_instance_valid(card_obj):
		card_obj.set_visible(true)
		


func ani_card_move(card_obj: Node, end_pos: Vector2, end_scale: Vector2) -> void:
	var copy = card_obj.duplicate(DUPLICATE_USE_INSTANCING)
	if is_instance_valid(card_obj):
		card_obj.set_visible(false)
	copy.set_scale(card_obj.scale)
	copy.set_global_position(card_obj.global_position)
	add_child(copy)	
	var start_pos = copy.global_position
	var start_scale = copy.scale
	var z_index = copy.z_index
	copy.z_index = 1000
	
	var a1 = Trans.new(copy)
	a1.add("global_position", start_pos, end_pos)
	a1.add("scale", start_scale, end_scale)
	a1.add("z_index", 1000, z_index)
	
	animate([a1])
	yield(Signal, "all_ani_completed")
	copy.queue_free()
	if is_instance_valid(card_obj):
		card_obj.set_visible(true)
		card_obj.set_global_position(end_pos)
		card_obj.set_scale(end_scale)


