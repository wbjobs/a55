class_name ActionPatrol
extends BTAction

func execute(context: BTContext) -> int:
	var owner: Node = context.owner
	if owner == null or not (owner is Node3D):
		return BTNodeState.State.FAILURE
	
	var state: Dictionary = context.get_node_state(data.id)
	var waypoint_index: int = int(state.get("waypoint_index", 0))
	var wait_timer: float = float(state.get("wait_timer", 0.0))
	var is_waiting: bool = bool(state.get("is_waiting", false))
	
	var wait_time: float = float(get_property("wait_time", 2.0))
	var speed: float = float(get_property("speed", 2.0))
	var tolerance: float = float(get_property("tolerance", 0.5))
	var patrol_radius: float = float(get_property("patrol_radius", 5.0))
	var waypoint_count: int = int(get_property("waypoint_count", 4))
	var center_key: String = String(get_property("center_blackboard_key", "home_position"))
	
	var owner_3d: Node3D = owner as Node3D
	
	var center: Variant = context.get_blackboard(center_key)
	var center_pos: Vector3
	if center == null:
		center_pos = owner_3d.global_position
		context.set_blackboard(center_key, center_pos)
	elif typeof(center) == TYPE_VECTOR3:
		center_pos = center as Vector3
	elif center is Node3D:
		center_pos = (center as Node3D).global_position
	else:
		center_pos = owner_3d.global_position
	
	var waypoints: Array = state.get("waypoints", [])
	if waypoints.is_empty():
		waypoints = _generate_waypoints(center_pos, patrol_radius, waypoint_count)
		state["waypoints"] = waypoints
		context.set_node_state(data.id, state)
	
	if is_waiting:
		wait_timer += context.delta_time
		if wait_timer >= wait_time:
			is_waiting = false
			wait_timer = 0.0
			waypoint_index = (waypoint_index + 1) % waypoints.size()
		else:
			state["wait_timer"] = wait_timer
			context.set_node_state(data.id, state)
			return BTNodeState.State.RUNNING
	
	var target_pos: Vector3 = waypoints[waypoint_index]
	target_pos.y = owner_3d.global_position.y
	
	var to_target: Vector3 = target_pos - owner_3d.global_position
	var distance: float = to_target.length()
	
	if distance <= tolerance:
		is_waiting = true
		wait_timer = 0.0
		state["is_waiting"] = is_waiting
		state["wait_timer"] = wait_timer
		state["waypoint_index"] = waypoint_index
		context.set_node_state(data.id, state)
		return BTNodeState.State.RUNNING
	
	var direction: Vector3 = to_target.normalized()
	var move_step: float = min(speed * context.delta_time, distance)
	owner_3d.global_position += direction * move_step
	
	if direction.length() > 0.01:
		owner_3d.look_at(owner_3d.global_position + direction, Vector3.UP)
	
	state["waypoint_index"] = waypoint_index
	state["is_waiting"] = is_waiting
	state["wait_timer"] = wait_timer
	context.set_node_state(data.id, state)
	
	return BTNodeState.State.RUNNING

func _generate_waypoints(center: Vector3, radius: float, count: int) -> Array:
	var waypoints: Array = []
	for i in range(count):
		var angle: float = (float(i) / float(count)) * TAU
		var wp: Vector3 = Vector3(
			center.x + cos(angle) * radius,
			center.y,
			center.z + sin(angle) * radius
		)
		waypoints.append(wp)
	return waypoints
