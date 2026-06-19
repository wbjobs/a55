class_name BTNodeData
extends RefCounted

var id: String = ""
var type: int = BTNodeType.NodeType.ACTION
var name: String = ""
var description: String = ""
var properties: Dictionary = {}
var children: Array[BTNodeData] = []
var position: Vector2 = Vector2.ZERO

func _init() -> void:
	id = generate_id()

static func generate_id() -> String:
	return "node_%s_%s" % [Time.get_unix_time_from_system(), randi()]

func to_dict() -> Dictionary:
	var data: Dictionary = {
		"id": id,
		"type": BTNodeType.to_string(type),
		"name": name,
		"description": description,
		"properties": properties.duplicate(true),
		"position": {"x": position.x, "y": position.y},
		"children": []
	}
	for child in children:
		data["children"].append(child.to_dict())
	return data

static func from_dict(data: Dictionary) -> BTNodeData:
	var node_data := BTNodeData.new()
	node_data.id = data.get("id", generate_id())
	node_data.type = BTNodeType.from_string(data.get("type", "Action"))
	node_data.name = data.get("name", "")
	node_data.description = data.get("description", "")
	node_data.properties = data.get("properties", {}).duplicate(true)
	var pos: Dictionary = data.get("position", {"x": 0, "y": 0})
	node_data.position = Vector2(float(pos.get("x", 0)), float(pos.get("y", 0)))
	var children_data: Array = data.get("children", [])
	for child_data in children_data:
		node_data.children.append(BTNodeData.from_dict(child_data))
	return node_data

func duplicate() -> BTNodeData:
	return BTNodeData.from_dict(to_dict())

func find_node_by_id(node_id: String) -> BTNodeData:
	if id == node_id:
		return self
	for child in children:
		var found: BTNodeData = child.find_node_by_id(node_id)
		if found:
			return found
	return null

func remove_child_by_id(node_id: String) -> bool:
	for i in range(children.size()):
		if children[i].id == node_id:
			children.remove_at(i)
			return true
		if children[i].remove_child_by_id(node_id):
			return true
	return false

func add_child(child: BTNodeData) -> bool:
	var max_children: int = BTNodeType.get_max_children(type)
	if max_children == 0:
		return false
	if max_children > 0 and children.size() >= max_children:
		return false
	children.append(child)
	return true
