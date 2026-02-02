extends Node3D

func _physics_process(delta: float) -> void:	
	if Input.is_action_just_pressed("devkey"):
		$Player.position = Vector3(39, 208, 53)
