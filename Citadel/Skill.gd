extends Node
onready var Signal = get_node("/root/Main/Signal")
onready var assassinated = [0, "Unchosen"]
onready var stolen = [0, "Unchosen"]
var full_num = 0
#### Skills - Cards
const deck_num = -1
const bank_num = -2
const unfound = -3
onready var first_person_num = 0

onready var player_built_color = {
	"red": 0,
	"yellow": 0,
	"blue": 0,
	"green": 0,
	"purple": 0
}










