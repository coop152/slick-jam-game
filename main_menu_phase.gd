extends Node2D

var button_actions = [
	func(): get_parent().goto_CSS(),
	func(): get_parent().goto_credits(),
	func(): get_tree().quit()
]

func _ready() -> void:
	var tween = $TransitionIn.create_tween()
	tween.tween_property($TransitionIn, "position", Vector2(-819, 0), 0.5)

var selected_idx: int = 0
var option_selected: bool = false

func _process(delta: float) -> void:
	if option_selected:
		return
	# handle input
	if Input.is_action_just_pressed("steer_right") or Input.is_action_just_pressed("menu_down"):
		selected_idx += 1
		Globals.play_sfx(Globals.MENU_MOVE_SFX)
	elif Input.is_action_just_pressed("steer_left") or Input.is_action_just_pressed("menu_up"):
		selected_idx -= 1
		Globals.play_sfx(Globals.MENU_MOVE_SFX)
	elif Input.is_action_just_pressed("accelerate"):
		option_selected = true
		Globals.play_sfx(Globals.MENU_ACCEPT_SFX)
		var tween = $Transition.create_tween()
		tween.tween_property($Transition, "position", Vector2.ZERO, 0.5)
		await tween.finished
		#get_parent().goto_CSS()
		button_actions[selected_idx].call()
	selected_idx = clamp(selected_idx, 0, 2)
	var cursor_pos = Vector2(366, 194) + (Vector2(-14, 58) * selected_idx)
	$Cursor.create_tween().tween_property($Cursor, "position", cursor_pos, 0.1)

var loop_track: AudioStreamOggVorbis = preload("res://music/menutheme-LOOP.ogg")

func _on_finished() -> void:
	$AudioStreamPlayer.stream = loop_track
	$AudioStreamPlayer.play()
