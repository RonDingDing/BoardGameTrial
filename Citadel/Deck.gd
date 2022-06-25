extends "res://BasePlayer.gd"

onready var deck_base = [
	"Monastery",
	"Temple",
	"Monastery",
	"Castle",
	"Church",
	"Church",
	"Temple",
	"Cathedral",
	"Church",
	"Cathedral",
	"Temple",
	"Monastery",
	"Manor",
	"Castle",
	"Manor",
	"Manor",
	"Castle",
	"Palace",
	"Manor",
	"Manor",
	"Palace",
	"Prison",
	"Prison",
	"Barracks",
	"Barracks",
	"Fortress",
	"Watchtower",
	"Prison",
	"Palace",
	"Castle",
	"Market",
	"Tavern",
	"Docks",
	"Market",
	"Harbor",
	"Barracks",
	"Watchtower",
	"Fortress",
	"Watchtower",
	"Harbor",
	"Tavern",
	"Trading Post",
	"Tavern",
	"Trading Post",
	"Town Hall",
	"Tavern",
	"Town Hall",
	"Market",
	"Tavern",
	"Market",
	"Harbor",
	"Docks",
	"Docks",
	"Trading Post",
]

onready var deck_standard_unique = [
	"Dragon Gate",
	"Factory",
	"Haunted Quarter",
	"Imperial Treasury",
	"Keep",
	"Laboratory",
	"Library",
	"Map Room",
	"Quarry",
	"School of Magic",
	"Smithy",
	"Statue",
	"Thieves' Den",
	"Wishing Well",
]

onready var deck = deck_base + deck_standard_unique

func _ready() -> void:
	player_num = -1
	
func shuffle():
	randomize()
	deck.shuffle()


func pop() -> String:
	return deck.pop_front()


func extend(card_names: Array) -> void:
	deck.append_array(card_names)
