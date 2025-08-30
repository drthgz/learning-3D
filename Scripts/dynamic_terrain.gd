extends Node3D

# Size of the terrain grid
const GRID_SIZE = 100
const TILE_SIZE = 1.0
const CITY_RADIUS = 5.0

# Preload mesh and materials for each zone (replace with your assets)
var ice_material = preload("res://Assets/ice_material.tres")
var desert_material = preload("res://Assets/desert_material.tres")
var forest_material = preload("res://Assets/forest_material.tres")
var grass_material = preload("res://Assets/grass_material.tres")
var city_material = preload("res://Assets/city_material.tres")
var tile_mesh = preload("res://Assets/tile_mesh.tres")

func _ready():
	# Reset root node transform to identity
	transform = Transform3D.IDENTITY

	# Add a flat floor at the origin for player spawn
	var floor_mesh = MeshInstance3D.new()
	floor_mesh.mesh = PlaneMesh.new()
	floor_mesh.scale = Vector3(10, 1, 10)
	floor_mesh.position = Vector3(0, 0, 0)
	floor_mesh.material_override = city_material
	add_child(floor_mesh)
	var floor_body = StaticBody3D.new()
	floor_body.position = Vector3(0, 0, 0)
	var floor_collision = CollisionShape3D.new()
	var floor_shape = BoxShape3D.new()
	floor_shape.size = Vector3(10, 0.1, 10)
	floor_collision.shape = floor_shape
	floor_body.add_child(floor_collision)
	add_child(floor_body)

	# Generate all terrain tiles with different topologies
	for x in range(-GRID_SIZE, GRID_SIZE):
		for z in range(-GRID_SIZE, GRID_SIZE):
			var pos = Vector3(x * TILE_SIZE, 0, z * TILE_SIZE)
			var zone = get_zone(pos.x, pos.z)
			match zone:
				"ice":
					pos.y = sin(x * 0.3) * 6.0 + cos(z * 0.3) * 6.0 # mountains
				"desert":
					pos.y = sin(x * 0.5) * 1.5 + cos(z * 0.3) * 1.0 # dunes
				"forest":
					pos.y = sin(x * 0.2) * 0.7 + cos(z * 0.2) * 0.7 # gentle hills
				"grass":
					pos.y = 0 # flat
				"city":
					pos.y = 0 # flat
				_:
					pos.y = 0
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = tile_mesh
			mesh_instance.position = pos
			mesh_instance.material_override = get_material_for_zone(zone)
			add_child(mesh_instance)
			# Add collision to each tile
			var static_body = StaticBody3D.new()
			static_body.position = pos
			var collision_shape = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(TILE_SIZE, 0.1, TILE_SIZE)
			collision_shape.shape = box_shape
			static_body.add_child(collision_shape)
			add_child(static_body)
## Removed generate_desert_mesh, all terrain handled in _ready()

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
