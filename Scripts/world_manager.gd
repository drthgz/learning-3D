extends Node3D

@onready var center_terrain = $CenterTerrain
@onready var east_terrain = $EastTerrain
@onready var west_terrain = $WestTerrain
@onready var north_terrain = $NorthTerrain


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_world()

func setup_world():
	print("=== Starting world setup ===")
	
	#Center grass plain
	print("Creating center terrain...")
	update_terrain(center_terrain, "grass")
	center_terrain.position = Vector3.ZERO
	
	# East Desert
	update_terrain(east_terrain, "desert")
	east_terrain.position = Vector3(80,0,0)
	
	# West Desert
	update_terrain(west_terrain, "mountains")
	west_terrain.position = Vector3(-90,0,0)
	
	# North Desert
	update_terrain(north_terrain, "village")
	north_terrain.position = Vector3(0,0,-70)
	spawn_village_buildings(north_terrain)
	print("=== World setup complete ===")
	
func update_terrain(terrain_node: StaticBody3D, type:String):
	# Get or create MeshInstance3D
	var mesh_instance = terrain_node.get_node_or_null("MeshInstance3D")
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		terrain_node.add_child(mesh_instance)
		mesh_instance.owner = terrain_node
	
	#Update terrain properties
	var config = LevelManager.terrain_types[type]
	
	#Configure mesh
	var mesh = PlaneMesh.new()
	mesh.size = config["size"]
	mesh_instance.mesh = mesh
	
	#Configure material
	var material = StandardMaterial3D.new()
	material.albedo_color = config["color"]
	mesh_instance.material_override = material
	
	#Configure collision
	var collision = terrain_node.get_node("CollisionShape3D")
	collision.shape.size = Vector3(config["size"].x, 1.0, config["size"].y)
	collision.position = Vector3(0,-0.5,0)
	
	#Make terrain visibile in editior
	terrain_node.set_meta("_edit_lock_", true)


func spawn_village_buildings(parent: Node3D):
	# Basic house spawning
	for i in range(5):
		var house = preload("res://Scenes/house.tscn").instantiate()
		house.position = Vector3(randf_range(-20,20), 0, randf_range(-20,20))
		parent.add_child(house)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player_pos = $Player.global_transform.origin 

	# Smooth biome transitions 
	if player_pos.x > 60:
		var terrain_a = east_terrain.get_node_or_null("MeshInstance3D")
		var terrain_b = center_terrain.get_node_or_null("MeshInstance3D")
		if terrain_a and terrain_b and terrain_a.material_override and terrain_b.material_override:
			lerp_terrain_properties(east_terrain, center_terrain, inverse_lerp(60.0, 80.0, player_pos.x))
	elif player_pos.x < -60:
		var terrain_a = west_terrain.get_node_or_null("MeshInstance3D")
		var terrain_b = center_terrain.get_node_or_null("MeshInstance3D")
		if terrain_a and terrain_b and terrain_a.material_override and terrain_b.material_override:
			lerp_terrain_properties(west_terrain, center_terrain, inverse_lerp(-60.0, -80.0, player_pos.x))
	elif player_pos.z < -50:
		var terrain_a = north_terrain.get_node_or_null("MeshInstance3D")
		var terrain_b = center_terrain.get_node_or_null("MeshInstance3D")
		if terrain_a and terrain_b and terrain_a.material_override and terrain_b.material_override:
			lerp_terrain_properties(north_terrain, center_terrain, inverse_lerp(-50.0, -70.0, player_pos.z))


# Function requires terrain nodes, not just MeshInstances passed
func lerp_terrain_properties(terrain_node_a: StaticBody3D, terrain_node_b: StaticBody3D, weight: float):
	var mesh_a = terrain_node_a.get_node_or_null("MeshInstance3D")
	var mesh_b = terrain_node_b.get_node_or_null("MeshInstance3D")

	if not mesh_a or not mesh_b:
		printerr("Missing MeshInstance in lerp_terrain_properties for ", terrain_node_a.name, " or ", terrain_node_b.name)
		return
		
	var mat_a = mesh_a.get_material_override() 
	var mat_b = mesh_b.get_material_override()

	if not mat_a or not mat_b:
		printerr("Missing material_override in lerp_terrain_properties for ", terrain_node_a.name, " or ", terrain_node_b.name)
		# You might want to assign a default material here if one is missing, or just return
		return

	if not mat_a is StandardMaterial3D or not mat_b is StandardMaterial3D:
		printerr("Materials are not StandardMaterial3D in lerp_terrain_properties")
		return

	var blended_mat = mat_b.duplicate() 
	blended_mat.albedo_color = lerp(mat_a.albedo_color, mat_b.albedo_color, clamp(weight, 0.0, 1.0)) 
	mesh_b.material_override = blended_mat
