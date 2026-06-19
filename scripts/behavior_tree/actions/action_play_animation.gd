class_name ActionPlayAnimation
extends BTAction

func execute(context: BTContext) -> int:
	var owner: Node = context.owner
	if owner == null:
		return BTNodeState.State.FAILURE
	
	var anim_name: String = String(get_property("animation_name", "idle"))
	var wait_for_finish: bool = bool(get_property("wait_for_finish", false))
	
	var anim_player: AnimationPlayer = owner.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if anim_player == null:
		anim_player = _find_animation_player(owner)
	
	if anim_player == null:
		return BTNodeState.State.SUCCESS if not wait_for_finish else BTNodeState.State.FAILURE
	
	if not anim_player.has_animation(anim_name):
		return BTNodeState.State.FAILURE
	
	var state: Dictionary = context.get_node_state(data.id)
	if not bool(state.get("started", false)):
		anim_player.play(anim_name)
		state["started"] = true
		context.set_node_state(data.id, state)
		if not wait_for_finish:
			return BTNodeState.State.SUCCESS
	
	if wait_for_finish and anim_player.is_playing():
		return BTNodeState.State.RUNNING
	
	return BTNodeState.State.SUCCESS

func _find_animation_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child as AnimationPlayer
		var found: AnimationPlayer = _find_animation_player(child)
		if found:
			return found
	return null
