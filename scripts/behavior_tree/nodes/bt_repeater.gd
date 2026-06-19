class_name BTRepeater
extends BTNode

func tick(context: BTContext) -> int:
	if children.is_empty():
		return BTNodeState.State.FAILURE
	
	var state: Dictionary = context.get_node_state(data.id)
	var repeat_count: int = state.get("repeat_count", 0)
	var max_repeats: int = int(get_property("max_repeats", -1))
	
	while true:
		var child_result: int = children[0].tick(context)
		
		if child_result == BTNodeState.State.RUNNING:
			return BTNodeState.State.RUNNING
		
		children[0].exit(context)
		repeat_count += 1
		state["repeat_count"] = repeat_count
		context.set_node_state(data.id, state)
		
		if max_repeats > 0 and repeat_count >= max_repeats:
			exit(context)
			return BTNodeState.State.SUCCESS
		
		if child_result == BTNodeState.State.FAILURE:
			exit(context)
			return BTNodeState.State.FAILURE
