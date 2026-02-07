extends Node2D

var car_previews = [
	[preload("res://models/MobCarTextured.glb"), 0.6, preload("res://vehicles/MafiaCar.tscn"), preload("res://UI/mob_css.png")],
	[preload("res://models/trolley combine.glb"), 0.8, preload("res://vehicles/BumCar.tscn"), preload("res://UI/bum_css.png")],
	[preload("res://models/greasecarTextured.glb"), 0.4, preload("res://vehicles/GreaserCar.tscn"), preload("res://UI/greaser_css.png")],
	[preload("res://models/rollsshmoyce Textured.glb"), 0.8, preload("res://vehicles/RollsRoyceCar.tscn"), preload("res://UI/royce_css.png")],
	[preload("res://models/boxcartTextured.glb"), 0.8, preload("res://vehicles/BoxCar.tscn"), preload("res://UI/kid_css.png")],
	[preload("res://models/new_davmobile.glb"), 1, preload("res://vehicles/JakeCar.tscn"), preload("res://UI/jakecar_css.png")],
]

var spinny: Node3D

var jakecar_unlocked: bool = false
var selected_idx: int = 2
var character_selected: bool = false

func _ready() -> void:
	var tween = $TransitionIn.create_tween()
	tween.tween_property($TransitionIn, "position", Vector2(-819, 0), 0.5)
	$SubViewport/Camera3D.look_at($SubViewport/Car.position)
	spinny = car_previews[selected_idx][0].instantiate()
	spinny.scale = Vector3.ONE * car_previews[selected_idx][1]
	$SubViewport/Car.add_child(spinny)

func _process(delta: float) -> void:
	$SubViewport/Car.rotate_y((0.5*PI*delta * (118.0/ 60.0)))
	if character_selected: return
	# jakecar unlock
	if Input.is_action_just_pressed("jake_key") and jakecar_unlocked == false:
		$JakecarHudPortrait.visible = true
		jakecar_unlocked = true
		Globals.play_sfx(preload("res://sfx/jaked-bitcrush.mp3"))
	# handle input
	if Input.is_action_just_pressed("steer_right"):
		selected_idx += 1
		Globals.play_sfx(preload("res://sfx/selectMOVE.wav"))
	elif Input.is_action_just_pressed("steer_left"):
		selected_idx -= 1
		Globals.play_sfx(preload("res://sfx/selectMOVE.wav"))
	elif Input.is_action_just_pressed("accelerate"):
		character_selected = true
		Globals.player_selected_car = car_previews[selected_idx][2]
		Globals.play_sfx(preload("res://sfx/acceptselect.wav"))
		var tween = $Transition.create_tween()
		tween.tween_property($Transition, "position", Vector2.ZERO, 0.5)
		await tween.finished
		get_parent().goto_race()
	elif Input.is_action_just_pressed("brake"):
		character_selected = true
		var tween = $Transition.create_tween()
		tween.tween_property($Transition, "position", Vector2.ZERO, 0.5)
		await tween.finished
		get_parent().goto_main_menu()
	var max_selectable = 5 if jakecar_unlocked else 4
	selected_idx = clamp(selected_idx, 0, max_selectable)
	update()
	$Label.text = "selected: " + str(selected_idx)
	#$Cursor.position = Vector2(83, 273) + Vector2(80*selected_idx, 0)
	var cursor_pos = Vector2(83, 273) + Vector2(80*selected_idx, 0)
	$Cursor.create_tween().tween_property($Cursor, "position", cursor_pos, 0.1)

func update():
	spinny.queue_free()
	spinny = car_previews[selected_idx][0].instantiate()
	spinny.scale = Vector3.ONE * car_previews[selected_idx][1]
	$CharacterBio.texture = car_previews[selected_idx][3]
	$SubViewport/Car.add_child(spinny)
