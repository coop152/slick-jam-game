extends RigidBody3D

@onready var car_mesh: Node3D = $new_davmobile

# Where to place the car mesh relative to the sphere
var sphere_offset = Vector3.DOWN

func goHere(target: Vector3) -> void:
	$Pathfinding.target_position = target

func _physics_process(delta: float) -> void:
	pass
