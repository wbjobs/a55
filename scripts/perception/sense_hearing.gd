extends Node3D
## 听觉感知组件 - 监听周围的声音事件

@export var hearing_range: float = 25.0
@export var min_volume: float = 0.2
@export var scan_interval: float = 0.3
@export var show_visualization: bool = true
@export var visualization_color: Color = Color(1.0, 0.8, 0.2, 0.2)

var memory: PerceptionMemory = null
var _scan_timer: float = 0.0
var _visualizer: MeshInstance3D = null
var _pulse_time: float = 0.0

signal sound_heard(stimulus: Stimulus)
signal alert_level_changed(level: float)

func _ready() -> void:
	if memory == null:
		memory = PerceptionMemory.new(10, 8.0)
	if show_visualization:
		_create_visualizer()

func _process(delta: float) -> void:
	_scan_timer += delta
	_pulse_time += delta
	if _scan_timer >= scan_interval:
		_scan_timer = 0.0
		_scan_sounds()
	if _visualizer and show_visualization:
		_update_visualizer(delta)

func _scan_sounds() -> void:
	if not PerceptionSystem:
		return
	
	var sounds: Array = PerceptionSystem.get_sounds_in_range(global_position, hearing_range)
	for stim in sounds:
		if stim.get_current_strength() >= min_volume:
			memory.add_stimulus(stim)
			sound_heard.emit(stim)
			_pulse_time = 0.0

func get_loudest_sound() -> Stimulus:
	return memory.get_latest_stimulus(SenseType.Type.HEARING)

func has_heard_sound(tag: String = "") -> bool:
	if tag == "":
		return memory.has_stimulus(SenseType.Type.HEARING)
	return memory.has_stimulus_with_tag(tag)

func get_last_sound_position() -> Vector3:
	var stim: Stimulus = memory.get_latest_stimulus(SenseType.Type.HEARING)
	if stim:
		return stim.position
	return Vector3.ZERO

func get_alert_level() -> float:
	var level: float = 0.0
	var sounds: Array = memory.get_all_stimuli(SenseType.Type.HEARING)
	for stim in sounds:
		var dist: float = global_position.distance_to(stim.position)
		var volume_effect: float = stim.get_current_strength() * (1.0 - dist / hearing_range)
		level = max(level, volume_effect)
	return clampf(level, 0.0, 1.0)

func _create_visualizer() -> void:
	if _visualizer:
		_visualizer.queue_free()
	_visualizer = MeshInstance3D.new()
	_visualizer.mesh = _create_ring_mesh()
	_visualizer.cast_shadow = 0
	add_child(_visualizer)

func _create_ring_mesh() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var vertices: Array = []
	var indices: Array = []
	var uvs: Array = []
	
	var segments: int = 48
	var inner_radius: float = hearing_range * 0.95
	var outer_radius: float = hearing_range
	
	for i in range(segments):
		var angle: float = (float(i) / float(segments)) * TAU
		var cos_a: float = cos(angle)
		var sin_a: float = sin(angle)
		
		vertices.append(Vector3(sin_a * inner_radius, 0.05, cos_a * inner_radius))
		vertices.append(Vector3(sin_a * outer_radius, 0.05, cos_a * outer_radius))
		uvs.append(Vector2(0, 0))
		uvs.append(Vector2(1, 1))
	
	for i in range(segments):
		var i0: int = i * 2
		var i1: int = i * 2 + 1
		var i2: int = (i * 2 + 2) % (segments * 2)
		var i3: int = (i * 2 + 3) % (segments * 2)
		
		indices.append(i0)
		indices.append(i1)
		indices.append(i3)
		indices.append(i0)
		indices.append(i3)
		indices.append(i2)
	
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func _update_visualizer(delta: float) -> void:
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
	
	var alert: float = get_alert_level()
	var pulse: float = 0.5 + 0.5 * sin(_pulse_time * 4.0)
	var alpha: float = visualization_color.a * (0.6 + alert * 0.4 * pulse)
	mat.albedo_color = Color(visualization_color.r, visualization_color.g, visualization_color.b, alpha)
