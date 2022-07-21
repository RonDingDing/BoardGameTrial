extends Area2D


onready var hide_employee = true
onready var employee = "Unchosen"
onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var employee_mode = Data.ScriptMode.PLAYING

func set_employee_mode(mode: int) -> void:
	employee_mode = mode

func on_employee_mouse_entered() -> void:
	if employee != "Unchosen" and (not hide_employee):# and employee_mode == Data.ScriptMode.PLAYING:
		Signal.emit_signal("sgin_char_focused", employee)


func on_employee_mouse_exited():
	if employee != "Unchosen" and (not hide_employee):# and employee_mode == Data.ScriptMode.PLAYING:
		Signal.emit_signal("sgin_char_unfocused")
