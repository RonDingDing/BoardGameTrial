extends Node
onready var Data = get_node("/root/Main/Data")


func _ready():
	pass


#	$"..".position = Vector2(660, 460)
#	init_current()

var index = 0
var current_name = "Park"
var current_lang = "cn"
var current_up_offset = 0


func init_current():
	var all_data = Data
	var name_text = all_data.get_card_name(current_name)
	var description = all_data.get_desc(current_name)
	var up_offset = all_data.get_up_offset(current_name)
	$"..".init(name_text, description, up_offset)


func _on_ChangeLang_pressed():
	var all_data = Data
	var card_data = all_data.card_data
	current_lang = "cn" if current_lang == "en" else "en"
	print(current_lang)
#	current_name = "Museum"
	init_current()


func _on_ChangeCard_pressed():
	var all_data = Data
	var card_data = all_data.card_data

	var keys = card_data.keys()
	var animation_name = ""
	if index + 1 < keys.size():
		animation_name = keys[index + 1]
		index += 1
	else:
		animation_name = keys[0]
		index = 0
	current_name = animation_name
#	current_name = "Museum"
	init_current()


func _on_Add_upset_mouse_entered():
	current_up_offset += 1
	$Upset.text = str(current_up_offset)
	init_current()


func _on_Minus_upset_mouse_entered():
	current_up_offset -= 1
	$Upset.text = str(current_up_offset)
	init_current()


func _on_Add_upset_mouse_exited():
	pass


func _on_Minus_upset_mouse_exited():
	pass
