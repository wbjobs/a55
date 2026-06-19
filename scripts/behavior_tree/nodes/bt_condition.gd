class_name BTCondition
extends BTNode

func tick(context: BTContext) -> int:
	if check_condition(context):
		return BTNodeState.State.SUCCESS
	return BTNodeState.State.FAILURE

func check_condition(context: BTContext) -> bool:
	return false
