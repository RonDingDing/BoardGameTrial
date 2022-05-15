extends Node2D

onready var keys = $Data.card_data.keys()
onready var lang = "en"
onready var ind = 0


func _ready():
	var info_array = [0, 1, 2, 3, 4]
	var seat_num = 0
	var s = info_array.slice(seat_num, info_array.size()) + info_array.slice(0, seat_num - 1)
	print(s)

	TranslationServer.set_locale(lang)
	init(ind)


func init(index: int):
	var card_name = keys[index]
	$Card.init(card_name, $Data.up_offset[lang].get(card_name, 0))
	$Card/Back.visible = false
	$Card.scale = Vector2(0.75, 0.75)


func on_pressed():
	ind += 1
	if ind == keys.size():
		ind = 0
	init(ind)


func on_pressed2():
	lang = "zh_CN" if lang == "en" else "en"
	TranslationServer.set_locale(lang)
	init(ind)
