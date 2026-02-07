extends Node

var RACE_FINISH_SFX = preload("res://sfx/racefinishwhistle.wav")
var RACE_WIN_MUSIC = preload("res://music/racewin_NEW.ogg")
var MENU_ACCEPT_SFX = preload("res://sfx/acceptselect.wav")
var MENU_MOVE_SFX = preload("res://sfx/selectMOVE.wav")
var DELTARUNE_EXPLOSION_SFX = preload("res://sfx/deltarune-explosion.mp3")
var JAKE_DAVIS_UNLOCKED = preload("res://sfx/jaked-bitcrush.mp3")

var player_selected_car: Resource

# modifications anonymous function must take the player object as an argument
func play_sfx(sfx: AudioStream, modifications: Callable = Callable()):
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = sfx
		player.bus = "SFX"
		if modifications.is_valid():
			modifications.call(player)
		player.play()
		player.finished.connect(func(): player.queue_free())
