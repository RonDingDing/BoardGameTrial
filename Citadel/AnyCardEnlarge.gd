extends Node2D
onready var TweenMove = get_node("/root/Main/Tween")
onready var Signal = get_node("/root/Main/Signal")
onready var Data = get_node("/root/Main/Data")
onready var mode = Data.CardMode.ENLARGE
onready var center = get_viewport_rect().size / 2
onready var enlarging = ""


func _ready():
	reset_cards()
	reset_characters()


func set_mode(modes: int) -> void:
	mode = modes


func assassinate(char_name: String) -> void:
	on_sgin_char_focused(char_name, true)
	set_mode(Data.CardMode.ASSASSINATING)
	TweenMove.animate(
		[
			[
				$KillSword,
				"global_position",
				Vector2(-900, $CharacterCard.global_position.y),
				$CharacterCard.global_position,
				2
			]
		]
	)
	yield(TweenMove, "tween_all_completed")
	set_mode(Data.CardMode.ENLARGE)
	$CharacterCard.hide()
	$KillSword.set_global_position(Vector2(-99999, -99999))


func steal(char_name: String) -> void:
	on_sgin_char_focused(char_name, true)
	set_mode(Data.CardMode.STEALING)
	TweenMove.animate(
		[
			[
				$StealPocket,
				"global_position",
				$CharacterCard.global_position,
				Vector2(2000, $CharacterCard.global_position.y),
				2
			]
		]
	)
	yield(TweenMove, "tween_all_completed")
	set_mode(Data.CardMode.ENLARGE)
	$CharacterCard.hide()
	$StealPocket.set_global_position(Vector2(-99999, -99999))


func on_sgin_card_focused(card_name: String) -> void:
	if mode == Data.CardMode.ENLARGE and enlarging != card_name:
		$CharacterCard.hide()
		enlarging = card_name
		var card_info = Data.get_card_info(card_name)
		$Card0.show()
		$Card0.init_card(
			card_name,
			card_info["up_offset"],
			Vector2(0.6, 0.6),
			center,
			true,
			Data.CardMode.ENLARGE
		)


func on_sgin_card_unfocused(card_name: String) -> void:
	if mode == Data.CardMode.ENLARGE and enlarging == card_name:
		enlarging = "Unknown"
		$Card0.hide()


func on_sgin_char_focused(char_name: String, forced: bool=false) -> void:
	var condition = true
	if not forced:
		condition = enlarging != char_name
	
	if mode == Data.CardMode.ENLARGE and condition:
		$Card0.hide()
		enlarging = char_name
		var char_info = Data.get_char_info(char_name)
		$CharacterCard.show()
		$CharacterCard.init_char(
			char_name,
			char_info["char_num"],
			char_info["char_up_offset"],
			Vector2(0.5, 0.5),
			center,
			true
		)


func on_sgin_char_unfocused(char_name: String) -> void:
	if mode == Data.CardMode.ENLARGE and enlarging == char_name:
		enlarging = "Unknown"
		$CharacterCard.hide()


func char_enter(char_name: String, start_pos: Vector2, end_pos: Vector2, start_scale: Vector2, end_scale: Vector2) -> void:
	var char_info = Data.get_char_info(char_name)
	set_mode(Data.CardMode.STATIC)
	$CharacterCard.show()
	$CharacterCard.init_char(
		char_name,
		char_info["char_num"],
		char_info["char_up_offset"],
		start_scale,
		start_pos,
		true
	)
	TweenMove.animate(
		[
			[
				$CharacterCard,
				"global_position",
				start_pos,
				end_pos,
			],
			[
				$CharacterCard,
				"scale",
				start_scale,
				end_scale,
			]
		]
	)
	yield(TweenMove, "tween_all_completed")
	reset_characters()
	Signal.emit_signal("sgin_char_entered")
	set_mode(Data.CardMode.ENLARGE)


func reset_characters() -> void:
	set_mode(Data.CardMode.ENLARGE)
	$CharacterCard.set_global_position(center)
	$CharacterCard.set_scale(Vector2(0.5, 0.5))
	$CharacterCard.hide()


func reset_cards() -> void:
	set_mode(Data.CardMode.ENLARGE)
	for i in range(3):
		var card = get_node(str("Card", i))
		card.set_global_position(center)
		card.set_scale(Vector2(0.5, 0.5))
		card.set_can_be_top(false)
		card.hide()


func selectable_cards(cards: Array) -> void:
	set_mode(Data.CardMode.SELECT)
	var poss = [center, center, center]
	if cards.size() == 1:
		$Card0.show()
		$Card0.set_can_be_top(true)
		$Card1.hide()
		$Card2.hide()
	elif cards.size() == 2:
		poss[0] += Vector2(-250, 0)
		poss[1] += Vector2(250, 0)
		$Card0.show()
		$Card0.set_can_be_top(true)
		$Card1.show()
		$Card1.set_can_be_top(true)
		$Card2.hide()
	elif cards.size() == 3:
		poss[0] += (Vector2(-450, 0))
		poss[1] += (Vector2(0, 0))
		poss[2] += (Vector2(450, 0))
		$Card0.show()
		$Card0.set_can_be_top(true)
		$Card1.show()
		$Card1.set_can_be_top(true)
		$Card2.show()
		$Card2.set_can_be_top(true)

	for i in range(cards.size()):
		var card_info = Data.get_card_info(cards[i])
		get_node(str("Card", i)).init_card(
			cards[i], card_info["up_offset"], Vector2(0.6, 0.6), poss[i], true, Data.CardMode.SELECT
		)
