extends Node2D

onready var hands = []
onready var built = []
onready var player_num = -5
onready var gold = 0
onready var username = "Unknown"
onready var employee = "Unchosen"
onready var employee_num = -1
onready var has_crown = false
onready var hide_employee = true
onready var museum_num = 0


func add_gold(_num: int) -> void:
	pass


func get_my_player_info() -> Dictionary:
	return {
		"player_num": player_num,
		"username": username,
		"money": gold,
		"employee": employee,
		"employee_num": employee_num,
		"hands": hands,
		"built": built,
		"has_crown": has_crown,
		"hide_employee": hide_employee, 
		"museum_num": museum_num
	}
