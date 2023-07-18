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
	
	var tween = Tween.new()
	add_child(tween)
	for action in action_list:
		if action is Trans:
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
			
			for motion in action.motion_list:
				var orgi_node = motion[0]
				var copy_node = motion[1]
				if is_instance_valid(orgi_node):
					orgi_node.set_visible(true)
					orgi_node.set_z_index(0)
				if is_instance_valid(copy_node):
					copy_node.set_z_index(0)
					copy_node.queue_free()
				
		elif action is Interval:
			TimerGlobal.set_wait_time(action.wait_time)
			TimerGlobal.start()
			yield(TimerGlobal, "timeout")
	
	remove_child(tween)
	tween.queue_free()
	Signal.emit_signal("all_ani_completed")

 
func ani_flip_move(
	obj: Node2D,
	end_pos: Vector2 = Data.FAR_AWAY,
	end_scale: Vector2 = Data.FAR_AWAY,
	end_visible: bool = true,
	end_face_up: bool = true,
	ani_time: int = 1
) -> void:
	if end_scale == Data.FAR_AWAY:
		end_scale = obj.scale
	if end_pos == Data.FAR_AWAY:
		end_pos = obj.global_position
	
	var a1 = Trans.new()
	var z_index = obj.z_index
	a1.add(obj, "global_position", obj.global_position, end_pos, ani_time)
	a1.add(obj, "scale", obj.scale, end_scale, ani_time)
	a1.add(obj, "z_index", 1, 1, ani_time)
	if "face_up" in obj:
		a1.add(obj, "face_up", obj.face_up, end_face_up, ani_time)
	animate([a1])
	
