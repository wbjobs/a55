class_name SenseType
extends RefCounted

enum Type {
	SIGHT,
	HEARING,
	TOUCH,
	SMELL
}

static func to_string(type: int) -> String:
	match type:
		Type.SIGHT:
			return "Sight"
		Type.HEARING:
			return "Hearing"
		Type.TOUCH:
			return "Touch"
		Type.SMELL:
			return "Smell"
		_:
			return "Unknown"

static func get_default_color(type: int) -> Color:
	match type:
		Type.SIGHT:
			return Color(0.3, 0.7, 1.0, 0.3)
		Type.HEARING:
			return Color(1.0, 0.8, 0.2, 0.3)
		Type.TOUCH:
			return Color(1.0, 0.3, 0.3, 0.3)
		Type.SMELL:
			return Color(0.5, 0.9, 0.5, 0.3)
		_:
			return Color(1, 1, 1, 0.3)
