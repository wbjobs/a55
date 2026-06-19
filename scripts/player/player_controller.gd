extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_velocity: float = 5.0
@export var rotation_speed: float = 12.0
@export var gravity: float = 20.0

var _target_rotation_y: float = 0.0

func _ready() -> void:
	GameManager.register_player(self)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	_handle_movement(delta)
	_move_and_slide()

func _handle_movement(delta: float) -> void:
	var input_dir: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1.0
	if Input.is_action_pressed("move_back"):
		input_dir.y += 1.0
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1.0
	
	if input_dir.length() > 0.0:
		input_dir = input_dir.normalized()
		var move_dir: Vector3 = Vector3(input_dir.x, 0.0, input_dir.y)
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
		
		_target_rotation_y = atan2(move_dir.x, move_dir.z)
	else:
		velocity.x = lerp(velocity.x, 0.0, 10.0 * delta)
		velocity.z = lerp(velocity.z, 0.0, 10.0 * delta)
	
	var current_y: float = rotation.y
	var new_y: float = lerp_angle(current_y, _target_rotation_y, rotation_speed * delta)
	rotation.y = new_y
