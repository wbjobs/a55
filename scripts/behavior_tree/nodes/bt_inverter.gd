class_name BTInverter
extends BTNode

func tick(context: BTContext) -> int:
	if children.is_empty():
		return BTNodeState.State.FAILURE
	
	var child_result: int = children[0].tick(context)
	
	if child_result == BTNodeState.State.RUNNING:
		return BTNodeState.State.RUNNING
	elif child_result == BTNodeState.State.SUCCESS:
		return BTNodeState.State.FAILURE
	else:
		return BTNodeState.State.SUCCESS
