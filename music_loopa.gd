extends AudioStreamPlayer

@export var loop_track: AudioStreamOggVorbis

func _on_finished() -> void:
	stream = loop_track
	play()
