extends Node3D

@export var behavior_tree_path: String = "res://data/behavior_trees/guard_patrol.json"
@export var npc_name: String = "NPC"
@export var health: float = 100.0
@export var display_color: Color = Color(0.8, 0.2, 0.2, 1)

var behavior_tree: Node = null

func _ready() -> void:
	GameManager.register_npc(self)
	_setup_behavior_tree()
	var mesh: MeshInstance3D = get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh:
		var mat: StandardMaterial3D = mesh.material_override
		if mat:
			mat.albedo_color = display_color

func _setup_behavior_tree() -> void:
	var bt_script: Script = load("res://scripts/behavior_tree/behavior_tree.gd")
	behavior_tree = bt_script.new()
	behavior_tree.behavior_tree_path = behavior_tree_path
	behavior_tree.auto_start = true
	add_child(behavior_tree)
	
	await get_tree().process_frame
	
	if behavior_tree and behavior_tree.has_method("set_blackboard"):
		behavior_tree.set_blackboard("home_position", global_position)
		behavior_tree.set_blackboard("health", health)
		behavior_tree.set_blackboard("npc_name", npc_name)

func _exit_tree() -> void:
	GameManager.unregister_npc(self)

func set_behavior_tree(path: String) -> void:
	behavior_tree_path = path
	if behavior_tree and behavior_tree.has_method("load_and_start"):
		behavior_tree.load_and_start(path)
