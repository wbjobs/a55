class_name ConditionDistanceToPlayer
extends BTCondition

func check_condition(context: BTContext) -> bool:
	var owner: Node = context.owner
	if owner == null or not (owner is Node3D):
		return false
	
	var player: Node3D = GameManager.get_player()
	if player == null:
		return bool(get_property("return_if_no_player", false))
	
	var min_distance: float = float(get_property("min_distance", 0.0))
	var max_distance: float = float(get_property("max_distance", 10.0))
	
	var owner_3d: Node3D = owner as Node3D
	var distance: float = owner_3d.global_position.distance_to(player.global_position)
	
	return distance >= min_distance and distance <= max_distance
