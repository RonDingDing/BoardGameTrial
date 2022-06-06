extends Area2D

onready var hide_employee = true
onready var employee = "Unchosen"
onready var Signal = get_node("/root/Main/Signal")


func on_mouse_entered():
	if employee != "Unchosen" and (not hide_employee):
		Signal.emit_signal("sgin_char_focused", employee)


func on_mouse_exited():
	if employee != "Unchosen" and (not hide_employee):
		Signal.emit_signal("sgin_char_unfocused", employee)

#func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
#
#	if event.is_pressed() and event is InputEventMouseButton and event.doubleclick:
#		print(1111)
