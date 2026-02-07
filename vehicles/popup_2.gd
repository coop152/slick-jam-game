extends Label

signal PLEEEEEEEEASE_put_me_back_in_char_select_plssssssssss

var only_one_time: bool = false

func _process(delta: float) -> void:
	if self.visible and Input.is_action_just_pressed("accelerate") and not only_one_time:
		only_one_time = true
		await get_parent().create_tween().tween_property(get_parent(), "scale", Vector2(0, 0), 1).finished
		#get_tree().return_to_character_select()
		PLEEEEEEEEASE_put_me_back_in_char_select_plssssssssss.emit()
