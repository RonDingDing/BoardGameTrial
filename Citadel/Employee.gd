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



func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 如卡片不灰（可点击），主视角玩家选择了某角色
	if event.is_pressed() and event is InputEventMouseButton and event.doubleclick:
		print(1111)
