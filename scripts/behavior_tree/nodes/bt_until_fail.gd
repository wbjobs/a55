class_name BTUntilFail
extends BTNode

func tick(context: BTContext) -> int:
	if children.is_empty():
		return BTNodeState.State.FAILURE
	
	while true:
		var child_result: int = children[0].tick(context)
		
		if child_result == BTNodeState.State.RUNNING:
			return BTNodeState.State.RUNNING
		elif child_result == BTNodeState.State.FAILURE:
			children[0].exit(context)
			exit(context)
			return BTNodeState.State.SUCCESS
		children[0].exit(context)
