extends Tween

onready var animation_time = 1


func animate(action_list: Array) -> void:
	var _useless
	for action in action_list:
		var node = action[0]
		var prop_name = action[1]
		var start_val = action[2]
		var end_val = action[3]
		var time = action[4] if action.size() > 4 else animation_time
		_useless = self.interpolate_property(
			node, prop_name, start_val, end_val, time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
		)
	_useless = self.start()
