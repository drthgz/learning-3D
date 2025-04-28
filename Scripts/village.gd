extends Node3D

@export var initial_terrain_type = "grass"
var current_terrain: StaticBody3D
var terrain_holder: Node3D

func _ready() -> void:
	# Create holder node
	terrain_holder = Node3D.new()
	terrain_holder.name = "TerrainHolder"
	add_child(terrain_holder)
	terrain_holder.owner = self
	
	# Initial terrain generation
	await generate_new_terrain(initial_terrain_type)
	
	# Debug after ensuring terrain exists
	print("Full scene tree:", get_tree().root.get_child(0).get_children())
	if current_terrain:
		print("Terrain children: ", current_terrain.get_children())
		var mesh = current_terrain.get_node_or_null("MeshInstance3D")
		print("Mesh exists: ", mesh != null)
		if mesh:
			print("Mesh visibility: ", mesh.visible)

func generate_new_terrain(type: String):
	# Clear existing
	for child in terrain_holder.get_children():
		child.queue_free()
		await child.tree_exited
	
	# Generate new terrain
	current_terrain = LevelManager.generate_terrain(terrain_holder, type)
	terrain_holder.add_child(current_terrain)
	
	# Wait for proper initialization
	await get_tree().process_frame
	
	# Position and debug
	current_terrain.global_position = Vector3.ZERO
	print("Terrain added to holder: ", terrain_holder.get_children())
