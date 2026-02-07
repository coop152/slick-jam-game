extends Area3D

signal lap_count_incremented()
signal lap_count_decremented()
signal car_fell_off_road()

var approaching_lap_marker: bool = false

func _on_area_entered(area: Area3D) -> void:
	# check the area is a lap marker
	if area is LapMarker:
		match area.marker_type:
			LapMarker.MarkerType.Before:
				print("entered before marker")
				approaching_lap_marker = true
			LapMarker.MarkerType.Lap:
				print("entered lap marker")
				if approaching_lap_marker:
					lap_count_incremented.emit()
				else:
					lap_count_decremented.emit()
			LapMarker.MarkerType.After:
				print("entered after marker")
				approaching_lap_marker = false
	elif area is Deathzone:
		print("FELL OFF !!!!!!!!!!!!!")
		car_fell_off_road.emit()
