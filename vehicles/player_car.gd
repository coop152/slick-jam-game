extends RigidBody3D

@onready var car_mesh: Node3D = $CarMesh
@onready var body_mesh = $"CarMesh/Mainbody"
@onready var left_wheel = $"CarMesh/FrontWheel L"
@onready var right_wheel = $"CarMesh/FrontWheel R"
#@onready var back_left_wheel = $CarMesh/backleftWheel
#@onready var back_right_wheel = $CarMesh/backrightWheel
@onready var ground_ray: RayCast3D = $CarMesh/RayCast3D

# Where to place the car mesh relative to the sphere
var sphere_offset = Vector3.DOWN * 1.5
# Engine power
var acceleration = 100.0
# maximum allowed speed
var max_speed = 80.0
# Turn amount, in degrees
var steering = 15.0
# How quickly the car turns
var turn_speed = 4.0
# Below this speed, the car doesn't turn
var turn_stop_limit = 0.75

var body_tilt = 35

# Variables for input values
var speed_input = 0
var turn_input = 0
func _physics_process(_delta: float) -> void:
	car_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		apply_central_force(car_mesh.global_transform.basis.z * speed_input)
		#if Input.is_action_just_pressed("boost"): # temporary jump
			#apply_central_impulse(car_mesh.global_transform.basis.y * 20)
	$Mask/HUD/SpeedCounter.text = str(int(linear_velocity.length()))


#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#if state.linear_velocity.length() > max_speed:
		#state.linear_velocity = state.linear_velocity.normalized() * max_speed

func _ready():
	#car_mesh.global_transform.basis.y = self.global_transform.basis.y
	#car_mesh.rotation.y = self.rotation.y
	car_mesh.top_level = true
	$Camera3D.top_level = true

func _process(delta):
	# if boost is held, increase acceleration and decrease turn speed
	var real_acc = acceleration
	var real_turn_speed = turn_speed
	if Input.is_action_pressed("boost"):
		real_acc *= 1.5
		real_turn_speed *= 0.75
		$Camera3D.create_tween().tween_property($Camera3D, "fov", 75, 0.5) 
	else:
		$Camera3D.create_tween().tween_property($Camera3D, "fov", 60, 0.5)
		
	# take inputs
	speed_input = Input.get_axis("brake", "accelerate") * real_acc
	turn_input = Input.get_axis("steer_right", "steer_left") * deg_to_rad(steering)
	# turn wheels
	right_wheel.create_tween().tween_property(right_wheel, "rotation", right_wheel.rotation + (Vector3(0,1,0) * (turn_input - right_wheel.rotation.y)), 0.05)
	left_wheel.create_tween().tween_property(left_wheel, "rotation", left_wheel.rotation + (Vector3(0,1,0) * (turn_input - left_wheel.rotation.y)), 0.05)
	# if car is moving fast enough, steer
	if linear_velocity.length() > turn_stop_limit:
		# rotate car mesh by steer amount, spherical lerp for smoothing
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, real_turn_speed * delta)
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
	

var lap_count: int = 0

func _on_marker_detector_lap_count_incremented() -> void:
		if lap_count == 3:
			get_tree().paused = true
			print("RACE FINISHED")
		else:
			lap_count += 1
			$Mask/HUD/LapCounter.text = "larp " + str(lap_count)


func _on_marker_detector_lap_count_decremented() -> void:
	lap_count = max(0, lap_count - 1)
	$Mask/HUD/LapCounter.text = "larp " + str(max(lap_count, 1))
