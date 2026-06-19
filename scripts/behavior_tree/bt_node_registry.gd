class_name BTNodeRegistry
extends RefCounted

static var _conditions: Dictionary = {}
static var _actions: Dictionary = {}
static var _initialized: bool = false

static func ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	_register_conditions()
	_register_actions()

static func _register_conditions() -> void:
	_conditions["IsPlayerInSight"] = preload("res://scripts/behavior_tree/conditions/condition_player_in_sight.gd")
	_conditions["IsDistanceToPlayer"] = preload("res://scripts/behavior_tree/conditions/condition_distance_to_player.gd")
	_conditions["HasReachedTarget"] = preload("res://scripts/behavior_tree/conditions/condition_has_reached_target.gd")
	_conditions["IsLowHealth"] = preload("res://scripts/behavior_tree/conditions/condition_low_health.gd")
	_conditions["RandomChance"] = preload("res://scripts/behavior_tree/conditions/condition_random_chance.gd")
	_conditions["CanSeePlayer"] = preload("res://scripts/behavior_tree/conditions/condition_can_see_player.gd")
	_conditions["HeardSound"] = preload("res://scripts/behavior_tree/conditions/condition_heard_sound.gd")
	_conditions["IsTouched"] = preload("res://scripts/behavior_tree/conditions/condition_touched.gd")
	_conditions["AlertLevel"] = preload("res://scripts/behavior_tree/conditions/condition_alert_level.gd")

static func _register_actions() -> void:
	_actions["MoveToPosition"] = preload("res://scripts/behavior_tree/actions/action_move_to_position.gd")
	_actions["MoveToPlayer"] = preload("res://scripts/behavior_tree/actions/action_move_to_player.gd")
	_actions["Patrol"] = preload("res://scripts/behavior_tree/actions/action_patrol.gd")
	_actions["PlayAnimation"] = preload("res://scripts/behavior_tree/actions/action_play_animation.gd")
	_actions["Wait"] = preload("res://scripts/behavior_tree/actions/action_wait.gd")
	_actions["FleeFromPlayer"] = preload("res://scripts/behavior_tree/actions/action_flee_from_player.gd")
	_actions["LookAtPlayer"] = preload("res://scripts/behavior_tree/actions/action_look_at_player.gd")
	_actions["Idle"] = preload("res://scripts/behavior_tree/actions/action_idle.gd")
	_actions["SetBlackboardValue"] = preload("res://scripts/behavior_tree/actions/action_set_blackboard.gd")

static func has_condition(name: String) -> bool:
	ensure_initialized()
	return _conditions.has(name)

static func has_action(name: String) -> bool:
	ensure_initialized()
	return _actions.has(name)

static func get_condition(name: String) -> GDScript:
	ensure_initialized()
	return _conditions.get(name, null)

static func get_action(name: String) -> GDScript:
	ensure_initialized()
	return _actions.get(name, null)

static func get_all_conditions() -> Dictionary:
	ensure_initialized()
	return _conditions.duplicate()

static func get_all_actions() -> Dictionary:
	ensure_initialized()
	return _actions.duplicate()

static func get_condition_names() -> Array:
	ensure_initialized()
	return _conditions.keys()

static func get_action_names() -> Array:
	ensure_initialized()
	return _actions.keys()

static func register_condition(name: String, script: GDScript) -> void:
	ensure_initialized()
	_conditions[name] = script

static func register_action(name: String, script: GDScript) -> void:
	ensure_initialized()
	_actions[name] = script
