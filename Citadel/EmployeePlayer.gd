extends "res://Employee.gd"

onready var Skill = get_node("/root/Main/Game/Board/Skill")
onready var can_skill = false
onready var activated_this_turn = true


func set_activated_this_turn(can: bool) -> void:
	activated_this_turn = can


func set_can_skill(can: bool) -> void:
	can_skill = can


func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 如卡片不灰（可点击），主视角玩家选择了某角色
	if (
		event.is_pressed()
		and event is InputEventMouseButton
		#		and event.doubleclick
		and can_skill
		and (not activated_this_turn)
	):
		match employee:
			"Assassin":
				Skill.charskill_play_active_assassin()
			"Thief":
				Skill.charskill_play_active_thief()
			"Magician":
				Skill.charskill_play_active_magician()
			"King":
				Skill.charskill_play_active_king($Player.built_color_num("yellow"))
			"Bishop":
				Skill.charskill_play_active_bishop()
			"Warlord":
				Skill.charskill_play_active_warlord()
		set_activated_this_turn(true)
