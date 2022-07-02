extends "res://Employee.gd"

onready var Skill = get_node("/root/Main/Game/Board/Skill")
onready var can_skill = false
onready var skill_1_activated_this_turn = true
onready var skill_2_activated_this_turn = true
enum ActivateMode { ALL, SKILL1, SKILL2, NONE }


func set_activated_this_turn(mode: int, can: bool) -> void:
	if mode == ActivateMode.ALL:
		skill_1_activated_this_turn = can
		skill_2_activated_this_turn = can
	elif mode == ActivateMode.SKILL1:
		skill_1_activated_this_turn = can
	elif mode == ActivateMode.SKILL2:
		skill_2_activated_this_turn = can


func set_can_skill(can: bool) -> void:
	can_skill = can


func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 如卡片不灰（可点击），主视角玩家选择了某角色
	if event.is_pressed() and event is InputEventMouseButton:
		print(can_skill)
		print(not skill_1_activated_this_turn)
		print(not skill_2_activated_this_turn)
		print((not skill_1_activated_this_turn) or (not skill_2_activated_this_turn))
		print()
	if (
		event.is_pressed()
		and event is InputEventMouseButton
		and can_skill
		and ((not skill_1_activated_this_turn) or (not skill_2_activated_this_turn))
	):
		Signal.emit_signal("sgin_disable_player_play")
		match employee:
			"Assassin":
				set_activated_this_turn(ActivateMode.ALL, true)
				Signal.emit_signal("sgin_skill", "assassin")
			"Thief":
				set_activated_this_turn(ActivateMode.ALL, true)
				Signal.emit_signal("sgin_skill", "thief")
			"Magician":
				set_activated_this_turn(ActivateMode.ALL, true)
				Signal.emit_signal("sgin_skill", "magician")
			"King":
				set_activated_this_turn(ActivateMode.ALL, true)
				Signal.emit_signal("sgin_skill", "king")
			"Bishop":
				set_activated_this_turn(ActivateMode.ALL, true)
				Signal.emit_signal("sgin_skill", "bishop")
			"Merchant":
				Signal.emit_signal("sgin_skill", "merchant")			
			"Architect":
				set_activated_this_turn(ActivateMode.ALL, true)
				Signal.emit_signal("sgin_skill", "architect")
			"Warlord":
				Signal.emit_signal("sgin_skill", "warlord")
