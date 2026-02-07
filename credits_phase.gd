extends Node2D


func _ready() -> void:
	var tween = $TransitionIn.create_tween()
	tween.tween_property($TransitionIn, "position", Vector2(-819, 0), 0.5)

var selected_idx: int = 0
var option_selected: bool = false

func _process(delta: float) -> void:
	if option_selected:
		return
	# handle input
	if Input.is_action_just_pressed("accelerate") or Input.is_action_just_pressed("brake"):
		option_selected = true
		Globals.play_sfx(Globals.MENU_ACCEPT_SFX)
		var tween = $Transition.create_tween()
		tween.tween_property($Transition, "position", Vector2.ZERO, 0.5)
		await tween.finished
		get_parent().goto_main_menu()

var loop_track: AudioStreamOggVorbis = preload("res://music/timetrial-LOOP.ogg")

func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.stream = loop_track
	$AudioStreamPlayer.play()
