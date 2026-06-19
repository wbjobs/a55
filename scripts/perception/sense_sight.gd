extends Node3D
## 视觉感知组件 - 检测视野内的目标

@export var vision_range: float = 15.0
@export var vision_angle: float = 90.0
@export var scan_interval: float = 0.2
@export var show_visualization: bool = true
@export var visualization_color: Color = Color(0.3, 0.7, 1.0, 0.3)

var memory: PerceptionMemory = null
var _scan_timer: float = 0.0
var _visualizer: MeshInstance3D = null

signal target_sighted(stimulus: Stimulus)
signal target_lost(target: Node3D)

func _ready() -> void:
	if memory == null:
		memory = PerceptionMemory.new()
	if show_visualization:
		_create_visualizer()

func _process(delta: float) -> void:
	_scan_timer += delta
	if _scan_timer >= scan_interval:
		_scan_timer = 0.0
		_scan()
	if _visualizer and show_visualization:
		_update_visualizer()

func _scan() -> void:
	var player: Node3D = GameManager.get_player()
	if player == null:
		return
	if can_see(player):
		var stimulus := Stimulus.new()
		stimulus.type = SenseType.Type.SIGHT
		stimulus.source = player
		stimulus.position = player.global_position
		stimulus.strength = 1.0
		stimulus.duration = 2.0
		stimulus.tag = "player"
		memory.add_stimulus(stimulus)
		target_sighted.emit(stimulus)

func can_see(target: Node3D) -> bool:
	if target == null:
		return false
	
	var to_target: Vector3 = target.global_position - global_position
	to_target.y = 0.0
	
	var distance: float = to_target.length()
	if distance > vision_range:
		return false
	
	var forward: Vector3 = -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	if to_target.length() < 0.01:
		return true
	
	var angle: float = rad_to_deg(forward.angle_to(to_target.normalized()))
	if angle > vision_angle * 0.5:
		return false
	
	return true

func is_target_visible() -> bool:
	return memory.has_stimulus_with_tag("player")

func get_visible_target() -> Node3D:
	var stim: Stimulus = memory.get_latest_by_tag("player")
	if stim and stim.source:
		return stim.source
	return null

func get_last_known_position() -> Vector3:
	var stim: Stimulus = memory.get_latest_by_tag("player")
	if stim:
		return stim.position
	return Vector3.ZERO

func _create_visualizer() -> void:
	if _visualizer:
		_visualizer.queue_free()
	_visualizer = MeshInstance3D.new()
	_visualizer.mesh = _create_fan_mesh()
	_visualizer.cast_shadow = 0
	add_child(_visualizer)

func _create_fan_mesh() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var vertices: Array = []
	var indices: Array = []
	var uvs: Array = []
	
	var segments: int = 32
	var half_angle: float = deg_to_rad(vision_angle * 0.5)
	var radius: float = vision_range
	
	vertices.append(Vector3.ZERO)
	uvs.append(Vector2(0.5, 0.5))
	
	for i in range(segments + 1):
		var t: float = float(i) / float(segments)
		var angle: float = -half_angle + t * half_angle * 2.0
		var x: float = sin(angle) * radius
		var z: float = cos(angle) * radius
		vertices.append(Vector3(x, 0.0, z))
		uvs.append(Vector2(0.5 + x / radius * 0.5, 0.5 + z / radius * 0.5))
	
	for i in range(segments):
		indices.append(0)
		indices.append(i + 1)
		indices.append(i + 2)
	
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

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
		mat.albedo_color = visualization_color
