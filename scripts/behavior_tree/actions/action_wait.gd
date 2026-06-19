class_name ActionWait
extends BTAction

func execute(context: BTContext) -> int:
	var wait_duration: float = float(get_property("duration", 1.0))
	
	var state: Dictionary = context.get_node_state(data.id)
	var elapsed: float = float(state.get("elapsed", 0.0))
	elapsed += context.delta_time
	state["elapsed"] = elapsed
	context.set_node_state(data.id, state)
	
	if elapsed >= wait_duration:
		return BTNodeState.State.SUCCESS
	
	return BTNodeState.State.RUNNING
