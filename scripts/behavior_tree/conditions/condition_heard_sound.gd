class_name ConditionHeardSound
extends BTCondition

func check_condition(context: BTContext) -> bool:
	var owner: Node = context.owner
	if owner == null:
		return false
	
	var tag: String = String(get_property("tag", ""))
	var hearing_sense: Node = owner.get_node_or_null("SenseHearing")
	if hearing_sense == null:
		hearing_sense = _find_sense_hearing(owner)
	if hearing_sense == null:
		return false
	
	return hearing_sense.has_heard_sound(tag)

func _find_sense_hearing(node: Node) -> Node:
	for child in node.get_children():
		if child.has_method("has_heard_sound"):
			return child
		var found: Node = _find_sense_hearing(child)
		if found:
			return found
	return null
