extends "res://BasePlayer.gd"

onready var deck_base = [
	"Barracks1",
	"Barracks2",
	"Barracks3",
	"Castle1",
	"Castle2",
	"Castle3",
	"Castle4",
	"Cathedral1",
	"Cathedral2",
	"Church1",
	"Church2",
	"Church3",
	"Docks1",
	"Docks2",
	"Docks3",
	"Fortress1",
	"Fortress2",
	"Harbor1",
	"Harbor2",
	"Harbor3",
	"Manor1",
	"Manor2",
	"Manor3",
	"Manor4",
	"Manor5",
	"Market1",
	"Market2",
	"Market3",
	"Market4",
	"Monastery1",
	"Monastery2",
	"Monastery3",
	"Palace1",
	"Palace2",
	"Palace3",
	"Prison1",
	"Prison2",
	"Prison3",
	"Tavern1",
	"Tavern2",
	"Tavern3",
	"Tavern4",
	"Tavern5",
	"Temple1",
	"Temple2",
	"Temple3",
	"Town Hall1",
	"Town Hall2",
	"Trading Post1",
	"Trading Post2",
	"Trading Post3",
	"Watchtower1",
	"Watchtower2",
	"Watchtower3"
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
