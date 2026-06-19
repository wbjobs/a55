class_name ActionMoveToPosition
extends BTAction

func execute(context: BTContext) -> int:
	var owner: Node = context.owner
	if owner == null or not (owner is Node3D):
		return BTNodeState.State.FAILURE
	
	var owner_3d: Node3D = owner as Node3D
	var speed: float = float(get_property("speed", 3.0))
	var target_key: String = String(get_property("target_blackboard_key", "target_position"))
	var tolerance: float = float(get_property("tolerance", 0.3))
	var stop_on_y: bool = bool(get_property("stop_on_y", true))
	var use_flow_field: bool = bool(get_property("use_flow_field", false))
	var flow_field_weight: float = float(get_property("flow_field_weight", 0.7))
	
	var target: Variant = context.get_blackboard(target_key)
	if target == null:
		return BTNodeState.State.FAILURE
	
	var target_pos: Vector3
	if typeof(target) == TYPE_VECTOR3:
		target_pos = target as Vector3
	elif target is Node3D:
		target_pos = (target as Node3D).global_position
	else:
		return BTNodeState.State.FAILURE
	
	if stop_on_y:
		target_pos.y = owner_3d.global_position.y
	
	var to_target: Vector3 = target_pos - owner_3d.global_position
	var distance: float = to_target.length()
	
	if distance <= tolerance:
		return BTNodeState.State.SUCCESS
	
	var direction: Vector3
	if use_flow_field and FlowFieldManager:
		var flow_dir: Vector3 = FlowFieldManager.get_direction(owner_3d.global_position, target_pos)
		if flow_dir.length() > 0.01:
			var straight_dir: Vector3 = to_target.normalized()
			direction = flow_dir.lerp(straight_dir, 1.0 - flow_field_weight).normalized()
		else:
			direction = to_target.normalized()
	else:
		direction = to_target.normalized()
	
	var move_step: float = min(speed * context.delta_time, distance)
	owner_3d.global_position += direction * move_step
	
	if direction.length() > 0.01:
		owner_3d.look_at(owner_3d.global_position + direction, Vector3.UP)
	
	return BTNodeState.State.RUNNING
