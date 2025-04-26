extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var mouse_sensititvity = 0.01
@export var camera_distance = 3.0
@export var camera_height = 1.5
@export var camera_shoulder_offset=0.7

# camera nodes
@onready var camera_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var camera = $CameraPivot/SpringArm3D/Camera3D


var gravity = 9.8
var camera_rotation = Vector2.ZERO

func _ready():
	#configure spring arm
	spring_arm.spring_length = camera_distance
	spring_arm.position.y = camera_height
	spring_arm.position.x = camera_shoulder_offset
	
	#Initial camera position
	update_camera_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event):
	#mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_rotation -= event.relative * mouse_sensititvity *0.01
		camera_rotation.y = clamp(camera_rotation.y, -0.8, 0.8) #limit vertical rotation
		update_camera_position()
	
	# mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = max(1.0, camera_distance - 0.5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = min(5.0, camera_distance + 0.5)
		spring_arm.spring_length = camera_distance

func update_camera_position():
	#Horizontal rotation (around player)
	camera_pivot.rotation.y=camera_rotation.x
	#vertical rotation(up/down)
	camera_pivot.rotation.x=camera_rotation.y


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		#velocity += Vector3(0,- gravity * delta,0)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _process(delta: float) -> void:
	#Add this for camera smoothing
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 10)
