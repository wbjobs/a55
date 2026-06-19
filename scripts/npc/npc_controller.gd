extends Node3D

@export var behavior_tree_path: String = "res://data/behavior_trees/guard_patrol.json"
@export var npc_name: String = "NPC"
@export var health: float = 100.0
@export var display_color: Color = Color(0.8, 0.2, 0.2, 1)

@export_group("感知设置")
@export var enable_sight: bool = true
@export var vision_range: float = 15.0
@export var vision_angle: float = 90.0
@export var enable_hearing: bool = true
@export var hearing_range: float = 25.0
@export var enable_touch: bool = true
@export var touch_radius: float = 1.5
@export var show_perception_visuals: bool = true

var behavior_tree: Node = null
var sense_sight: Node3D = null
var sense_hearing: Node3D = null
var sense_touch: Area3D = null

func _ready() -> void:
	GameManager.register_npc(self)
	_setup_senses()
	_setup_behavior_tree()
	var mesh: MeshInstance3D = get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh:
		var mat: StandardMaterial3D = mesh.material_override
		if mat:
			mat.albedo_color = display_color

func _setup_senses() -> void:
	if enable_sight:
		var sight_script: Script = load("res://scripts/perception/sense_sight.gd")
		sense_sight = Node3D.new()
		sense_sight.set_script(sight_script)
		sense_sight.name = "SenseSight"
		sense_sight.vision_range = vision_range
		sense_sight.vision_angle = vision_angle
		sense_sight.show_visualization = show_perception_visuals
		add_child(sense_sight)
	
	if enable_hearing:
		var hearing_script: Script = load("res://scripts/perception/sense_hearing.gd")
		sense_hearing = Node3D.new()
		sense_hearing.set_script(hearing_script)
		sense_hearing.name = "SenseHearing"
		sense_hearing.hearing_range = hearing_range
		sense_hearing.show_visualization = show_perception_visuals
		add_child(sense_hearing)
		if sense_hearing.has_signal("sound_heard"):
			sense_hearing.sound_heard.connect(_on_sound_heard)
	
	if enable_touch:
		var touch_script: Script = load("res://scripts/perception/sense_touch.gd")
		sense_touch = Area3D.new()
		sense_touch.set_script(touch_script)
		sense_touch.name = "SenseTouch"
		sense_touch.touch_radius = touch_radius
		sense_touch.show_visualization = show_perception_visuals
		var sphere_shape := SphereShape3D.new()
		sphere_shape.radius = touch_radius
		var collision := CollisionShape3D.new()
		collision.shape = sphere_shape
		sense_touch.add_child(collision)
		add_child(sense_touch)
		if sense_touch.has_signal("body_touched"):
			sense_touch.body_touched.connect(_on_body_touched)

func _on_sound_heard(stimulus: Stimulus) -> void:
	if behavior_tree and behavior_tree.has_method("set_blackboard"):
		behavior_tree.set_blackboard("last_heard_position", stimulus.position)
		behavior_tree.set_blackboard("heard_sound_tag", stimulus.tag)

func _on_body_touched(body: Node3D, position: Vector3) -> void:
	if behavior_tree and behavior_tree.has_method("set_blackboard"):
		behavior_tree.set_blackboard("last_touch_position", position)
		behavior_tree.set_blackboard("is_touched", true)

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
		behavior_tree.set_blackboard("is_touched", false)

func _exit_tree() -> void:
	GameManager.unregister_npc(self)

func set_behavior_tree(path: String) -> void:
	behavior_tree_path = path
	if behavior_tree and behavior_tree.has_method("load_and_start"):
		behavior_tree.load_and_start(path)

func get_sense_memory(sense_type: int) -> PerceptionMemory:
	match sense_type:
		SenseType.Type.SIGHT:
			if sense_sight:
				return sense_sight.memory
		SenseType.Type.HEARING:
			if sense_hearing:
				return sense_hearing.memory
		SenseType.Type.TOUCH:
			if sense_touch:
				return sense_touch.memory
	return null

func set_perception_visible(visible: bool) -> void:
	show_perception_visuals = visible
	if sense_sight:
		sense_sight.show_visualization = visible
	if sense_hearing:
		sense_hearing.show_visualization = visible
	if sense_touch:
		sense_touch.show_visualization = visible
