extends Node

onready var TimerGlobal = get_node("/root/Main/Timer")

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
		
	func add(prop_name: String, start_val: Node, end_val: Node):
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
	yield(tween, "tween_all_completed")
	remove_child(tween)
	tween.queue_free()
	
	
func move_scale(node: Node, start_pos: Vector2, end_pos: Vector2, start_scale: Vector2, end_scale: Vector2, ani_time: float=1, wait: bool=true) -> Trans:
	var sm = Trans.new(node, ani_time, wait)
	sm.add("global_position", start_pos, end_pos)
	sm.add("scale", start_scale, end_scale)
	return sm
