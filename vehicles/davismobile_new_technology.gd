extends Sprite2D

var x = 0


func _process(delta: float) -> void:
	#skew += delta
	x += delta * 4
	scale.y = abs(sin(x))
