extends Node
## 流场寻路管理器 - 全局单例，管理所有流场的创建、缓存和复用
## 所有NPC共享流场数据，避免重复计算

class_name FlowFieldManager

var grid: FlowFieldGrid = null
var _flow_field_cache: Dictionary = {}
var _last_calculation_time: Dictionary = {}
var _cache_lifetime: float = 2.0
var _max_cached_fields: int = 8
var _debug_visualizer: Node = null
var _show_debug: bool = false

signal flow_field_calculated(target_pos: Vector3)

func _ready() -> void:
	_setup_default_grid()

func _setup_default_grid() -> void:
	var world_size: float = 100.0
	var cell_size: float = 1.0
	var num_cells: int = int(world_size / cell_size)
	var origin: Vector2 = Vector2(-world_size * 0.5, -world_size * 0.5)
	grid = FlowFieldGrid.new(num_cells, num_cells, cell_size, origin)

func register_obstacle(world_pos: Vector3, radius: float = 1.0) -> void:
	if grid:
		grid.set_blocked_world(world_pos, radius)
		_clear_cache()

func register_static_obstacles(obstacles: Array) -> void:
	if not grid:
		return
	for obs in obstacles:
		if obs is Node3D:
			var pos: Vector3 = (obs as Node3D).global_position
			var rad: float = 1.5
			grid.set_blocked_world(pos, rad)
	_clear_cache()

func get_flow_field(target_world_pos: Vector3, force_recalculate: bool = false) -> FlowField:
	if not grid:
		return null
	
	var grid_pos: Vector2i = grid.world_to_grid(target_world_pos)
	var key: String = str(grid_pos.x) + "," + str(grid_pos.y)
	
	var current_time: float = Time.get_ticks_msec() / 1000.0
	var cached: FlowField = _flow_field_cache.get(key, null)
	
	if not force_recalculate and cached and cached.is_valid():
		var last_calc: float = _last_calculation_time.get(key, 0.0)
		if current_time - last_calc < _cache_lifetime:
			return cached
	
	var new_field := FlowField.new(grid)
	if new_field.calculate(target_world_pos):
		_flow_field_cache[key] = new_field
		_last_calculation_time[key] = current_time
		_trim_cache()
		flow_field_calculated.emit(target_world_pos)
		return new_field
	
	return null

func get_direction(from_world_pos: Vector3, to_world_pos: Vector3) -> Vector3:
	var flow_field: FlowField = get_flow_field(to_world_pos)
	if flow_field:
		return flow_field.get_flow_direction_world(from_world_pos)
	return Vector3.ZERO

func has_path(from_world_pos: Vector3, to_world_pos: Vector3) -> bool:
	var flow_field: FlowField = get_flow_field(to_world_pos)
	if not flow_field:
		return false
	var distance: float = flow_field.get_distance_to_target_world(from_world_pos)
	return distance < INF and distance >= 0

func _trim_cache() -> void:
	if _flow_field_cache.size() <= _max_cached_fields:
		return
	
	var oldest_key: String = ""
	var oldest_time: float = INF
	
	for key in _last_calculation_time.keys():
		var t: float = _last_calculation_time[key]
		if t < oldest_time:
			oldest_time = t
			oldest_key = key
	
	if oldest_key != "":
		_flow_field_cache.erase(oldest_key)
		_last_calculation_time.erase(oldest_key)

func _clear_cache() -> void:
	_flow_field_cache.clear()
	_last_calculation_time.clear()

func set_cache_lifetime(lifetime: float) -> void:
	_cache_lifetime = lifetime

func set_max_cached_fields(max_fields: int) -> void:
	_max_cached_fields = max_fields

func get_cache_size() -> int:
	return _flow_field_cache.size()

func toggle_debug(show: bool) -> void:
	_show_debug = show
	if _debug_visualizer:
		_debug_visualizer.queue_free()
		_debug_visualizer = null
	if show:
		_debug_visualizer = _create_debug_visualizer()
		if get_tree():
			get_tree().root.add_child(_debug_visualizer)

func _create_debug_visualizer() -> Node:
	var visualizer := Node.new()
	visualizer.set_script(load("res://scripts/pathfinding/flow_field_debug.gd"))
	visualizer.set("manager", self)
	return visualizer

func is_showing_debug() -> bool:
	return _show_debug
