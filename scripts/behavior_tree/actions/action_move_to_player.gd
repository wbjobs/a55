class_name ActionMoveToPlayer
extends BTAction

func execute(context: BTContext) -> int:
	var player: Node3D = GameManager.get_player()
	if player == null:
		return BTNodeState.State.FAILURE
	
	context.set_blackboard(String(get_property("target_blackboard_key", "target_position")), player.global_position)
	
	var move_action := ActionMoveToPosition.new(data)
	return move_action.execute(context)
