extends Node
## 行为树运行时组件，挂载到NPC上即可运行行为树

@export var behavior_tree_path: String = ""
@export var tick_interval: float = 0.1
@export var auto_start: bool = true

var tree_data: BTTreeData = null
var root_node: BTNode = null
var context: BTContext = null
var _tick_timer: float = 0.0
var _is_running: bool = false
var _is_paused: bool = false

signal tree_started()
signal tree_stopped()
signal node_executed(node_id: String, result: int)

func _ready() -> void:
	BTNodeRegistry.ensure_initialized()
	context = BTContext.new(self)
	if auto_start and behavior_tree_path != "":
		load_and_start(behavior_tree_path)

func _process(delta: float) -> void:
	if not _is_running or _is_paused:
		return
	context.delta_time = delta
	_tick_timer += delta
	if _tick_timer >= tick_interval:
		_tick_timer = 0.0
		_tick_tree()

func load_and_start(path: String) -> void:
	behavior_tree_path = path
	if load_tree(path):
		start()

func load_tree(path: String) -> bool:
	if path == "":
		push_error("Behavior tree path is empty")
		return false
	tree_data = BTTreeData.load_from_file(path)
	if tree_data == null:
		push_error("Failed to load behavior tree: %s" % path)
		return false
	return _build_runtime_tree()

func load_tree_from_data(data: BTTreeData) -> bool:
	tree_data = data
	return _build_runtime_tree()

func _build_runtime_tree() -> bool:
	if tree_data == null or tree_data.root == null:
		push_error("Behavior tree has no root")
		return false
	root_node = BTNodeFactory.create_node(tree_data.root)
	return root_node != null

func start() -> void:
	if root_node == null:
		push_error("No behavior tree loaded")
		return
	_is_running = true
	_is_paused = false
	context.clear_all_states()
	tree_started.emit()

func stop() -> void:
	_is_running = false
	if root_node:
		root_node.halt(context)
	tree_stopped.emit()

func pause() -> void:
	_is_paused = true

func resume() -> void:
	_is_paused = false

func is_running() -> bool:
	return _is_running and not _is_paused

func _tick_tree() -> void:
	if root_node == null:
		return
	var result: int = root_node.tick(context)
	node_executed.emit(root_node.data.id, result)
	if result != BTNodeState.State.RUNNING:
		root_node.exit(context)

func set_blackboard(key: String, value: Variant) -> void:
	if context:
		context.set_blackboard(key, value)

func get_blackboard(key: String, default: Variant = null) -> Variant:
	if context:
		return context.get_blackboard(key, default)
	return default
