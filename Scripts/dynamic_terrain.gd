extends Node3D

# Size of the terrain grid
const GRID_SIZE = 50
const TILE_SIZE = 1.0
const CITY_RADIUS = 10.0

# Preload mesh and materials for each zone (replace with your assets)
var ice_material = preload("res://Assets/ice_material.tres")
var desert_material = preload("res://Assets/desert_material.tres")
var forest_material = preload("res://Assets/forest_material.tres")
var grass_material = preload("res://Assets/grass_material.tres")
var city_material = preload("res://Assets/city_material.tres")
var tile_mesh = preload("res://Assets/tile_mesh.tres")

func _ready():
	for x in range(-GRID_SIZE, GRID_SIZE):
		for z in range(-GRID_SIZE, GRID_SIZE):
			var pos = Vector3(x * TILE_SIZE, 0, z * TILE_SIZE)
			var zone = get_zone(pos.x, pos.z)
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = tile_mesh
			mesh_instance.position = pos
			mesh_instance.material_override = get_material_for_zone(zone)

			# Add collision to each tile
			var static_body = StaticBody3D.new()
			static_body.position = pos
			var collision_shape = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(TILE_SIZE, 0.1, TILE_SIZE)
			collision_shape.shape = box_shape
			static_body.add_child(collision_shape)
			add_child(static_body)
			add_child(mesh_instance)

	# Add camera
	## Add camera (higher and angled for top-down view)
	#var camera = Camera3D.new()
	#camera.position = Vector3(0, GRID_SIZE * 1, GRID_SIZE * 1)
	#camera.look_at(Vector3(0, 0, 0), Vector3.UP)
	#camera.far = 1000
	#add_child(camera)

	# Add directional light (angled for better illumination)
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-90, 45, 0)
	add_child(light)

func get_zone(x, z):
	if Vector2(x, z).length() < CITY_RADIUS:
		return "city"
	elif x >= 0 and z >= 0:
		return "ice"
	elif x < 0 and z >= 0:
		return "desert"
	elif x < 0 and z < 0:
		return "forest"
	elif x >= 0 and z < 0:
		return "grass"
	return "unknown"

func get_material_for_zone(zone):
	match zone:
		"ice":
			return ice_material
		"desert":
			return desert_material
		"forest":
			return forest_material
		"grass":
			return grass_material
		"city":
			return city_material
		_:
			return null
