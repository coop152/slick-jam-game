extends Node3D

func _physics_process(delta: float) -> void:
	var path: Path3D = $Path3D
	# find how far the NPC is along the path
	
	var offset = path.curve.get_closest_offset($Player.global_position)
	# put the target 10 3d units ahead
	#offset += 10
	## get that advanced point on the path
	#var new_target = path.curve.sample_baked(offset)
	#$MeshInstance3D.position = new_target
