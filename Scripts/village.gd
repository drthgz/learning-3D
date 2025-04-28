extends Node3D

@export var initial_terrain_type = "grass"
@onready var terrain_node = $Terrain  # Reference to existing terrain
func _ready() -> void:
	# Wait one frame to ensure everything loads
	await get_tree().process_frame
	update_terrain(initial_terrain_type)
	# Call this anywhere to change terrain:
	LevelManager.change_terrain(terrain_node,"grass")

func update_terrain(type: String):
	var mesh_instance = terrain_node.get_node_or_null("MeshInstance3D")
	
	# Create mesh instance if it doesn't exist
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		terrain_node.add_child(mesh_instance)
		mesh_instance.owner = terrain_node
	
	# Update terrain properties
	var config = LevelManager.terrain_types[type]
	
	# Configure mesh
	var mesh = PlaneMesh.new()
	mesh.size = config["size"]
	mesh_instance.mesh = mesh
	
	# Configure material
	var material = StandardMaterial3D.new()
	material.albedo_color = config["color"]
	mesh_instance.material_override = material
	
	# Configure collision (using existing BoxShape)
	var collision = terrain_node.get_node("CollisionShape3D")
	collision.shape.size = Vector3(config["size"].x, 1.0, config["size"].y)
	collision.position = Vector3(0, -0.5, 0)
