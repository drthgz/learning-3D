extends Node3D

# Preload the house scene if you built it visually
var house_scene = preload("res://Scenes/house.tscn")

# --- Noise for Mountains ---
var noise = FastNoiseLite.new()
var noise_seed = randi()

func _ready():
	print("--- Starting Procedural World Generation ---")
	noise.seed = noise_seed
	noise.frequency = 0.02 # Controls mountains terrain

	generate_world_layout()
	print("--- World Generation Complete ---")

func generate_world_layout():
	# Define the layout grid (adjust positions as needed)
	# Using chunk size from LevelConfig for positioning
	var chunk_size = LevelConfig.TERRAIN_CHUNK_SIZE
	
	# Center (House Area)
	var center_pos = Vector3.ZERO
	create_terrain_chunk(center_pos, "center")
	spawn_house(center_pos)

	# West (Mountains)
	var west_pos = Vector3(-chunk_size.x, 0, 0)
	create_terrain_chunk(west_pos, "mountains")
	create_terrain_chunk(west_pos + Vector3(-chunk_size.x, 0, 0), "mountains")

	# East (Desert)
	var east_pos = Vector3(chunk_size.x, 0, 0)
	create_terrain_chunk(east_pos, "desert")
	create_terrain_chunk(east_pos + Vector3(chunk_size.x, 0, 0), "desert")

	# North (Village)
	var north_pos = Vector3(0, 0, -chunk_size.y)
	create_terrain_chunk(north_pos, "village")
	spawn_village_buildings(north_pos, 15)

	# South (Grass)
	var south_pos = Vector3(0, 0, chunk_size.y)
	create_terrain_chunk(south_pos, "grass")
	create_terrain_chunk(south_pos + Vector3(0, 0, chunk_size.y), "grass")

	# Add some filler chunks if needed
	create_terrain_chunk(Vector3(-chunk_size.x, 0, -chunk_size.y), "mountains") # NW
	create_terrain_chunk(Vector3( chunk_size.x, 0, -chunk_size.y), "desert")    # NE
	create_terrain_chunk(Vector3(-chunk_size.x, 0,  chunk_size.y), "grass")     # SW
	create_terrain_chunk(Vector3( chunk_size.x, 0,  chunk_size.y), "grass")     # SE


func create_terrain_chunk(position: Vector3, biome_key: String):
	if not LevelConfig.BIOME_DATA.has(biome_key):
		printerr("Invalid biome key: ", biome_key)
		return

	var biome_config = LevelConfig.BIOME_DATA[biome_key]
	var chunk_size = LevelConfig.TERRAIN_CHUNK_SIZE
	var chunk_height = LevelConfig.TERRAIN_CHUNK_HEIGHT

	# 1. Create the StaticBody
	var terrain_chunk = StaticBody3D.new()
	terrain_chunk.name = "TerrainChunk_%s_%d_%d" % [biome_key, position.x, position.z]
	terrain_chunk.position = position + Vector3(0, biome_config["base_height"], 0) # Apply base height offset
	add_child(terrain_chunk)

	# 2. Create the MeshInstance
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.name = "Visuals"
	terrain_chunk.add_child(mesh_inst)

	# --- Mesh Generation ---
	var terrain_mesh: Mesh

	if biome_key == "mountains":
		# Use ArrayMesh for mountains to add noise-based height
		terrain_mesh = generate_mountain_mesh(chunk_size, biome_config, position)
	else:
		# Use a simple BoxMesh for other biomes (gives thickness)
		var box_mesh = BoxMesh.new()
		# Size X/Z from config, Y is the chunk_height
		box_mesh.size = Vector3(chunk_size.x, chunk_height, chunk_size.y)
		terrain_mesh = box_mesh
		# Offset mesh instance slightly down so top surface is at base_height
		mesh_inst.position.y = -chunk_height / 2.0

	mesh_inst.mesh = terrain_mesh

	# 3. Create and Apply Material
	var material = StandardMaterial3D.new()
	material.albedo_color = biome_config["color"]
	# You could add textures here later:
	# material.albedo_texture = load("res://Textures/" + biome_key + "_texture.png")
	mesh_inst.material_override = material # Use override for simplicity here

	# 4. Create Collision Shape
	var collision_shape = CollisionShape3D.new()
	collision_shape.name = "Collision"
	terrain_chunk.add_child(collision_shape)

	# --- Collision Shape Generation ---
	var shape_resource: Shape3D

	if biome_key == "mountains" and terrain_mesh is ArrayMesh:
		 # For complex ArrayMeshes, generate a collision shape from it
		 # This can be slow for very complex meshes!
		shape_resource = terrain_mesh.create_trimesh_shape()
		# No need to offset collision shape if mesh vertices are already at correct height
	else:
		# Use a BoxShape matching the BoxMesh visual
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(chunk_size.x, chunk_height, chunk_size.y)
		shape_resource = box_shape
		# Offset collision shape same as mesh instance
		collision_shape.position.y = -chunk_height / 2.0

	collision_shape.shape = shape_resource


# Function to generate a mountain mesh with noise
func generate_mountain_mesh(size: Vector2, config: Dictionary, chunk_offset: Vector3) -> ArrayMesh:
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Define resolution (how many vertices across the chunk)
	var resolution_x = 20
	var resolution_z = 20

	var step_x = size.x / float(resolution_x - 1)
	var step_z = size.y / float(resolution_z - 1)

	noise.frequency = config.get("mountain_frequency", 0.05)
	var height_scale = config.get("mountain_height_scale", 15.0)

	# Generate vertices
	for z_idx in range(resolution_z):
		for x_idx in range(resolution_x):
			var local_x = float(x_idx) * step_x - size.x / 2.0 # Center the mesh
			var local_z = float(z_idx) * step_z - size.y / 2.0 # Center the mesh
			
			# Get noise value based on GLOBAL position for seamless noise
			var world_x = local_x + chunk_offset.x
			var world_z = local_z + chunk_offset.z
			var height = noise.get_noise_2d(world_x, world_z) * height_scale

			var vertex = Vector3(local_x, height, local_z)
			
			# Add UVs (simple planar projection)
			var uv = Vector2(float(x_idx) / (resolution_x - 1), float(z_idx) / (resolution_z - 1))
			surface_tool.set_uv(uv)
			
			# Add vertex (normals will be generated later)
			surface_tool.add_vertex(vertex)

	# Generate indices (simple grid triangulation)
	for z_idx in range(resolution_z - 1):
		for x_idx in range(resolution_x - 1):
			var current = z_idx * resolution_x + x_idx
			var right = current + 1
			var below = current + resolution_x
			var below_right = below + 1

			# Triangle 1
			surface_tool.add_index(current)
			surface_tool.add_index(below)
			surface_tool.add_index(right)

			# Triangle 2
			surface_tool.add_index(right)
			surface_tool.add_index(below)
			surface_tool.add_index(below_right)

	# Generate normals for lighting
	surface_tool.generate_normals()

	# Commit the surface data to the ArrayMesh
	mesh = surface_tool.commit()
	return mesh


func spawn_house(position: Vector3):
	if house_scene:
		var house_instance = house_scene.instantiate()
		# Position the house slightly above the base terrain height
		house_instance.position = position + Vector3(0, LevelConfig.TERRAIN_CHUNK_HEIGHT / 2.0, 0)
		add_child(house_instance)
	else:
		printerr("House scene not preloaded!")


func spawn_village_buildings(chunk_position: Vector3, count: int):
	if not house_scene:
		printerr("House scene not preloaded, cannot spawn village buildings!")
		return
		
	var biome_config = LevelConfig.BIOME_DATA["village"]
	var chunk_size = LevelConfig.TERRAIN_CHUNK_SIZE
	var base_y = biome_config["base_height"] + LevelConfig.TERRAIN_CHUNK_HEIGHT / 2.0 # Top surface Y

	print("Spawning ", count, " buildings in village chunk at ", chunk_position)
	for i in range(count):
		var building = house_scene.instantiate()
		# Random position within the chunk boundaries
		var random_x = randf_range(-chunk_size.x / 2.5, chunk_size.x / 2.5) # Leave some margin
		var random_z = randf_range(-chunk_size.y / 2.5, chunk_size.y / 2.5)
		
		building.position = chunk_position + Vector3(random_x, base_y, random_z)
		building.rotation.y = randf() * TAU # TAU is 2*PI
		add_child(building)
