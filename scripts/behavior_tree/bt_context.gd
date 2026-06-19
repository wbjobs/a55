class_name BTContext
extends RefCounted

var owner: Node = null
var blackboard: Dictionary = {}
var delta_time: float = 0.0
var _running_nodes: Dictionary = {}

func _init(owner_node: Node) -> void:
	owner = owner_node

func set_blackboard(key: String, value: Variant) -> void:
	blackboard[key] = value

func get_blackboard(key: String, default: Variant = null) -> Variant:
	if blackboard.has(key):
		return blackboard[key]
	return default

func has_blackboard(key: String) -> bool:
	return blackboard.has(key)

func clear_blackboard() -> void:
	blackboard.clear()

func set_node_state(node_id: String, state: Dictionary) -> void:
	_running_nodes[node_id] = state

func get_node_state(node_id: String) -> Dictionary:
	if _running_nodes.has(node_id):
		return _running_nodes[node_id]
	return {}

func clear_node_state(node_id: String) -> void:
	if _running_nodes.has(node_id):
		_running_nodes.erase(node_id)

func clear_all_states() -> void:
	_running_nodes.clear()
