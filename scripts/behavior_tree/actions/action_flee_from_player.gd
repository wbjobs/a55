class_name ActionFleeFromPlayer
extends BTAction

func execute(context: BTContext) -> int:
	var owner: Node = context.owner
	if owner == null or not (owner is Node3D):
		return BTNodeState.State.FAILURE
	
	var player: Node3D = GameManager.get_player()
	if player == null:
		return BTNodeState.State.FAILURE
	
	var owner_3d: Node3D = owner as Node3D
	var speed: float = float(get_property("speed", 4.0))
	var safe_distance: float = float(get_property("safe_distance", 15.0))
	
	var away_from_player: Vector3 = owner_3d.global_position - player.global_position
	away_from_player.y = 0.0
	var current_distance: float = away_from_player.length()
	
	if current_distance >= safe_distance:
		return BTNodeState.State.SUCCESS
	
	var direction: Vector3 = away_from_player.normalized()
	owner_3d.global_position += direction * speed * context.delta_time
	
	if direction.length() > 0.01:
		owner_3d.look_at(owner_3d.global_position + direction, Vector3.UP)
	
	return BTNodeState.State.RUNNING
