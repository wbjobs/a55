class_name ConditionAlertLevel
extends BTCondition

func check_condition(context: BTContext) -> bool:
	var owner: Node = context.owner
	if owner == null:
		return false
	
	var threshold: float = float(get_property("threshold", 0.5))
	var comparison: String = String(get_property("comparison", "greater"))
	
	var hearing_sense: Node = owner.get_node_or_null("SenseHearing")
	if hearing_sense == null:
		hearing_sense = _find_sense_hearing(owner)
	if hearing_sense == null:
		return false
	
	var alert_level: float = hearing_sense.get_alert_level()
	
	match comparison:
		"greater":
			return alert_level > threshold
		"greater_or_equal":
			return alert_level >= threshold
		"less":
			return alert_level < threshold
		"less_or_equal":
			return alert_level <= threshold
		"equal":
			return abs(alert_level - threshold) < 0.01
		_:
			return alert_level > threshold

func _find_sense_hearing(node: Node) -> Node:
	for child in node.get_children():
		if child.has_method("get_alert_level"):
			return child
		var found: Node = _find_sense_hearing(child)
		if found:
			return found
	return null
