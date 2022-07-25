extends Node2D
onready var Card = preload("res://Card.tscn")
onready var Data = get_node("/root/Main/Data")
onready var TweenMove = get_node("/root/Main/Tween")

func _ready():
	var card_name = "Tavern"
	var card2_name = "Palace"
	var incoming_card1 = Card.instance()
	var incoming_card2 = Card.instance()
	var start_scale = Vector2(0.4, 0.4)
	var from_pos1 = Vector2(300, 400)
	var from_pos2 = Vector2(600, 400)
	incoming_card1.init_card(card_name, start_scale, from_pos1, true, Data.CardMode.ENLARGE)
	add_child(incoming_card1)
	
	incoming_card2.init_card(card2_name, start_scale, from_pos2, true, Data.CardMode.ENLARGE)
	add_child(incoming_card2)
	
	
	var a1 = TweenMove.ScalingMotion.new(incoming_card1, from_pos1, Vector2(400, 400), Vector2(0.4, 0.4), Vector2(1,1))
	var t1 = TweenMove.Interval.new(1)
	var a2 = TweenMove.ScalingMotion.new(incoming_card1, Vector2(400, 400), from_pos1, Vector2(1, 1), Vector2(0.5,0.5))
	
	var a3 = TweenMove.ScalingMotion.new(incoming_card2, from_pos2, Vector2(800, 800), Vector2(0.4, 0.4), Vector2(1,1))
	var a4 = TweenMove.ScalingMotion.new(incoming_card2, Vector2(800, 800), from_pos2, Vector2(1, 1), Vector2(0.5,0.5))
	
	
	TweenMove.animate([a1, a2])
	TweenMove.animate([a3, t1, a4])
