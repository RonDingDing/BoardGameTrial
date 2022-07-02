extends Area2D

enum EmployeeMode { PLAYING, NOT_PLAYING }
onready var hide_employee = true
onready var employee = "Unchosen"
onready var Signal = get_node("/root/Main/Signal")
onready var employee_mode = EmployeeMode.PLAYING

func set_employee_mode(mode: int) -> void:
	employee_mode = mode

func on_mouse_entered() -> void:
	if employee != "Unchosen" and (not hide_employee) and employee_mode == EmployeeMode.PLAYING:
		Signal.emit_signal("sgin_char_focused", employee)


func on_mouse_exited():
	if employee != "Unchosen" and (not hide_employee) and employee_mode == EmployeeMode.PLAYING:
		Signal.emit_signal("sgin_char_unfocused", employee)
