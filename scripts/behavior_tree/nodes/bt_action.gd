class_name BTAction
extends BTNode

func tick(context: BTContext) -> int:
	var timeout: float = float(get_property("timeout", 0.0))
	var state: Dictionary = context.get_node_state(data.id)
	
	if timeout > 0.0:
		var elapsed: float = float(state.get("elapsed", 0.0))
		elapsed += context.delta_time
		state["elapsed"] = elapsed
		context.set_node_state(data.id, state)
		
		if elapsed >= timeout:
			push_warning("Action '%s' timed out after %.2fs" % [data.name, timeout])
			return BTNodeState.State.FAILURE
	
	return execute(context)

func execute(context: BTContext) -> int:
	return BTNodeState.State.FAILURE
