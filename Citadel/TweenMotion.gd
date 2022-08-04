extends Node2D

onready var TimerGlobal = get_node("/root/Main/Timer")
onready var Data = get_node("/root/Main/Data")
onready var Signal = get_node("/root/Main/Signal")


class Trans:
	var node: Node
	var animation_time: float
	var wait_till_finish: bool
	var motion_list: Array

	func _init(n: Node, ani_time: float = 1, wait: bool = true) -> void:
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


class EndStatus:
	var end_pos: Vector2
	var end_scale: Vector2
	var end_z_index: int
	var end_visible: bool

	func _init(e_pos: Vector2, e_scale: Vector2, e_z_index: int, e_visible: bool=true) -> void:
		end_pos = e_pos
		end_scale = e_scale
		end_z_index = e_z_index
		end_visible = e_visible


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
				_useless = tween.interpolate_property(action.node, prop_name, start_val, end_val, action.animation_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
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


func prepare(card_obj: Node2D, visible: bool = false) -> Node2D:
	if is_instance_valid(card_obj):
		card_obj.set_visible(visible)
	var copy_obj = card_obj.duplicate(0)
	copy_obj.set_scale(card_obj.scale)
	copy_obj.set_global_position(card_obj.global_position)
	copy_obj.set_visible(true)
	add_child(copy_obj)
	return copy_obj


func finish(card_obj: Node2D, copy_obj: Node2D, end_status: EndStatus) -> void:
	copy_obj.queue_free()
	if is_instance_valid(card_obj):
		card_obj.set_global_position(end_status.end_pos)
		card_obj.set_scale(end_status.end_scale)
		card_obj.set_z_index(end_status.end_z_index)
		card_obj.set_visible(true)


func center_away(copy_obj: Node2D) -> EndStatus:
	var original_z = copy_obj.z_index
	copy_obj.z_index = 1000

	var a1 = Trans.new(copy_obj)
	a1.add("global_position", copy_obj.global_position, Data.CENTER)
	a1.add("scale", copy_obj.scale, Data.CARD_SIZE_BIG)
	a1.add("z_index", 1000, 1000)

	var a2 = Trans.new(copy_obj)
	a2.add("global_position", Data.CENTER, Data.CARD_END2)
	a2.add("z_index", 1000, original_z)

	animate([a1, a2])
	return EndStatus.new(Data.CARD_END2, copy_obj.scale, original_z)


func move(copy_obj: Node2D, end_pos: Vector2, end_scale: Vector2, end_visible: bool) -> EndStatus:
	var original_z = copy_obj.z_index
	copy_obj.z_index = 1000

	var a1 = Trans.new(copy_obj)
	a1.add("global_position", copy_obj.global_position, end_pos)
	a1.add("scale", copy_obj.scale, end_scale)
	a1.add("z_index", 1000, original_z)
	animate([a1])
	return EndStatus.new(end_pos, end_scale, original_z, end_visible)


func ani_move_center_then_away(card_obj: Node) -> void:
	var copy_obj = prepare(card_obj)
	var end_status = center_away(copy_obj)
	yield(Signal, "all_ani_completed")
	finish(card_obj, copy_obj, end_status)


func ani_move(card_obj: Node, end_pos: Vector2, end_scale: Vector2, end_visible: bool) -> void:
	var copy_obj = prepare(card_obj)
	var end_status = move(copy_obj, end_pos, end_scale, end_visible)
	yield(Signal, "all_ani_completed")
	finish(card_obj, copy_obj, end_status)
