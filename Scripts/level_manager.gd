extends Node

var terrain_types = {
	"grass": {
		"color": Color(0,0.6,0.29),
		"size": Vector2(100,100),
		"texture": "res://Assets/placeHolderImages/grass.jpg"
	},
	"desert": {
		"color": Color(0.8,0.7,0.3),
		"size": Vector2(80,80),
		"texture": "res://assets/sand.png",
		"heightmap": "res://assets/desert_height.png"
	},
	"mountains": {
		"color": Color(0.4,0.3,0.2),
		"size": Vector2(120,120),
		"texture": "res://assets/rock.png",
		"heightmap": "res://assets/Heightmap.png",
		"height_scale": 50.0
	},
	"village": {
		"color": Color(0.9,0.8,0.7),
		"size": Vector2(60,60),
		"texture": "res://assets/village_ground.png",
		"buildings": true
	}
}

func generate_terrain(type: String) -> StaticBody3D:
	var config = terrain_types[type]
	
	var terrain = StaticBody3D.new()
	terrain.name = "Terrain"
	
	# Mesh setup
	var mesh = PlaneMesh.new()
	mesh.size = config["size"]
	
	var textureImg = load(config["texture"])
	print(textureImg)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	mesh_instance.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = config["color"]
	material.albedo_texture = textureImg
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
	
	return terrain
	
func change_terrain(parent_node: Node3D, type: String):
	#Remove old terrain if exists
	for child in parent_node.get_children():
		if child.name == "Terrain":
			child.queue_free()
			await child.tree_exited #Wait for full removal
	
	# Add new terrain
	var new_terrain = generate_terrain(type)
	parent_node.add_child(new_terrain)
	new_terrain.owner = parent_node
	parent_node.move_child(new_terrain, 0) #This is to ensure its at the bottom of the scene tree
