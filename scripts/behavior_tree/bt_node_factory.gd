class_name BTNodeFactory
extends RefCounted

static func create_node(node_data: BTNodeData) -> BTNode:
	match node_data.type:
		BTNodeType.NodeType.SEQUENCE:
			return BTSequence.new(node_data)
		BTNodeType.NodeType.SELECTOR:
			return BTSelector.new(node_data)
		BTNodeType.NodeType.INVERTER:
			return BTInverter.new(node_data)
		BTNodeType.NodeType.REPEATER:
			return BTRepeater.new(node_data)
		BTNodeType.NodeType.UNTIL_FAIL:
			return BTUntilFail.new(node_data)
		BTNodeType.NodeType.UNTIL_SUCCESS:
			return BTUntilSuccess.new(node_data)
		BTNodeType.NodeType.CONDITION:
			return create_condition_node(node_data)
		BTNodeType.NodeType.ACTION:
			return create_action_node(node_data)
		_:
			push_error("Unknown node type: %s" % node_data.type)
			return BTAction.new(node_data)

static func create_condition_node(node_data: BTNodeData) -> BTNode:
	var condition_name: String = node_data.name
	if BTNodeRegistry.has_condition(condition_name):
		var condition_class: GDScript = BTNodeRegistry.get_condition(condition_name)
		return condition_class.new(node_data)
	push_warning("Unknown condition: %s, using default" % condition_name)
	return BTCondition.new(node_data)

static func create_action_node(node_data: BTNodeData) -> BTNode:
	var action_name: String = node_data.name
	if BTNodeRegistry.has_action(action_name):
		var action_class: GDScript = BTNodeRegistry.get_action(action_name)
		return action_class.new(node_data)
	push_warning("Unknown action: %s, using default" % action_name)
	return BTAction.new(node_data)
