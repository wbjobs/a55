class_name FlowField
extends RefCounted

var grid: FlowFieldGrid = null
var target_grid_pos: Vector2i = Vector2i(-1, -1)
var _integration_field: Array = []
var _flow_field: Array = []
var _is_valid: bool = false

func _init(flow_grid: FlowFieldGrid) -> void:
	grid = flow_grid

func calculate(target_world_pos: Vector3) -> bool:
	target_grid_pos = grid.world_to_grid(target_world_pos)
	
	if not grid.is_in_bounds(target_grid_pos.x, target_grid_pos.y):
		_is_valid = false
		return false
	
	if grid.is_blocked(target_grid_pos.x, target_grid_pos.y):
		_is_valid = false
		return false
	
	_integration_field.clear()
	_flow_field.clear()
	_integration_field.resize(grid.grid_width * grid.grid_height)
	_flow_field.resize(grid.grid_width * grid.grid_height)
	
	for i in range(_integration_field.size()):
		_integration_field[i] = INF
		_flow_field[i] = Vector2.ZERO
	
	var target_index: int = grid.get_index(target_grid_pos.x, target_grid_pos.y)
	_integration_field[target_index] = 0
	_flow_field[target_index] = Vector2.ZERO
	
	var open_list: Array = [target_grid_pos]
	var closed_set: Dictionary = {}
	
	var iterations: int = 0
	var max_iterations: int = grid.grid_width * grid.grid_height * 2
	
	while open_list.size() > 0 and iterations < max_iterations:
		iterations += 1
		
		var current: Vector2i = open_list.pop_front()
		var current_idx: int = grid.get_index(current.x, current.y)
		var current_cost: float = _integration_field[current_idx]
		
		var neighbors: Array = _get_neighbors(current.x, current.y)
		for neighbor in neighbors:
			var nx: int = neighbor.x
			var ny: int = neighbor.y
			var n_idx: int = grid.get_index(nx, ny)
			
			if grid.is_blocked(nx, ny):
				continue
			
			var cell_cost: int = grid.get_cost(nx, ny)
			if cell_cost == grid.CELL_BLOCKED:
				continue
			
			var new_cost: float = current_cost + float(cell_cost)
			if new_cost < _integration_field[n_idx]:
				_integration_field[n_idx] = new_cost
				var n_key: String = str(nx) + "," + str(ny)
				if not closed_set.has(n_key):
					open_list.append(Vector2i(nx, ny))
					closed_set[n_key] = true
	
	_calculate_flow_field()
	_is_valid = true
	return true

func _get_neighbors(x: int, y: int) -> Array:
	var neighbors: Array = []
	if grid.is_in_bounds(x - 1, y):
		neighbors.append(Vector2i(x - 1, y))
	if grid.is_in_bounds(x + 1, y):
		neighbors.append(Vector2i(x + 1, y))
	if grid.is_in_bounds(x, y - 1):
		neighbors.append(Vector2i(x, y - 1))
	if grid.is_in_bounds(x, y + 1):
		neighbors.append(Vector2i(x, y + 1))
	return neighbors

func _calculate_flow_field() -> void:
	for gx in range(grid.grid_width):
		for gy in range(grid.grid_height):
			var idx: int = grid.get_index(gx, gy)
			if grid.is_blocked(gx, gy):
				_flow_field[idx] = Vector2.ZERO
				continue
			
			var current_cost: float = _integration_field[idx]
			if current_cost == INF:
				_flow_field[idx] = Vector2.ZERO
				continue
			
			if current_cost == 0:
				_flow_field[idx] = Vector2.ZERO
				continue
			
			var min_cost: float = INF
			var flow_dir: Vector2 = Vector2.ZERO
			
			var neighbors: Array = _get_neighbors(gx, gy)
			for neighbor in neighbors:
				var nx: int = neighbor.x
				var ny: int = neighbor.y
				var n_idx: int = grid.get_index(nx, ny)
				var n_cost: float = _integration_field[n_idx]
				
				if n_cost < min_cost:
					min_cost = n_cost
					flow_dir = Vector2(float(nx - gx), float(ny - gy)).normalized()
			
			_flow_field[idx] = flow_dir

func get_flow_direction_world(world_pos: Vector3) -> Vector3:
	if not _is_valid or grid == null:
		return Vector3.ZERO
	
	var grid_pos: Vector2i = grid.world_to_grid(world_pos)
	if not grid.is_in_bounds(grid_pos.x, grid_pos.y):
		return Vector3.ZERO
	
	var idx: int = grid.get_index(grid_pos.x, grid_pos.y)
	var flow: Vector2 = _flow_field[idx]
	return Vector3(flow.x, 0.0, flow.y).normalized()

func get_distance_to_target_world(world_pos: Vector3) -> float:
	if not _is_valid or grid == null:
		return INF
	
	var grid_pos: Vector2i = grid.world_to_grid(world_pos)
	if not grid.is_in_bounds(grid_pos.x, grid_pos.y):
		return INF
	
	var idx: int = grid.get_index(grid_pos.x, grid_pos.y)
	return _integration_field[idx] * grid.cell_size

func is_valid() -> bool:
	return _is_valid

func invalidate() -> void:
	_is_valid = false

func get_integration_field() -> Array:
	return _integration_field

func get_flow_field_raw() -> Array:
	return _flow_field
