extends Node2D
onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
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


func shuffle():
	randomize()
	deck.shuffle()


func pop() -> String:
	return deck.pop_front()


func extend(card_names: Array) -> void:
	deck.append_array(card_names)


func draw_card(relative_to_me: int, pos: Vector2, face_is_up: bool):
	var card_name = deck.pop_front()
	Signal.emit_signal("sgin_draw_card", relative_to_me, card_name, pos, face_is_up)


func on_sgin_start_game(all_player_length):
	# 洗牌
	shuffle()

	# 每个玩家派4张牌
	for _i in range(4):
		for relative_to_me in range(all_player_length):
			draw_card(relative_to_me, position, false)
			if relative_to_me == 0:
				yield(Signal, "sgin_player_draw_ready")
			else:
				yield(Signal, "sgin_opponent_draw_ready")
	Signal.emit_signal("sgin_card_dealt", all_player_length)
