class_name BTTreeData
extends RefCounted

var root: BTNodeData = null
var name: String = "BehaviorTree"
var description: String = ""
var version: String = "1.0"
var created_at: String = ""
var updated_at: String = ""

func _init() -> void:
	created_at = Time.get_datetime_string_from_system()
	updated_at = created_at

func to_dict() -> Dictionary:
	var data: Dictionary = {
		"name": name,
		"description": description,
		"version": version,
		"created_at": created_at,
		"updated_at": Time.get_datetime_string_from_system(),
		"root": null
	}
	if root:
		data["root"] = root.to_dict()
	return data

static func from_dict(data: Dictionary) -> BTTreeData:
	var tree_data := BTTreeData.new()
	tree_data.name = data.get("name", "BehaviorTree")
	tree_data.description = data.get("description", "")
	tree_data.version = data.get("version", "1.0")
	tree_data.created_at = data.get("created_at", "")
	tree_data.updated_at = data.get("updated_at", "")
	if data.has("root") and data["root"]:
		tree_data.root = BTNodeData.from_dict(data["root"])
	return tree_data

func to_json() -> String:
	return JSON.stringify(to_dict(), "\t")

static func from_json(json_str: String) -> BTTreeData:
	var parse_result: JSONParseResult = JSON.parse(json_str)
	if parse_result.error != OK:
		push_error("Failed to parse behavior tree JSON: %s" % parse_result.error_string)
		return null
	if typeof(parse_result.data) != TYPE_DICTIONARY:
		push_error("Behavior tree JSON root must be an object")
		return null
	return from_dict(parse_result.data)

func save_to_file(file_path: String) -> bool:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: %s" % file_path)
		return false
	file.store_string(to_json())
	file.close()
	return true

static func load_from_file(file_path: String) -> BTTreeData:
	if not FileAccess.file_exists(file_path):
		push_error("File does not exist: %s" % file_path)
		return null
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: %s" % file_path)
		return null
	var json_str: String = file.get_as_text()
	file.close()
	return from_json(json_str)

func duplicate() -> BTTreeData:
	return BTTreeData.from_dict(to_dict())
