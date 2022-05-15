extends Node2D
enum Mode { ENLARGE, STATIC, SELECT, PLAY }
onready var mode = Mode.ENLARGE
onready var TweenMove = get_node("/root/Main/Tween")
onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var middle = get_viewport_rect().size / 2

func _ready():
	$CharacterCard.hide()
	$Card0.hide()
	$Card1.hide()
	$Card2.hide()


func set_mode(modes: int) -> void:
	mode = modes


func on_sgin_card_focused(card_name: String) -> void:
	if mode == Mode.ENLARGE:
		var card_info = Data.get_card_info(card_name)
		$Card0.show()
		$Card0.init_card(
			card_name,
			card_info["up_offset"],
			Vector2(0.6, 0.6),
			middle,
			true,
			true
		)


func on_sgin_card_unfocused() -> void:
	if mode == Mode.ENLARGE:
		$Card0.hide()


func on_sgin_char_focused(char_name: String) -> void:
	if mode == Mode.ENLARGE:
		var char_info = Data.get_char_info(char_name)
		$CharacterCard.show()
		$CharacterCard.init_char(
			char_name,
			char_info["char_num"],
			char_info["char_up_offset"],
			Vector2(0.5, 0.5),
			middle,
			true
		)


func on_sgin_char_unfocused() -> void:
	if mode == Mode.ENLARGE:
		$CharacterCard.hide()


func char_enter(card_info: Dictionary, scaling: Vector2, global_pos: Vector2) -> void:
	set_mode(Mode.STATIC)
	var move_pos
	if global_pos == middle:
		move_pos = $CharacterCard.global_position
	else:
		move_pos = global_pos
	$CharacterCard.show()
	$CharacterCard.init_char(
		card_info["char_name"],
		card_info["char_num"],
		card_info["char_up_offset"],
		Vector2(0.5, 0.5),
		middle,
		true
	)
	TweenMove.animate(
		[
			[
				$CharacterCard,
				"global_position",
				$CharacterCard.global_position,
				move_pos,
			],
			[
				$CharacterCard,
				"scale",
				Vector2(0.5, 0.5),
				scaling,
			]
		]
	)
	yield(TweenMove, "tween_all_completed")
	reset_characters()
	Signal.emit_signal("sgin_char_entered")
	set_mode(Mode.ENLARGE)


func reset_characters() -> void:
	set_mode(Mode.ENLARGE)
	$CharacterCard.set_global_position(middle)
	$CharacterCard.set_scale(Vector2(0.5, 0.5))
	$CharacterCard.hide()


func reset_cards() -> void:
	set_mode(Mode.ENLARGE)
	for i in range(3):
		var card = get_node(str("Card", i))
		card.set_global_position(middle)
		card.set_scale(Vector2(0.5, 0.5))
		card.hide()


func selectable_cards(cards: Array) -> void:
	set_mode(Mode.SELECT)
	var poss = [middle, middle, middle]
	if cards.size() == 1:
		$Card0.show()
		$Card1.hide()
		$Card2.hide()
	elif cards.size() == 2:
		poss[0] += Vector2(-250, 0)
		poss[1] += Vector2(250, 0)
		$Card0.show()
		$Card1.show()
		$Card2.hide()
	elif cards.size() == 3:
		poss[0] += (Vector2(-450, 0))
		poss[1] += (Vector2(0, 0))
		poss[2] += (Vector2(450, 0))
		$Card0.show()
		$Card1.show()
		$Card2.show()

	for i in range(cards.size()):
		var card_info = Data.get_card_info(cards[i])
		get_node(str("Card", i)).init_card(
			cards[i], card_info["up_offset"], Vector2(0.6, 0.6), poss[i], true, Mode.SELECT
		)