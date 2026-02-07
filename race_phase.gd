extends Node3D

@onready var player_car: PlayerCar = $PlayerCar
@onready var spawn_point = $Map/PlayerSpawn

var track_music = preload("res://music/track1_START.ogg")
var track_music_loop = preload("res://music/track1_LOOP.ogg")

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("devkey"):
		player_car.global_transform = spawn_point.global_transform

func _ready() -> void:
	# spawn the player's chosen car
	print("car picked: " + str(Globals.player_selected_car))
	player_car.free()
	player_car = Globals.player_selected_car.instantiate()
	add_child(player_car)
	player_car.name = "PlayerCar"
	player_car.global_transform = spawn_point.global_transform
	player_car.car_mesh.global_transform = spawn_point.global_transform
	# play the scene-in transition and race start sequence
	$MusicPlayer.stream = track_music
	$MusicPlayer.play()
	$AnimationPlayer.play("race_start")
	await $AnimationPlayer.animation_finished


func _on_music_player_finished() -> void:
	if $MusicPlayer.stream == track_music or $MusicPlayer.stream == track_music_loop:
		$MusicPlayer.stream = track_music_loop
		$MusicPlayer.play()

func stop_music():
	$MusicPlayer.stop()

func play_music(resource: AudioStreamOggVorbis):
	$MusicPlayer.stream = resource
	$MusicPlayer.play()
