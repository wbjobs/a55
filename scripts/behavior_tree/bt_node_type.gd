class_name BTNodeType
extends RefCounted

enum NodeType {
	SEQUENCE,
	SELECTOR,
	CONDITION,
	ACTION,
	INVERTER,
	REPEATER,
	UNTIL_FAIL,
	UNTIL_SUCCESS
}

static func to_string(type: int) -> String:
	match type:
		NodeType.SEQUENCE:
			return "Sequence"
		NodeType.SELECTOR:
			return "Selector"
		NodeType.CONDITION:
			return "Condition"
		NodeType.ACTION:
			return "Action"
		NodeType.INVERTER:
			return "Inverter"
		NodeType.REPEATER:
			return "Repeater"
		NodeType.UNTIL_FAIL:
			return "UntilFail"
		NodeType.UNTIL_SUCCESS:
			return "UntilSuccess"
		_:
			return "Unknown"

static func from_string(type_str: String) -> int:
	match type_str:
		"Sequence":
			return NodeType.SEQUENCE
		"Selector":
			return NodeType.SELECTOR
		"Condition":
			return NodeType.CONDITION
		"Action":
			return NodeType.ACTION
		"Inverter":
			return NodeType.INVERTER
		"Repeater":
			return NodeType.REPEATER
		"UntilFail":
			return NodeType.UNTIL_FAIL
		"UntilSuccess":
			return NodeType.UNTIL_SUCCESS
		_:
			return -1

static func is_composite(type: int) -> bool:
	return type == NodeType.SEQUENCE or type == NodeType.SELECTOR

static func is_decorator(type: int) -> bool:
	return type in [NodeType.INVERTER, NodeType.REPEATER, NodeType.UNTIL_FAIL, NodeType.UNTIL_SUCCESS]

static func get_max_children(type: int) -> int:
	match type:
		NodeType.SEQUENCE, NodeType.SELECTOR:
			return -1
		NodeType.INVERTER, NodeType.REPEATER, NodeType.UNTIL_FAIL, NodeType.UNTIL_SUCCESS:
			return 1
		_:
			return 0
