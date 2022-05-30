extends "res://Employee.gd"

onready var Skill = get_node("/root/Main/Game/Board/Skill")
onready var playing = false

func set_playing(play: bool) -> void:
	playing = play

func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 如卡片不灰（可点击），主视角玩家选择了某角色
	if event.is_pressed() and event is InputEventMouseButton and event.doubleclick and playing:
		match employee:
			"Assassin":
				Skill.charskill_play_active_assassin()
			"Thief":
				Skill.charskill_play_active_thief()
			"Magician":
				Skill.charskill_play_active_magician()			
			"Bishop":
				Skill.charskill_play_active_bishop()			
			"Warlord":
				Skill.charskill_play_active_warlord()
