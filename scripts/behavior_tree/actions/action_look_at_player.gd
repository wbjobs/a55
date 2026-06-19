class_name ActionLookAtPlayer
extends BTAction

func execute(context: BTContext) -> int:
	var owner: Node = context.owner
	if owner == null or not (owner is Node3D):
		return BTNodeState.State.FAILURE
	
	var player: Node3D = GameManager.get_player()
	if player == null:
		return BTNodeState.State.FAILURE
	
	var owner_3d: Node3D = owner as Node3D
	var lerp_speed: float = float(get_property("lerp_speed", 5.0))
	
	var look_target: Vector3 = player.global_position
	look_target.y = owner_3d.global_position.y
	
	var target_basis: Basis = Basis.looking_at(look_target - owner_3d.global_position, Vector3.UP)
	owner_3d.global_transform.basis = owner_3d.global_transform.basis.slerp(target_basis, clampf(lerp_speed * context.delta_time, 0.0, 1.0))
	
	var instant: bool = bool(get_property("instant", false))
	if instant:
		return BTNodeState.State.SUCCESS
	
	return BTNodeState.State.RUNNING
