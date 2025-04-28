extends Node3D

#@onready var player = $Player
#
#func _ready():
	## Wait for full initialization
	#await get_tree().process_frame
	#
	## Change terrain and get reference to new terrain
	#var new_terrain = await LevelManager.change_terrain(self, "grass")
	#
	### Position player safely above terrain
	##var safe_height = new_terrain.get_node("CollisionShape3D").shape.size.y/2 + 1.0
	##player.global_position = Vector3(0, safe_height, 0)
	##
	### Ensure camera updates
	##player.update_camera_position()
