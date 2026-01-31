extends RigidBody3D

@onready var car_mesh: Node3D = $new_davmobile
@onready var body_mesh = $new_davmobile/body
@onready var left_wheel = $new_davmobile/frontleftWheel
@onready var right_wheel = $new_davmobile/frontrightWheel
@onready var back_left_wheel = $new_davmobile/backleftWheel
@onready var back_right_wheel = $new_davmobile/backrightWheel
@onready var ground_ray: RayCast3D = $new_davmobile/RayCast3D

# Where to place the car mesh relative to the sphere
var sphere_offset = Vector3.DOWN
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
func _physics_process(delta: float) -> void:
	car_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		apply_central_force(car_mesh.global_transform.basis.x * speed_input)
		if Input.is_action_just_pressed("boost"): # temporary jump
			apply_central_impulse(car_mesh.global_transform.basis.y * 20)
	$HUD/Label.text = str(int(linear_velocity.length()))


#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#if state.linear_velocity.length() > max_speed:
		#state.linear_velocity = state.linear_velocity.normalized() * max_speed

func _process(delta):
	#if not ground_ray.is_colliding():
		#return
	speed_input = Input.get_axis("brake", "accelerate") * acceleration
	turn_input = Input.get_axis("steer_right", "steer_left") * deg_to_rad(steering)
	right_wheel.rotation.y = turn_input
	left_wheel.rotation.y = turn_input
	#back_right_wheel.rotation.y = -turn_input
	#back_left_wheel.rotation.y = -turn_input
	if linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		var t = -turn_input * linear_velocity.length() / body_tilt
		body_mesh.rotation.x = lerp(-body_mesh.rotation.x, t, 5.0 * delta)
		if ground_ray.is_colliding():
			var n = ground_ray.get_collision_normal()
			var xform = align_with_y(car_mesh.global_transform, n)
			car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
