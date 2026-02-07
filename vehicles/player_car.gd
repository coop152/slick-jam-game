class_name PlayerCar
extends RigidBody3D

# TODO: DRIFTING IDEA
# When the car's facing angle is different enough from its velocity/inertia angle, start drifting.
# when drifting, a sideways force is applied to the car in the direction it is turning,
# perpendicular to the car's up vector and velocity (cross product i think).
# this could use a specific drift button, in which case the extra force is only applied when that button is held.
# it seems like in mario kart, pressing the drift button when you arent yet tilted enough will immediately turn your character to the side
# until they are turned enough to drift

@onready var car_mesh: Node3D = $Model
@onready var body_mesh = $"Model/CarMesh/Mainbody"
@onready var left_wheel = $"Model/CarMesh/FrontWheel L"
@onready var right_wheel = $"Model/CarMesh/FrontWheel R"
@onready var back_left_wheel = $"Model/CarMesh/RearWheel L"
@onready var back_right_wheel = $"Model/CarMesh/RearWheel R"
@onready var ground_ray: RayCast3D = $Model/CarMesh/RayCast3D

# Where to place the car mesh relative to the sphere
var sphere_offset = Vector3.DOWN * 1.5
# Engine power
var base_acceleration = 120.0
var deceleration_factor = 0.5
# maximum allowed speed
var max_speed = 80.0
# Turn amount, in degrees
var steering = 15.0
# How quickly the car turns
var base_turn_speed = 4.0
# Below this speed, the car doesn't turn
var turn_stop_limit = 0.75

var body_tilt = 35

var boost_charge: float = 0.0 # max 100
var boosting: bool = false

enum DriftState {
	Not,
	Left,
	Right
}
var drift_state = DriftState.Not

var race_time: float = 0.0
var current_lap_time: float = 0.0
var lap_times: Array[float] = []

var last_known_grounded_locations: Array = []

# Variables for input values
var speed_input = 0
var turn_input = 0

var acceleration = base_acceleration
var turn_speed = base_turn_speed

@export var input_disabled: bool = false

func _physics_process(_delta: float) -> void:
	car_mesh.position = position + sphere_offset
	var velocity_directed: float = linear_velocity.dot(car_mesh.global_transform.basis.z.normalized())
	if ground_ray.is_colliding():
		last_known_grounded_locations.append([position, car_mesh.rotation])
		# todo: store car mesh rotation also
		if last_known_grounded_locations.size() == 30:
			last_known_grounded_locations.pop_front()
		apply_central_force(car_mesh.global_transform.basis.z * speed_input)
		if drift_state != DriftState.Not:
			var v = car_mesh.global_transform.basis.y.cross(linear_velocity).normalized()
			apply_central_force(v * turn_input * velocity_directed)
	$HUD/SpeedCounter.text = str(int(velocity_directed))
	var capped = clamp(velocity_directed, 0, 120)
	$HUD/SpeedNeedle.create_tween().tween_property($HUD/SpeedNeedle, "rotation", (capped / 120) * PI, 0.05)

func _ready():
	car_mesh.top_level = true
	$Camera3D.top_level = true

func _process(delta):
	# handle boost bar refill
	if not input_disabled:
		boost_charge += delta * 10
	boost_charge = clamp(boost_charge, 0, 100)
	$HUD/BoostBar/BoostMask/Fill.position.x = lerp(-220, 0, boost_charge/100)
	# handle timer
	if not input_disabled:
		race_time += delta
		current_lap_time += delta
	$HUD/Timer.text = "%02d:%02d.%02d" % [race_time/60, int(race_time) % 60, (race_time - int(race_time)) * 100]
	# fiddle with engine noise
	var velocity_directed: float = linear_velocity.dot(car_mesh.global_transform.basis.z.normalized())
	$EngineSound.pitch_scale = 1 + (abs(velocity_directed) / 120) + (0.5 if boosting else 0)
	$EngineSound.volume_db = (30 if boosting else 20)
	if drift_state != DriftState.Not:
		$Model/GPUParticles3D.emitting = true
		if not $DriftSound.playing:
			$DriftSound.play()
	else:
		$Model/GPUParticles3D.emitting = false
		$DriftSound.stop()
	# position minimap indicator
	var minimap_center = $HUD/Minimap.position
	var pos: Vector2 = (Vector2(position.x, position.z) / 375.0) * 46.0
	$HUD/MinimapIndicator.position = minimap_center + pos
	$HUD/MinimapIndicator.rotation = -$Model.rotation.y + (PI / 2)
	
	handle_input(delta)

	# steer wheels
	right_wheel.create_tween().tween_property(right_wheel, "rotation", right_wheel.rotation + (Vector3(0,1,0) * (turn_input - right_wheel.rotation.y)), 0.05)
	left_wheel.create_tween().tween_property(left_wheel, "rotation", left_wheel.rotation + (Vector3(0,1,0) * (turn_input - left_wheel.rotation.y)), 0.05)
	# spin wheels
	right_wheel.create_tween().tween_property(right_wheel, "rotation", right_wheel.rotation + (Vector3(delta,0,0) * (velocity_directed)), 0.01)
	left_wheel.create_tween().tween_property(left_wheel, "rotation", left_wheel.rotation + (Vector3(delta,0,0) * (velocity_directed)), 0.01)
	back_right_wheel.create_tween().tween_property(back_right_wheel, "rotation", back_right_wheel.rotation + (Vector3(delta,0,0) * (velocity_directed)), 0.01)
	back_left_wheel.create_tween().tween_property(back_left_wheel, "rotation", back_left_wheel.rotation + (Vector3(delta,0,0) * (velocity_directed)), 0.01)

	# if car is moving fast enough, steer it
	if linear_velocity.length() > turn_stop_limit:
		# rotate car mesh by steer amount, spherical lerp for smoothing
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		# tilt car body
		var t = -turn_input * linear_velocity.length() / body_tilt
		body_mesh.rotation.z = lerp(-body_mesh.rotation.z, t, 5.0 * delta)
	# align car mesh with the ground angle
	if ground_ray.is_colliding():
		var n = ground_ray.get_collision_normal()
		var xform = align_with_y(car_mesh.global_transform, n)
		car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
	
func handle_input(delta):
	if input_disabled: 
		turn_input = 0
		speed_input = 0
		return
	# if boost is held, increase acceleration and decrease turn speed
	acceleration = base_acceleration
	turn_speed = base_turn_speed
		
	if Input.is_action_pressed("boost") and (boost_charge >= 25.0 or boosting) and boost_charge > 0:
		boosting = true
		boost_charge -= delta * 40
		acceleration *= 1.5
		turn_speed *= 0.75
		$Camera3D.create_tween().tween_property($Camera3D, "fov", 75, 0.5)
	else:
		boosting = false
		$Camera3D.create_tween().tween_property($Camera3D, "fov", 60, 0.5)
		
	# take inputs
	#speed_input = Input.get_axis("brake", "accelerate") * acceleration
	speed_input = (Input.get_action_strength("accelerate") * acceleration) \
		- (Input.get_action_strength("brake") * (acceleration * deceleration_factor))
	turn_input = Input.get_axis("steer_right", "steer_left") * deg_to_rad(steering)
	if Input.is_action_pressed("drift"):
		#turn_speed *= 1.5
		if drift_state == DriftState.Not and ground_ray.is_colliding():
			if turn_input == 0:
				pass
			elif turn_input > 0: # trying to drift left
				drift_state = DriftState.Left
			elif turn_input < 0: # trying to drift right
				drift_state = DriftState.Right
		
		if drift_state == DriftState.Left:
			turn_input += deg_to_rad(steering)
			turn_input *= 0.75
		elif drift_state == DriftState.Right:
			turn_input -= deg_to_rad(steering)
			turn_input *= 0.75
	elif drift_state != DriftState.Not:
		drift_state = DriftState.Not
	
### lap handling
var lap_count: int = 0
var highest_lap_achieved = 1
func _on_marker_detector_lap_count_incremented() -> void:
	if lap_count == 3:
		print("RACE FINISHED")
		Globals.play_sfx(Globals.RACE_FINISH_SFX)
		input_disabled = true
		$HUD/FinishText.visible = true
		$HUD/Popup.text = "LAP: " + ("%02d:%02d.%02d" % [current_lap_time/60, int(current_lap_time) % 60, (current_lap_time - int(current_lap_time)) * 100])
		$HUD/Popup.visible = true
		lap_times.append(current_lap_time)
		get_parent().stop_music()
		$EngineSound.stop()
		await get_tree().create_timer(3).timeout
		get_parent().play_music(Globals.RACE_WIN_MUSIC)
		$HUD/Transition/PostgameHUD/TimeSummary.text = "Total: " + format_timer(race_time) + \
			"\nLap 1: " + format_timer(lap_times[0]) + \
			"\nLap 2: " + format_timer(lap_times[1]) + \
			"\nLap 3: " + format_timer(lap_times[2])
		var tween = $HUD/Transition.create_tween()
		tween.tween_property($HUD/Transition, "position", Vector2.ZERO, 0.5)
		await tween.finished
		await get_tree().create_timer(9).timeout
		$HUD/Transition/PostgameHUD/Popup2.visible = true
		
	else:
		lap_count += 1
		if lap_count > highest_lap_achieved:
			Globals.play_sfx(Globals.MENU_ACCEPT_SFX)
			$HUD/Popup.text = "LAP: " + ("%02d:%02d.%02d" % [current_lap_time/60, int(current_lap_time) % 60, (current_lap_time - int(current_lap_time)) * 100])
			$HUD/Popup.visible = true
			lap_times.append(current_lap_time)
			current_lap_time = 0
			get_tree().create_timer(2).timeout.connect(func(): $HUD/Popup.visible = false)
		highest_lap_achieved = max(highest_lap_achieved, lap_count)
		print(str(lap_count))
		print(str(highest_lap_achieved))
		assert(lap_count >= 0 && lap_count <= 3)
		$HUD/LapCounter.animation = str(lap_count if lap_count >=1 else 1)

func _on_marker_detector_lap_count_decremented() -> void:
	lap_count = max(0, lap_count - 1)
	assert(lap_count >= 0 && lap_count <= 3)
	$HUD/LapCounter.animation = str(lap_count if lap_count >=1 else 1)


func _on_marker_detector_car_fell_off_road() -> void:
	self.input_disabled = true
	$Camera3D.position_lock = true
	Globals.play_sfx(Globals.DELTARUNE_EXPLOSION_SFX)
	$Model/Explosion.visible = true
	$Model/Explosion.play("default")
	await get_tree().create_timer(1).timeout
	self.linear_velocity = Vector3.ZERO
	self.position = last_known_grounded_locations[0][0]
	car_mesh.rotation = last_known_grounded_locations[0][1]
	$Model/Explosion.visible = false
	self.input_disabled = false
	$Camera3D.position_lock = false
	# why did i have this?
	#self.process_mode = Node.PROCESS_MODE_INHERIT


func _on_popup_2_pleeeeeeeease_put_me_back_in_char_select_plssssssssss() -> void:
	get_parent().get_parent().goto_CSS()

func format_timer(time: float):
	return ("%02d:%02d.%02d" % [time/60, int(time) % 60, (time - int(time)) * 100])
