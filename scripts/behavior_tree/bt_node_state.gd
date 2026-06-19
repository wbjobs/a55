class_name BTNodeState
extends RefCounted

enum State {
	SUCCESS,
	FAILURE,
	RUNNING
}

static func to_string(state: int) -> String:
	match state:
		State.SUCCESS:
			return "SUCCESS"
		State.FAILURE:
			return "FAILURE"
		State.RUNNING:
			return "RUNNING"
		_:
			return "UNKNOWN"
