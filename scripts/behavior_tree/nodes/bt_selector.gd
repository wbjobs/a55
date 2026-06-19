class_name BTSelector
extends BTNode

func tick(context: BTContext) -> int:
	var state: Dictionary = context.get_node_state(data.id)
	var current_index: int = state.get("current_index", 0)
	
	for i in range(current_index, children.size()):
		state["current_index"] = i
		context.set_node_state(data.id, state)
		
		var child_result: int = children[i].tick(context)
		
		if child_result == BTNodeState.State.RUNNING:
			return BTNodeState.State.RUNNING
		elif child_result == BTNodeState.State.SUCCESS:
			exit(context)
			return BTNodeState.State.SUCCESS
		children[i].exit(context)
	
	exit(context)
	return BTNodeState.State.FAILURE
