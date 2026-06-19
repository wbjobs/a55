class_name ConditionLowHealth
extends BTCondition

func check_condition(context: BTContext) -> bool:
	var health_key: String = String(get_property("health_blackboard_key", "health"))
	var threshold: float = float(get_property("threshold", 30.0))
	
	var health: Variant = context.get_blackboard(health_key)
	if health == null:
		return bool(get_property("return_if_no_health", false))
	
	return float(health) <= threshold
