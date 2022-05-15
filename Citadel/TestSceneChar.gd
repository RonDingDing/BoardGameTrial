extends Node2D

onready var keys = $Data.char_data.keys()
onready var lang = "en"
onready var ind = 0
onready var offset = 0


func _ready():
	TranslationServer.set_locale(lang)
	init(ind)


func init(index: int):
	var card_name = keys[index]
	var original_offset = $Data.up_offset_char[lang].get(card_name, 0)
	$Label2.text = str(original_offset)
	$Label.text = str(offset)
	$CharacterCard.init(card_name, 1, original_offset + offset)


func on_pressed():
	offset = 0
	ind += 1
	if ind == keys.size():
		ind = 0
	init(ind)


func on_pressed2():
	lang = "zh_CN" if lang == "en" else "en"
	TranslationServer.set_locale(lang)
	offset = 0
	init(ind)


func _on_up_pressed():
	offset += 1
	init(ind)
	$Label.text = str(offset)


func _on_Down_pressed():
	offset -= 1
	init(ind)
	$Label.text = str(offset)
