class_name Stimulus
extends RefCounted

var type: int = SenseType.Type.SIGHT
var source: Node3D = null
var position: Vector3 = Vector3.ZERO
var strength: float = 1.0
var timestamp: float = 0.0
var duration: float = 0.0
var tag: String = ""

func _init() -> void:
	timestamp = Time.get_ticks_msec() / 1000.0

func get_age() -> float:
	return Time.get_ticks_msec() / 1000.0 - timestamp

func is_expired() -> bool:
	if duration <= 0.0:
		return false
	return get_age() > duration

func get_current_strength() -> float:
	if duration <= 0.0:
		return strength
	var age: float = get_age()
	var fade: float = 1.0 - clampf(age / duration, 0.0, 1.0)
	return strength * fade
