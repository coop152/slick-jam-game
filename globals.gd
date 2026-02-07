extends Node

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
