extends Node2D

onready var TimerGlobal = get_node("/root/Main/Timer")
onready var Data = get_node("/root/Main/Data")
onready var Signal = get_node("/root/Main/Signal")
const Area2D2 = preload("res://Area2D2.gd")

class Trans:
	var motion_list: Array

	func _init( ) -> void:
		motion_list = []

	func add(node: Node2D, prop_name: String, start_val, end_val, ani_time: float = 1) -> void:
		motion_list.append([node, prop_name, start_val, end_val, ani_time])


class Interval:
	var wait_time: float

	func _init(times: float) -> void:
		wait_time = times


class EndStatus:
	var end_pos: Vector2
	var end_scale: Vector2
	var end_z_index: int
	var end_visible: bool
	var end_face_up: bool

	func _init(e_pos: Vector2, e_scale: Vector2, e_z_index: int, e_visible: bool = true, e_face_up: bool=true) -> void:
		end_pos = e_pos
		end_scale = e_scale
		end_z_index = e_z_index
		end_visible = e_visible
		end_face_up = e_face_up

func animate(action_list: Array) -> void:
	var _useless
	var tween = Tween.new()
	add_child(tween)
	for action in action_list:
		if action is Trans:
			for motion in action.motion_list:
				var node = motion[0]
				var prop_name = motion[1]
				var start_val = motion[2]
				var end_val = motion[3]
				var ani_time = motion[4]
				_useless = tween.interpolate_property(
					node,
					prop_name,
					start_val,
					end_val,
					ani_time,
					Tween.TRANS_CUBIC,
					Tween.EASE_IN_OUT
				)
			_useless = tween.start()
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
	var ani_obj = card_obj.duplicate(0)
	ani_obj.set_scale(card_obj.scale)
	ani_obj.set_global_position(card_obj.global_position)
	ani_obj.set_visible(true)
	add_child(ani_obj)
	return ani_obj
	 

func finish(card_obj: Node2D, ani_obj: Node2D, end_status: EndStatus) -> void:
	ani_obj.queue_free()
	if is_instance_valid(card_obj):
		card_obj.set_global_position(end_status.end_pos)
		card_obj.set_scale(end_status.end_scale)
		card_obj.set_z_index(end_status.end_z_index)
		card_obj.set_visible(true)

 

func center_away(ani_obj: Node2D) -> EndStatus:
	var original_z = ani_obj.z_index
	ani_obj.z_index = 1000
	
	var ani_time = 1
	
	var a1 = Trans.new()
	a1.add(ani_obj, "global_position", ani_obj.global_position, Data.CENTER, ani_time)
	a1.add(ani_obj, "scale", ani_obj.scale, Data.CARD_SIZE_BIG, ani_time)
	a1.add(ani_obj, "z_index", 1000, 1000, ani_time)

	var a2 = Trans.new()
	a2.add(ani_obj, "global_position", Data.CENTER, Data.CARD_END2, ani_time)
	a2.add(ani_obj, "z_index", 1000, original_z, ani_time)

	animate([a1, a2])
	return EndStatus.new(Data.CARD_END2, ani_obj.scale, original_z)


func move(
	ani_obj: Node2D, end_pos: Vector2, end_scale: Vector2 = Data.FAR_AWAY, end_visible: bool = true
) -> EndStatus:
	var original_z = ani_obj.z_index
	ani_obj.z_index = 1000
	if end_scale == Data.FAR_AWAY:
		end_scale = ani_obj.scale
	var ani_time = 1
	var a1 = Trans.new()
	a1.add(ani_obj, "global_position", ani_obj.global_position, end_pos, ani_time)
	a1.add(ani_obj, "scale", ani_obj.scale, end_scale, ani_time)
	a1.add(ani_obj, "z_index", 1000, original_z, ani_time)
	animate([a1])
	return EndStatus.new(end_pos, end_scale, original_z, end_visible)

func flip_move(
	ani_obj: Node2D,
	end_face_up: bool,
	end_pos: Vector2,
	end_scale: Vector2 = Data.FAR_AWAY,
	end_visible: bool = true
) -> EndStatus:
	var original_z = ani_obj.z_index
	ani_obj.z_index = 1000
	if end_scale == Data.FAR_AWAY:
		end_scale = ani_obj.scale
	var ani_time = 1
	
	var a1 = Trans.new()
	a1.add(ani_obj, "global_position", ani_obj.global_position, end_pos, ani_time)
	a1.add(ani_obj, "scale", ani_obj.scale, end_scale, ani_time)
	a1.add(ani_obj, "z_index", 1000, original_z, ani_time)
	if end_face_up:
		a1.add(ani_obj, "scale:y", ani_obj.scale.y, 0.01, ani_time / 2)
		a1.add(ani_obj, "scale:y", 0.01, ani_obj.scale.y, ani_time / 2)
	a1.add(ani_obj.get_node("Back"), "visible", true, not end_face_up, ani_time)
	a1.add(ani_obj.get_node("Face"), "visible", false, end_face_up, ani_time)
	animate([a1])
	
	return EndStatus.new(end_pos, end_scale, original_z, end_visible, end_face_up)


func ani_move(
	card_obj: Node2D, end_pos: Vector2, end_scale: Vector2 = Data.FAR_AWAY, end_visible: bool = true
) -> void:
	var ani_obj = prepare(card_obj)
	if end_scale == Data.FAR_AWAY:
		end_scale = ani_obj.scale
	var end_status = move(ani_obj, end_pos, end_scale, end_visible)
	yield(Signal, "all_ani_completed")
	finish(card_obj, ani_obj, end_status)


func ani_flip_to_face_up_move(
	card_obj: Node2D, face_is_up: bool, end_pos: Vector2, end_scale: Vector2 = Data.FAR_AWAY, end_visible: bool = true
) -> void:
	var ani_obj = prepare(card_obj)
	if is_instance_valid(card_obj):
		card_obj.set_face_up(false)
	if end_scale == Data.FAR_AWAY:
		end_scale = ani_obj.scale
	var end_status = flip_move(ani_obj, face_is_up, end_pos, end_scale, end_visible)
	yield(Signal, "all_ani_completed")
	finish(card_obj, ani_obj, end_status)
	if is_instance_valid(card_obj):
		card_obj.set_face_up(end_status.end_face_up)


func ani_move_center_then_away(card_obj: Node2D) -> void:
	var ani_obj = prepare(card_obj)
	var end_status = center_away(ani_obj)
	yield(Signal, "all_ani_completed")
	finish(card_obj, ani_obj, end_status)
