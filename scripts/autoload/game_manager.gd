extends Node
## 游戏全局管理器，负责管理玩家引用、NPC注册等全局状态

var player: Node3D = null
var npcs: Array[Node3D] = []

signal player_registered(player_node: Node3D)
signal npc_registered(npc_node: Node3D)
signal npc_unregistered(npc_node: Node3D)

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
