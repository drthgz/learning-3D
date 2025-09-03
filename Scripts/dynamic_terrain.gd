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

	# Reset root node transform to identity
	transform = Transform3D.IDENTITY

	# Generate a single smooth mesh for the whole terrain with vertex colors
	var mesh = ArrayMesh.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var size = GRID_SIZE
	var step = TILE_SIZE
	for x in range(-size, size):
		for z in range(-size, size):
			var zone00 = get_zone(x * step, z * step)
			var zone10 = get_zone((x+1) * step, z * step)
			var zone01 = get_zone(x * step, (z+1) * step)
			var zone11 = get_zone((x+1) * step, (z+1) * step)
			var y00 = get_height_for_zone(zone00, x, z)
			var y10 = get_height_for_zone(zone10, x+1, z)
			var y01 = get_height_for_zone(zone01, x, z+1)
			var y11 = get_height_for_zone(zone11, x+1, z+1)
			var v00 = Vector3(x * step, y00, z * step)
			var v10 = Vector3((x+1) * step, y10, z * step)
			var v01 = Vector3(x * step, y01, (z+1) * step)
			var v11 = Vector3((x+1) * step, y11, (z+1) * step)
			# Assign colors based on zone
			var c00 = get_color_for_zone(zone00)
			var c10 = get_color_for_zone(zone10)
			var c01 = get_color_for_zone(zone01)
			var c11 = get_color_for_zone(zone11)
			# First triangle
			st.set_color(c00)
			st.add_vertex(v00)
			st.set_color(c10)
			st.add_vertex(v10)
			st.set_color(c11)
			st.add_vertex(v11)
			# Second triangle
			st.set_color(c00)
			st.add_vertex(v00)
			st.set_color(c11)
			st.add_vertex(v11)
			st.set_color(c01)
			st.add_vertex(v01)
	mesh = st.commit()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	# Create a material that uses vertex colors
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mesh_instance.material_override = mat
	add_child(mesh_instance)
	# Add collision for the mesh
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = ConcavePolygonShape3D.new()
	shape.data = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	collision_shape.shape = shape
	static_body.add_child(collision_shape)
	add_child(static_body)
func get_color_for_zone(zone):
	match zone:
		"ice":
			return Color(0.7, 0.9, 1.0) # light blue
		"desert":
			return Color(0.95, 0.85, 0.5) # sandy yellow
		"forest":
			return Color(0.2, 0.7, 0.3) # green
		"grass":
			return Color(0.5, 1.0, 0.5) # bright green
		"city":
			return Color(0.7, 0.7, 0.7) # gray
		_:
			return Color(1, 1, 1)

	# Add moonlight (directional light, dim and bluish)
	var moonlight = DirectionalLight3D.new()
	moonlight.light_color = Color(0.6, 0.7, 1.0)
	moonlight.light_energy = 0.3
	moonlight.rotation_degrees = Vector3(-60, 30, 0)
	add_child(moonlight)

func get_height_for_zone(zone, x, z):
	match zone:
		"ice":
			return sin(x * 0.3) * 6.0 + cos(z * 0.3) * 6.0 # mountains
		"desert":
			return sin(x * 0.5) * 1.5 + cos(z * 0.3) * 1.0 # dunes
		"forest":
			return sin(x * 0.2) * 0.7 + cos(z * 0.2) * 0.7 # gentle hills
		"grass":
			return 0 # flat
		"city":
			return 0 # flat
		_:
			return 0
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
