extends CanvasLayer

func _ready():
	$ColorRect.hide()

func change_scene() -> void:
	var tween = Tween.new()
	add_child(tween)
	$ColorRect.show()
	tween.interpolate_property($ColorRect, "color:a", 0.2, 1.0, 1)
	tween.interpolate_callback(get_tree(), 0.1, "change_scene", "res://End.tscn")
	tween.interpolate_property($ColorRect, "color:a", 1.0, 0.2, 1)
	tween.start()
	yield(tween, "tween_all_completed")
	$ColorRect.hide()
