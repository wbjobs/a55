class_name FlowFieldGrid
extends RefCounted

const CELL_BLOCKED: int = -1

var cell_size: float = 1.0
var grid_width: int = 0
var grid_height: int = 0
var origin: Vector2 = Vector2.ZERO
var _cost_field: Array = []

func _init(width: int, height: int, size: float = 1.0, orig: Vector2 = Vector2.ZERO) -> void:
	grid_width = width
	grid_height = height
	cell_size = size
	origin = orig
	_cost_field.resize(grid_width * grid_height)
	for i in range(_cost_field.size()):
		_cost_field[i] = 1

func get_index(grid_x: int, grid_y: int) -> int:
	return grid_y * grid_width + grid_x

func is_in_bounds(grid_x: int, grid_y: int) -> bool:
	return grid_x >= 0 and grid_x < grid_width and grid_y >= 0 and grid_y < grid_height

func world_to_grid(world_pos: Vector3) -> Vector2i:
	var x: int = int(floor((world_pos.x - origin.x) / cell_size))
	var y: int = int(floor((world_pos.z - origin.y) / cell_size))
	return Vector2i(x, y)

func grid_to_world(grid_x: int, grid_y: int) -> Vector3:
	var world_x: float = origin.x + (float(grid_x) + 0.5) * cell_size
	var world_z: float = origin.y + (float(grid_y) + 0.5) * cell_size
	return Vector3(world_x, 0.0, world_z)

func get_cost(grid_x: int, grid_y: int) -> int:
	if not is_in_bounds(grid_x, grid_y):
		return CELL_BLOCKED
	return _cost_field[get_index(grid_x, grid_y)]

func set_cost(grid_x: int, grid_y: int, cost: int) -> void:
	if is_in_bounds(grid_x, grid_y):
		_cost_field[get_index(grid_x, grid_y)] = cost

func is_blocked(grid_x: int, grid_y: int) -> bool:
	return get_cost(grid_x, grid_y) == CELL_BLOCKED

func set_blocked(grid_x: int, grid_y: int, blocked: bool = true) -> void:
	if is_in_bounds(grid_x, grid_y):
		_cost_field[get_index(grid_x, grid_y)] = CELL_BLOCKED if blocked else 1

func set_blocked_world(world_pos: Vector3, radius: float = 1.0) -> void:
	var grid_pos: Vector2i = world_to_grid(world_pos)
	var grid_radius: int = int(ceil(radius / cell_size))
	for dx in range(-grid_radius, grid_radius + 1):
		for dy in range(-grid_radius, grid_radius + 1):
			var gx: int = grid_pos.x + dx
			var gy: int = grid_pos.y + dy
			if is_in_bounds(gx, gy):
				var dist: float = Vector2(dx, dy).length() * cell_size
				if dist <= radius:
					set_blocked(gx, gy, true)

func clear() -> void:
	for i in range(_cost_field.size()):
		_cost_field[i] = 1
