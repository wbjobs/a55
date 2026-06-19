class_name ConditionCanSeePlayer
extends BTCondition

func check_condition(context: BTContext) -> bool:
	var owner: Node = context.owner
	if owner == null:
		return false
	
	var sight_sense: Node = owner.get_node_or_null("SenseSight")
	if sight_sense == null:
		sight_sense = _find_sense_sight(owner)
	if sight_sense == null:
		return false
	
	return sight_sense.is_target_visible()

func _find_sense_sight(node: Node) -> Node:
	for child in node.get_children():
		if child.has_method("is_target_visible"):
			return child
		var found: Node = _find_sense_sight(child)
		if found:
			return found
	return null
