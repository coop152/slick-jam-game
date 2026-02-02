class_name LapMarker
extends Area3D

enum MarkerType {
	Before,
	Lap,
	After
}

@export var marker_type: MarkerType 

# the range of lap numbers is 0-3.
# You start on lap 0, and immediately begin on lap 1
# when you pass the finish line at the start of the race.
# The lap number cannot go negative (you cannot go in reverse to reach lap -1, for example)
# "lap 0" should be displayed as lap 1, but stored as lap 0 internally.
# when you would reach lap 4, the game ends instead.

#signal lap_number_updated(new_val: int)
#
#var approaching_lap_marker: bool = false
#var lap_num: int = 0
#
#func lap_marker_entered(body: Node3D) -> void:
	#print("entered lap marker")
	#if approaching_lap_marker:
		#if lap_num == 3:
			#get_tree().paused = true
			#print("RACE FINISHED")
		#else:
			#lap_num += 1
	#else:
		#lap_num = max(0, lap_num - 1)
	#print("LAP UPDATED: " + str(lap_num))
	#lap_number_updated.emit(lap_num)
#
#
#func before_marker_entered(body: Node3D) -> void:
	##print("entered before marker")
	#approaching_lap_marker = true
	#
	#
#func after_marker_entered(body: Node3D) -> void:
	##print("entered after marker")
	#approaching_lap_marker = false
