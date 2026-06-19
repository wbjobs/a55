class_name ConditionHasReachedTarget
extends BTCondition

func check_condition(context: BTContext) -> bool:
	var owner: Node = context.owner
	if owner == null or not (owner is Node3D):
		return false
	
	var owner_3d: Node3D = owner as Node3D
	var target_key: String = String(get_property("target_blackboard_key", "target_position"))
	var tolerance: float = float(get_property("tolerance", 0.5))
	
	var target: Variant = context.get_blackboard(target_key)
	if target == null:
		return bool(get_property("return_if_no_target", false))
	
	if typeof(target) == TYPE_VECTOR3:
		var dist: float = owner_3d.global_position.distance_to(target as Vector3)
		return dist <= tolerance
	elif target is Node3D:
		var dist: float = owner_3d.global_position.distance_to((target as Node3D).global_position)
		return dist <= tolerance
	
	return false
