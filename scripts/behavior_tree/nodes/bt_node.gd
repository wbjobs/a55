class_name BTNode
extends RefCounted

var data: BTNodeData = null
var children: Array[BTNode] = []

func _init(node_data: BTNodeData) -> void:
	data = node_data
	for child_data in node_data.children:
		children.append(BTNodeFactory.create_node(child_data))

func tick(context: BTContext) -> int:
	return BTNodeState.State.FAILURE

func enter(context: BTContext) -> void:
	pass

func exit(context: BTContext) -> void:
	context.clear_node_state(data.id)

func halt(context: BTContext) -> void:
	for child in children:
		child.halt(context)
	exit(context)

func get_property(key: String, default_value: Variant = null) -> Variant:
	if data.properties.has(key):
		return data.properties[key]
	return default_value

func set_property(key: String, value: Variant) -> void:
	data.properties[key] = value
