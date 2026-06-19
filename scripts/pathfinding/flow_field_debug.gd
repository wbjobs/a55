@tool
extends Node
## 流场调试可视化组件

var manager: FlowFieldManager = null
var _mesh_instances: Array = []
var _last_target: Vector3 = Vector3.INF

func _process(delta: float) -> void:
	if not manager or not manager.is_showing_debug():
		_clear_visualization()
		return
	
	var cache: Dictionary = manager._flow_field_cache
	if cache.size() == 0:
		_clear_visualization()
		return
	
	var keys: Array = cache.keys()
	if keys.size() == 0:
		return
	
	var target_key: String = keys[0]
	var flow_field: FlowField = cache[target_key]
	
	if not flow_field or not flow_field.is_valid():
		return
	
	_redraw_flow_field(flow_field)

func _redraw_flow_field(flow_field: FlowField) -> void:
	if not manager or not manager.grid:
		return
	
	if _mesh_instances.size() > 0:
		_clear_visualization()
	
	var grid: FlowFieldGrid = manager.grid
	var step: int = 1
	
	for gx in range(0, grid.grid_width, step):
		for gy in range(0, grid.grid_height, step):
			if grid.is_blocked(gx, gy):
				continue
			
			var idx: int = grid.get_index(gx, gy)
			var integration: float = flow_field.get_integration_field()[idx]
			if integration == INF:
				continue
			
			var world_pos: Vector3 = grid.grid_to_world(gx, gy)
			
			var flow_vec: Vector3 = flow_field.get_flow_direction_world(world_pos)
			
			var arrow_mesh := MeshInstance3D.new()
			arrow_mesh.position = world_pos
			arrow_mesh.position.y = 0.1
			
			if integration == 0:
				var sphere := SphereMesh.new()
				sphere.radius = 0.2
				sphere.height = 0.4
				arrow_mesh.mesh = sphere
				var mat := StandardMaterial3D.new()
				mat.albedo_color = Color(1, 0, 0)
				mat.emission = Color(1, 0, 0)
				mat.emission_energy = 0.5
				arrow_mesh.material_override = mat
			else:
				var cylinder := CylinderMesh.new()
				cylinder.top_radius = 0.05
				cylinder.bottom_radius = 0.1
				cylinder.height = 0.6
				cylinder.radial_segments = 6
				arrow_mesh.mesh = cylinder
				
				if flow_vec.length() > 0.01:
					var look_at_pos: Vector3 = world_pos + flow_vec
					look_at_pos.y = 0.1
					arrow_mesh.look_at(look_at_pos, Vector3.UP)
					arrow_mesh.rotate_object_local(Vector3.RIGHT, -PI * 0.5)
				
				var max_integration: float = 50.0
				var t: float = clampf(integration / max_integration, 0.0, 1.0)
				var mat := StandardMaterial3D.new()
				mat.albedo_color = Color(1.0 - t, t, 0.2)
				arrow_mesh.material_override = mat
			
			add_child(arrow_mesh)
			_mesh_instances.append(arrow_mesh)

func _clear_visualization() -> void:
	for mesh in _mesh_instances:
		if mesh:
			mesh.queue_free()
	_mesh_instances.clear()
