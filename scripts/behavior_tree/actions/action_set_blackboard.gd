class_name ActionSetBlackboardValue
extends BTAction

func execute(context: BTContext) -> int:
	var key: String = String(get_property("key", ""))
	var value_type: String = String(get_property("value_type", "string"))
	var value_str: String = String(get_property("value", ""))
	
	if key == "":
		return BTNodeState.State.FAILURE
	
	var value: Variant = _parse_value(value_type, value_str)
	context.set_blackboard(key, value)
	
	return BTNodeState.State.SUCCESS

func _parse_value(value_type: String, value_str: String) -> Variant:
	match value_type:
		"string":
			return value_str
		"int":
			return int(value_str)
		"float":
			return float(value_str)
		"bool":
			return value_str.to_lower() == "true"
		"vector3":
			var parts: Array = value_str.split(",")
			if parts.size() >= 3:
				return Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
			return Vector3.ZERO
		_:
			return value_str
