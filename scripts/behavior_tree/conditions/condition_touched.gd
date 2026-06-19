class_name ConditionTouched
extends BTCondition

func check_condition(context: BTContext) -> bool:
	var owner: Node = context.owner
	if owner == null:
		return false
	
	var require_player: bool = bool(get_property("require_player", false))
	
	var touch_sense: Node = owner.get_node_or_null("SenseTouch")
	if touch_sense == null:
		touch_sense = _find_sense_touch(owner)
	if touch_sense == null:
		return false
	
	if require_player:
		return touch_sense.is_touching_player()
	return touch_sense.is_touching_anything()

func _find_sense_touch(node: Node) -> Node:
	for child in node.get_children():
		if child.has_method("is_touching_anything"):
			return child
		var found: Node = _find_sense_touch(child)
		if found:
			return found
	return null
