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
