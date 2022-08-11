extends Node2D

onready var TimerGlobal = get_node("/root/Main/Timer")
onready var Data = get_node("/root/Main/Data")
onready var Signal = get_node("/root/Main/Signal")
const Area2D2 = preload("res://Area2D2.gd")

class Trans:
	var motion_list: Array
	var copies: Dictionary

	func _init() -> void:
		motion_list = []
		copies = {}

	func add(node: Node2D, prop_name: String, start_val, end_val, ani_time: float = 1) -> void:
		var copy
		if node in copies:
			copy = copies[node]
		else:
			copy = node.duplicate(node.DUPLICATE_USE_INSTANCING)
			copies[node] = copy
		node.set(prop_name, end_val)
		motion_list.append([node, copy, prop_name, start_val, end_val, ani_time])


class Interval:
	var wait_time: float

	func _init(times: float) -> void:
		wait_time = times
 

func animate(action_list: Array) -> void:
	var _useless
	
	for action in action_list:
		if action is Trans:
			var tween = Tween.new()
			add_child(tween)
			for motion in action.motion_list:
				var orgi_node = motion[0]
				var copy_node = motion[1]
				var prop_name = motion[2]
				var start_val = motion[3]
				var end_val = motion[4]
				var ani_time = motion[5]
				orgi_node.set(prop_name, end_val)
				orgi_node.set_visible(false)
				if not copy_node.is_inside_tree():
					add_child(copy_node)
				
				_useless = tween.interpolate_property(
					copy_node,
					prop_name,
					start_val,
					end_val,
					ani_time,
					Tween.TRANS_CUBIC,
					Tween.EASE_IN_OUT
				)
			_useless = tween.start()
			yield(tween, "tween_all_completed")
			remove_child(tween)
			tween.queue_free()
			
			
			for motion in action.motion_list:
				var orgi_node = motion[0]
				action.copies.erase(orgi_node)
				var copy_node = motion[1]
				orgi_node.set_visible(true)
				if not copy_node.is_inside_tree():
					remove_child(copy_node)
				copy_node.queue_free()
				
		elif action is Interval:
			TimerGlobal.set_wait_time(action.wait_time)
			TimerGlobal.start()
			yield(TimerGlobal, "timeout")
	
	Signal.emit_signal("all_ani_completed")

 
func ani_flip_move(
	obj: Node2D,
	end_pos: Vector2 = Data.FAR_AWAY,
	end_scale: Vector2 = Data.FAR_AWAY,
	end_visible: bool = true,
	end_face_up: bool = true
) -> void:
		if end_scale == Data.FAR_AWAY:
			end_scale = obj.scale
		if end_pos == Data.FAR_AWAY:
			end_pos = obj.global_position
		
		
		var ani_time = 1	
		var a1 = Trans.new()
		a1.add(obj, "global_position", obj.global_position, end_pos, ani_time)
		a1.add(obj, "scale", obj.scale, end_scale, ani_time)
		a1.add(obj, "z_index", 1000, obj.z_index, ani_time)
		a1.add(obj.get_node("Back"), "visible", true, not end_face_up, ani_time)
#		a1.add(obj.get_node("Face"), "visible", false, end_face_up, ani_time)
		animate([a1])
