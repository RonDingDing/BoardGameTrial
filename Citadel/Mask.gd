extends Node2D

onready var Signal = get_node("/root/Main/Signal")


func on_hand_over(player_name: String) -> void:
	set_process(true)
	$Text.text = tr("DIALOG_HAND_DEVICE").replace("X", player_name)
	show()


func on_phase(phase_string: String) -> void:
	set_process(true)
	$Text.text = tr(phase_string)	
	show()


func on_pressed():
	hide()
	set_process(false)
	Signal.emit_signal("uncover")
