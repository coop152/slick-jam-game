extends Camera3D

@export var lerp_speed = 3.0
@export var offset = Vector3.ZERO
@export var target : PlayerCar

var position_lock: bool = false

func _physics_process(delta):
	if !target:
		return
	var velocity_directed: float = target.linear_velocity.length()
	var lerp_speed_fr = lerp_speed * (1 + velocity_directed / 180)
	var target_pos = target.car_mesh.global_transform.translated_local(offset)
	if not position_lock: 
		global_transform = global_transform.interpolate_with(target_pos, lerp_speed_fr * delta)
	look_at(target.car_mesh.global_position + Vector3(0, 1, 0), Vector3.UP)
