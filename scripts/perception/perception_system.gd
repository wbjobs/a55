extends Node
## 全局感知系统 - 管理全局声音事件等

class_name PerceptionSystem

var _global_sounds: Array = []
var _max_global_sounds: int = 50

signal sound_heard(stimulus: Stimulus)

func _process(delta: float) -> void:
	_cleanup_old_sounds()

func emit_sound(source: Node3D, position: Vector3, volume: float = 1.0, radius: float = 20.0, tag: String = "") -> void:
	var stimulus := Stimulus.new()
	stimulus.type = SenseType.Type.HEARING
	stimulus.source = source
	stimulus.position = position
	stimulus.strength = volume
	stimulus.duration = radius * 0.1
	stimulus.tag = tag
	_global_sounds.append(stimulus)
	sound_heard.emit(stimulus)
	
	_cleanup_old_sounds()

func get_sounds_in_range(position: Vector3, range: float) -> Array:
	var result: Array = []
	for stim in _global_sounds:
		var dist: float = position.distance_to(stim.position)
		if dist <= range:
			result.append(stim)
	return result

func get_loudest_sound(position: Vector3, range: float) -> Stimulus:
	var loudest: Stimulus = null
	var loudest_strength: float = 0.0
	
	for stim in _global_sounds:
		var dist: float = position.distance_to(stim.position)
		if dist <= range:
			var effective: float = stim.get_current_strength() * (1.0 - dist / range)
			if effective > loudest_strength:
				loudest_strength = effective
				loudest = stim
	
	return loudest

func _cleanup_old_sounds() -> void:
	var to_remove: Array = []
	for stim in _global_sounds:
		if stim.is_expired():
			to_remove.append(stim)
	for stim in to_remove:
		_global_sounds.erase(stim)
	
	while _global_sounds.size() > _max_global_sounds:
		_global_sounds.pop_front()

func get_global_sound_count() -> int:
	return _global_sounds.size()
