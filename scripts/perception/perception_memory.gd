class_name PerceptionMemory
extends RefCounted

var max_stimuli: int = 20
var retention_time: float = 5.0
var _stimuli: Array = []

signal stimulus_added(stimulus: Stimulus)
signal stimulus_removed(stimulus: Stimulus)

func _init(max_items: int = 20, retention: float = 5.0) -> void:
	max_stimuli = max_items
	retention_time = retention

func add_stimulus(stimulus: Stimulus) -> void:
	_stimuli.append(stimulus)
	stimulus_added.emit(stimulus)
	
	_cleanup()

func _cleanup() -> void:
	var to_remove: Array = []
	for stim in _stimuli:
		if stim.get_age() > retention_time:
			to_remove.append(stim)
		elif stim.is_expired():
			to_remove.append(stim)
	
	for stim in to_remove:
		_stimuli.erase(stim)
		stimulus_removed.emit(stim)
	
	while _stimuli.size() > max_stimuli:
		var removed: Stimulus = _stimuli.pop_front()
		stimulus_removed.emit(removed)

func get_latest_stimulus(sense_type: int = -1) -> Stimulus:
	_cleanup()
	for i in range(_stimuli.size() - 1, -1, -1):
		var stim: Stimulus = _stimuli[i]
		if sense_type == -1 or stim.type == sense_type:
			return stim
	return null

func get_latest_by_tag(tag: String) -> Stimulus:
	_cleanup()
	for i in range(_stimuli.size() - 1, -1, -1):
		var stim: Stimulus = _stimuli[i]
		if stim.tag == tag:
			return stim
	return null

func get_all_stimuli(sense_type: int = -1) -> Array:
	_cleanup()
	var result: Array = []
	for stim in _stimuli:
		if sense_type == -1 or stim.type == sense_type:
			result.append(stim)
	return result

func has_stimulus(sense_type: int) -> bool:
	_cleanup()
	for stim in _stimuli:
		if stim.type == sense_type:
			return true
	return false

func has_stimulus_with_tag(tag: String) -> bool:
	_cleanup()
	for stim in _stimuli:
		if stim.tag == tag:
			return true
	return false

func clear() -> void:
	for stim in _stimuli:
		stimulus_removed.emit(stim)
	_stimuli.clear()

func get_stimulus_count() -> int:
	_cleanup()
	return _stimuli.size()
