extends Node

var main_menu = preload("res://MainMenuPhase.tscn")
var character_select = preload("res://CharSelectPhase.tscn")
var race_phase = preload("res://RacePhase.tscn")
var credits_phase = preload("res://CreditsPhase.tscn")

var current_phase: Node
var next_phase: Node

func _ready() -> void:
	#current_phase = character_select.instantiate()
	current_phase = main_menu.instantiate()
	add_child(current_phase)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func goto_main_menu():
	next_phase = main_menu.instantiate()
	add_child(next_phase)
	if not next_phase.is_node_ready():
		await next_phase.ready
	current_phase.queue_free()
	current_phase = next_phase
	next_phase = null

func goto_CSS():
	next_phase = character_select.instantiate()
	add_child(next_phase)
	if not next_phase.is_node_ready():
		await next_phase.ready
	current_phase.queue_free()
	current_phase = next_phase
	next_phase = null

func goto_race():
	next_phase = race_phase.instantiate()
	add_child(next_phase)
	if not next_phase.is_node_ready():
		await next_phase.ready
	current_phase.queue_free()
	current_phase = next_phase
	next_phase = null

func goto_credits():
	next_phase = credits_phase.instantiate()
	add_child(next_phase)
	if not next_phase.is_node_ready():
		await next_phase.ready
	current_phase.queue_free()
	current_phase = next_phase
	next_phase = null
