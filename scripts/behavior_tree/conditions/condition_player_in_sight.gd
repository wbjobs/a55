class_name ConditionPlayerInSight
extends BTCondition

func check_condition(context: BTContext) -> bool:
	var owner: Node = context.owner
	if owner == null or not (owner is Node3D):
		return false
	
	var player: Node3D = GameManager.get_player()
	if player == null:
		return false
	
	var vision_range: float = float(get_property("vision_range", 15.0))
	var vision_angle: float = float(get_property("vision_angle", 90.0))
	
	var owner_3d: Node3D = owner as Node3D
	var to_player: Vector3 = player.global_position - owner_3d.global_position
	to_player.y = 0.0
	
	var distance: float = to_player.length()
	if distance > vision_range:
		return false
	
	var forward: Vector3 = -owner_3d.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	var angle: float = rad_to_deg(forward.angle_to(to_player.normalized()))
	return angle <= vision_angle * 0.5
