extends Node

var terrain_types = {
	"grass": {
		"color": Color(0,0.6,0.29),
		"size": Vector2(12,30),
		"texture": "res://Assets/grass_texture.png"  # Add later
	},
	"desert": {
		"color": Color(0.8,0.7,0.3),
		"size": Vector2(20,20),
		"texture": "res://Assets/sand_texture.png"
	},
	"forest": {
		"color": Color(0.1,0.4,0.2),
		"size": Vector2(15,15),
		"texture": "res://Assets/forest_texture.png"
	},
	"snow": {
		"color": Color(0.9,0.9,1.0),
		"size": Vector2(25,25),
		"texture": "res://Assets/snow_texture.png"
	}
}

func generate_terrain(parent_node: Node3D, type: String) -> StaticBody3D:
	var config = terrain_types[type]
	
	var terrain = StaticBody3D.new()
	terrain.name = "Terrain"  # Fixed typo in name
	
	# Mesh setup
	var mesh = PlaneMesh.new()
	mesh.size = config["size"]
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"  # Unique name
	mesh_instance.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = config["color"]
	mesh_instance.material_override = material
	
	# Collision setup
	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.shape.size = Vector3(config["size"].x, 0.2, config["size"].y)
	collision.position = Vector3(0, -0.1, 0)
	
	# Build hierarchy
	terrain.add_child(mesh_instance)
	terrain.add_child(collision)
	
	# Set ownership
	mesh_instance.owner = terrain
	collision.owner = terrain
	terrain.owner = parent_node
	
	return terrain
	
func change_terrain(parent_node: Node3D, type: String):
	#Remove old terrain if exists
	for child in parent_node.get_children():
		if child.name == "Terrain":
			child.queue_free()
			await child.tree_exited #Wait for full removal
	
	# Add new terrain
	var new_terrain = generate_terrain(parent_node, type)
	parent_node.add_child(new_terrain)
	new_terrain.owner = parent_node
	parent_node.move_child(new_terrain, 0) #This is to ensure its at the bottom of the scene tree
