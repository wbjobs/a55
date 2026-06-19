extends Area3D
## 触觉感知组件 - 检测身体碰撞和接触

@export var touch_radius: float = 1.5
@export var show_visualization: bool = true
@export var visualization_color: Color = Color(1.0, 0.3, 0.3, 0.3)

var memory: PerceptionMemory = null
var _visualizer: MeshInstance3D = null
var _touching_bodies: Array = []

signal body_touched(body: Node3D, position: Vector3)
signal body_left(body: Node3D)

func _ready() -> void:
	if memory == null:
		memory = PerceptionMemory.new(5, 2.0)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if show_visualization:
		_create_visualizer()

func _process(delta: float) -> void:
	if _visualizer and show_visualization:
		_update_visualizer()

func _on_body_entered(body: Node3D) -> void:
	if not _touching_bodies.has(body):
		_touching_bodies.append(body)
		
		var contact_pos: Vector3 = (global_position + body.global_position) * 0.5
		
		var stimulus := Stimulus.new()
		stimulus.type = SenseType.Type.TOUCH
		stimulus.source = body
		stimulus.position = contact_pos
		stimulus.strength = 1.0
		stimulus.duration = 1.0
		stimulus.tag = "touch"
		memory.add_stimulus(stimulus)
		
		body_touched.emit(body, contact_pos)

func _on_body_exited(body: Node3D) -> void:
	if _touching_bodies.has(body):
		_touching_bodies.erase(body)
		body_left.emit(body)

func is_touching_anything() -> bool:
	return _touching_bodies.size() > 0

func get_touching_bodies() -> Array:
	return _touching_bodies.duplicate()

func is_touching_player() -> bool:
	var player: Node3D = GameManager.get_player()
	if player == null:
		return false
	return _touching_bodies.has(player)

func get_latest_touch() -> Stimulus:
	return memory.get_latest_stimulus(SenseType.Type.TOUCH)

func _create_visualizer() -> void:
	if _visualizer:
		_visualizer.queue_free()
	_visualizer = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = touch_radius
	sphere.height = touch_radius * 2
	sphere.radial_segments = 16
	sphere.rings = 8
	_visualizer.mesh = sphere
	_visualizer.cast_shadow = 0
	add_child(_visualizer)

func _update_visualizer() -> void:
	if not _visualizer:
		return
	var mat: StandardMaterial3D = _visualizer.material_override as StandardMaterial3D
	if mat == null:
		mat = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENT
		mat.albedo_color = visualization_color
		mat.roughness = 1.0
		mat.cull_mode = BaseMaterial3D.CULL_BACK
		_visualizer.material_override = mat
	else:
		var pulse: float = 1.0
		if is_touching_anything():
			pulse = 0.7 + 0.3 * sin(Time.get_ticks_msec() * 0.01)
		mat.albedo_color = Color(
			visualization_color.r,
			visualization_color.g,
			visualization_color.b,
			visualization_color.a * pulse
		)
