class_name BTAction
extends BTNode

func tick(context: BTContext) -> int:
	return execute(context)

func execute(context: BTContext) -> int:
	return BTNodeState.State.FAILURE
