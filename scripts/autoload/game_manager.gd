extends Node
## 游戏全局管理器，负责管理玩家引用、NPC注册等全局状态

var player: Node3D = null
var npcs: Array[Node3D] = []
var _obstacles_initialized: bool = false

signal player_registered(player_node: Node3D)
signal npc_registered(npc_node: Node3D)
signal npc_unregistered(npc_node: Node3D)

var _debug_show: bool = false

func _ready() -> void:
	await get_tree().process_frame
	_initialize_obstacles()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_flow_field_debug"):
		_debug_show = not _debug_show
		toggle_flow_field_debug(_debug_show)
		if _debug_show:
			print("Flow Field Debug: ON")
		else:
			print("Flow Field Debug: OFF")

func register_player(p: Node3D) -> void:
	player = p
	player_registered.emit(p)

func register_npc(npc: Node3D) -> void:
	if not npcs.has(npc):
		npcs.append(npc)
		npc_registered.emit(npc)

func unregister_npc(npc: Node3D) -> void:
	if npcs.has(npc):
		npcs.erase(npc)
		npc_unregistered.emit(npc)

func get_player() -> Node3D:
	return player

func get_nearby_npcs(position: Vector3, radius: float) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for npc in npcs:
		if npc and npc.global_position.distance_to(position) <= radius:
			result.append(npc)
	return result

func _initialize_obstacles() -> void:
	if _obstacles_initialized or not FlowFieldManager:
		return
	_obstacles_initialized = true
	
	var obstacles: Array = []
	var root: Node = get_tree().current_scene
	if root:
		_find_static_obstacles(root, obstacles)
		FlowFieldManager.register_static_obstacles(obstacles)

func _find_static_obstacles(node: Node, out_obstacles: Array) -> void:
	if node is StaticBody3D and node.name.to_lower().contains("crate"):
		out_obstacles.append(node)
	for child in node.get_children():
		_find_static_obstacles(child, out_obstacles)

func register_obstacle(world_pos: Vector3, radius: float = 1.0) -> void:
	if FlowFieldManager:
		FlowFieldManager.register_obstacle(world_pos, radius)

func toggle_flow_field_debug(show: bool) -> void:
	if FlowFieldManager:
		FlowFieldManager.toggle_debug(show)

func get_flow_field_manager() -> FlowFieldManager:
	return FlowFieldManager
