class_name ActionIdle
extends BTAction

func execute(context: BTContext) -> int:
	var duration: float = float(get_property("duration", -1.0))
	
	if duration < 0.0:
		return BTNodeState.State.RUNNING
	
	var state: Dictionary = context.get_node_state(data.id)
	var elapsed: float = float(state.get("elapsed", 0.0))
	elapsed += context.delta_time
	state["elapsed"] = elapsed
	context.set_node_state(data.id, state)
	
	if elapsed >= duration:
		return BTNodeState.State.SUCCESS
	
	return BTNodeState.State.RUNNING
