extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var mouse_sensititvity = 0.01
@export var camera_distance = 3.0
@export var camera_height = 1.5
@export var camera_shoulder_offset=0.7

var camera_pivot: Node3D
var spring_arm: SpringArm3D
var camera: Camera3D


var gravity = 9.8
var camera_rotation = Vector2.ZERO

func _ready():
	# Dynamically create camera nodes
	camera_pivot = Node3D.new()
	add_child(camera_pivot)
	spring_arm = SpringArm3D.new()
	camera_pivot.add_child(spring_arm)
	camera = Camera3D.new()
	spring_arm.add_child(camera)
	camera.current = true

	# Configure spring arm
	spring_arm.spring_length = camera_distance
	spring_arm.position.y = camera_height
	spring_arm.position.x = camera_shoulder_offset

	# Initial camera position
	update_camera_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_rotation.x -= event.relative.x * mouse_sensititvity * 0.01
		camera_rotation.y -= event.relative.y * mouse_sensititvity * 0.01
		camera_rotation.y = clamp(camera_rotation.y, -0.8, 0.8) # limit vertical rotation
		update_camera_position()
		# Rotate player horizontally with mouse
		rotation.y = camera_rotation.x

	# Mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = max(1.0, camera_distance - 0.5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = min(5.0, camera_distance + 0.5)
		spring_arm.spring_length = camera_distance

func update_camera_position():
	# Horizontal rotation (around player)
	camera_pivot.rotation.y = camera_rotation.x
	# Vertical rotation (up/down)
	spring_arm.rotation.x = camera_rotation.y


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Move relative to player's facing direction (which matches camera)
	var move_basis = Basis(Vector3.UP, rotation.y)
	var direction := (move_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _process(delta: float) -> void:
	# Camera follows player smoothly
	if camera_pivot:
		camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 10)
