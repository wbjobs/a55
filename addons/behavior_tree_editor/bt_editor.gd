@tool
extends Control

var tree_data: BTTreeData = null
var selected_node_id: String = ""

var _h_split: HSplitContainer = null
var _left_panel: VBoxContainer = null
var _canvas_panel: PanelContainer = null
var _canvas_scroll: ScrollContainer = null
var _canvas: Control = null
var _draw_layer: Control = null
var _node_layer: Control = null
var _right_panel: VBoxContainer = null
var _toolbar: HBoxContainer = null
var _node_library: VBoxContainer = null
var _property_editor: VBoxContainer = null
var _tree_info_panel: VBoxContainer = null

var _zoom: float = 1.0
var _pan_offset: Vector2 = Vector2.ZERO
var _is_dragging_node: bool = false
var _dragged_node_id: String = ""
var _drag_start_mouse: Vector2 = Vector2.ZERO
var _drag_start_node_pos: Vector2 = Vector2.ZERO
var _is_connecting: bool = false
var _connecting_from_id: String = ""
var _connecting_mouse: Vector2 = Vector2.ZERO

signal node_selected(node_id: String)
signal tree_modified()

func _ready() -> void:
	BTNodeRegistry.ensure_initialized()
	_build_ui()
	new_tree()

func _build_ui() -> void:
	_h_split = HSplitContainer.new()
	_h_split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_h_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_h_split)
	_h_split.split_offset = 200
	
	_build_left_panel()
	_build_canvas()
	_build_right_panel()

func _build_left_panel() -> void:
	_left_panel = VBoxContainer.new()
	_left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_left_panel.custom_minimum_size = Vector2(180, 0)
	_h_split.add_child(_left_panel)
	
	var label := Label.new()
	label.text = "节点库"
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	_left_panel.add_child(label)
	
	_node_library = VBoxContainer.new()
	_node_library.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_node_library.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(_node_library)
	_left_panel.add_child(scroll)
	
	_add_library_category("组合节点", [
		{"type": BTNodeType.NodeType.SEQUENCE, "name": "顺序节点 (Sequence)", "color": Color(0.2, 0.6, 0.9)},
		{"type": BTNodeType.NodeType.SELECTOR, "name": "选择节点 (Selector)", "color": Color(0.9, 0.6, 0.2)},
	])
	_add_library_category("装饰节点", [
		{"type": BTNodeType.NodeType.INVERTER, "name": "取反节点 (Inverter)", "color": Color(0.6, 0.4, 0.9)},
		{"type": BTNodeType.NodeType.REPEATER, "name": "重复节点 (Repeater)", "color": Color(0.4, 0.7, 0.7)},
		{"type": BTNodeType.NodeType.UNTIL_FAIL, "name": "直到失败 (UntilFail)", "color": Color(0.7, 0.4, 0.4)},
		{"type": BTNodeType.NodeType.UNTIL_SUCCESS, "name": "直到成功 (UntilSuccess)", "color": Color(0.4, 0.7, 0.4)},
	])
	_add_library_condition_nodes()
	_add_library_action_nodes()

func _add_library_category(title: String, items: Array) -> void:
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	title_label.add_theme_font_size_override("font_size", 11)
	_node_library.add_child(title_label)
	
	for item in items:
		var btn := Button.new()
		btn.text = item["name"]
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.add_theme_stylebox_override("normal", _make_stylebox(item["color"], 0.3))
		btn.add_theme_stylebox_override("hover", _make_stylebox(item["color"], 0.5))
		btn.pressed.connect(func(): _create_node_from_library(item["type"], item["name"]))
		_node_library.add_child(btn)

func _add_library_condition_nodes() -> void:
	var title_label := Label.new()
	title_label.text = "条件节点"
	title_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	title_label.add_theme_font_size_override("font_size", 11)
	_node_library.add_child(title_label)
	
	for name in BTNodeRegistry.get_condition_names():
		var btn := Button.new()
		btn.text = name
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.add_theme_stylebox_override("normal", _make_stylebox(Color(0.9, 0.3, 0.3), 0.4))
		btn.add_theme_stylebox_override("hover", _make_stylebox(Color(0.9, 0.3, 0.3), 0.6))
		btn.pressed.connect(func(n = name): _create_condition_node(n))
		_node_library.add_child(btn)

func _add_library_action_nodes() -> void:
	var title_label := Label.new()
	title_label.text = "动作节点"
	title_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	title_label.add_theme_font_size_override("font_size", 11)
	_node_library.add_child(title_label)
	
	for name in BTNodeRegistry.get_action_names():
		var btn := Button.new()
		btn.text = name
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.add_theme_stylebox_override("normal", _make_stylebox(Color(0.2, 0.8, 0.4), 0.4))
		btn.add_theme_stylebox_override("hover", _make_stylebox(Color(0.2, 0.8, 0.4), 0.6))
		btn.pressed.connect(func(n = name): _create_action_node(n))
		_node_library.add_child(btn)

func _build_canvas() -> void:
	_canvas_panel = PanelContainer.new()
	_canvas_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_canvas_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_h_split.add_child(_canvas_panel)
	
	var canvas_vbox := VBoxContainer.new()
	_canvas_panel.add_child(canvas_vbox)
	
	_toolbar = HBoxContainer.new()
	_toolbar.add_theme_constant_override("separation", 4)
	canvas_vbox.add_child(_toolbar)
	
	_add_toolbar_button("新建", self.new_tree, "创建新的行为树")
	_add_toolbar_button("加载", self._on_load_pressed, "从JSON文件加载行为树")
	_add_toolbar_button("保存", self._on_save_pressed, "保存为JSON文件")
	_add_toolbar_button("保存为...", self._on_save_as_pressed, "另存为JSON文件")
	_add_toolbar_separator()
	_add_toolbar_button("缩放+", func(): _set_zoom(_zoom * 1.2), "放大视图")
	_add_toolbar_button("缩放-", func(): _set_zoom(_zoom / 1.2), "缩小视图")
	_add_toolbar_button("重置", func(): _set_zoom(1.0); _pan_offset = Vector2.ZERO; _refresh_canvas(), "重置视图")
	_add_toolbar_separator()
	_add_toolbar_button("删除选中", self._on_delete_selected, "删除选中的节点")
	_add_toolbar_button("断开连线", self._on_disconnect_selected, "断开选中节点的父连接")
	
	_canvas_scroll = ScrollContainer.new()
	_canvas_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_canvas_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	canvas_vbox.add_child(_canvas_scroll)
	
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(2000, 1500)
	_canvas.mouse_filter = Control.MOUSE_FILTER_STOP
	_canvas.gui_input.connect(_on_canvas_gui_input)
	_canvas_scroll.add_child(_canvas)
	
	_draw_layer = Control.new()
	_draw_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_draw_layer.draw.connect(_on_draw_layer_draw)
	_canvas.add_child(_draw_layer)
	
	_node_layer = Control.new()
	_node_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.add_child(_node_layer)

func _build_right_panel() -> void:
	_right_panel = VBoxContainer.new()
	_right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_right_panel.custom_minimum_size = Vector2(250, 0)
	_h_split.add_child(_right_panel)
	_h_split.split_offset = _h_split.split_offset + 250
	
	_tree_info_panel = VBoxContainer.new()
	_right_panel.add_child(_tree_info_panel)
	
	var info_label := Label.new()
	info_label.text = "行为树信息"
	info_label.add_theme_font_size_override("font_size", 14)
	_tree_info_panel.add_child(info_label)
	
	var tree_name_label := Label.new()
	tree_name_label.text = "名称:"
	tree_name_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	_tree_info_panel.add_child(tree_name_label)
	
	var tree_name_edit := LineEdit.new()
	tree_name_edit.placeholder_text = "行为树名称"
	tree_name_edit.text_changed.connect(func(t): 
		if tree_data:
			tree_data.name = t
			tree_modified.emit()
	)
	_tree_info_panel.add_child(tree_name_edit)
	call_deferred("_set_tree_name_edit_ref", tree_name_edit)
	
	var selected_label := Label.new()
	selected_label.text = "节点属性"
	selected_label.add_theme_font_size_override("font_size", 14)
	selected_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_right_panel.add_child(selected_label)
	
	_property_editor = VBoxContainer.new()
	_property_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var prop_scroll := ScrollContainer.new()
	prop_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	prop_scroll.add_child(_property_editor)
	_right_panel.add_child(prop_scroll)

var _tree_name_edit: LineEdit = null
func _set_tree_name_edit_ref(ref: LineEdit) -> void:
	_tree_name_edit = ref

func _add_toolbar_button(text: String, callback: Callable, tooltip: String = "") -> void:
	var btn := Button.new()
	btn.text = text
	btn.tooltip_text = tooltip
	btn.pressed.connect(callback)
	_toolbar.add_child(btn)

func _add_toolbar_separator() -> void:
	var sep := VSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	_toolbar.add_child(sep)

func _make_stylebox(color: Color, alpha: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(color.r, color.g, color.b, alpha)
	sb.border_color = color
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	return sb

func new_tree() -> void:
	tree_data = BTTreeData.new()
	tree_data.name = "NewBehaviorTree"
	var root := BTNodeData.new()
	root.type = BTNodeType.NodeType.SELECTOR
	root.name = "RootSelector"
	root.description = "根节点"
	root.position = Vector2(800, 100)
	tree_data.root = root
	selected_node_id = ""
	_refresh_canvas()
	_refresh_property_editor()
	if _tree_name_edit:
		_tree_name_edit.text = tree_data.name

func _on_load_pressed() -> void:
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.add_filter("*.json ; JSON行为树文件")
	dialog.file_selected.connect(func(path):
		var loaded := BTTreeData.load_from_file(path)
		if loaded:
			tree_data = loaded
			selected_node_id = ""
			if _tree_name_edit:
				_tree_name_edit.text = tree_data.name
			_refresh_canvas()
			_refresh_property_editor()
	)
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)

func _on_save_pressed() -> void:
	if not tree_data:
		return
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE
	dialog.add_filter("*.json ; JSON行为树文件")
	dialog.current_path = "res://data/behavior_trees/" + tree_data.name + ".json"
	dialog.file_selected.connect(func(path):
		if not path.ends_with(".json"):
			path += ".json"
		tree_data.save_to_file(path)
	)
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)

func _on_save_as_pressed() -> void:
	_on_save_pressed()

func _on_delete_selected() -> void:
	if selected_node_id == "" or not tree_data or not tree_data.root:
		return
	if tree_data.root.id == selected_node_id:
		return
	tree_data.root.remove_child_by_id(selected_node_id)
	selected_node_id = ""
	_refresh_canvas()
	_refresh_property_editor()
	tree_modified.emit()

func _on_disconnect_selected() -> void:
	if selected_node_id == "" or not tree_data or not tree_data.root:
		return
	if tree_data.root.id == selected_node_id:
		return
	tree_data.root.remove_child_by_id(selected_node_id)
	_refresh_canvas()
	tree_modified.emit()

func _set_zoom(z: float) -> void:
	_zoom = clampf(z, 0.3, 3.0)
	if _node_layer:
		_node_layer.scale = Vector2(_zoom, _zoom)
		_draw_layer.scale = Vector2(_zoom, _zoom)

func _create_node_from_library(type: int, display_name: String) -> void:
	var node_data := BTNodeData.new()
	node_data.type = type
	node_data.name = BTNodeType.to_string(type)
	node_data.description = display_name
	node_data.position = Vector2(400, 300) + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	_add_node_to_tree(node_data)

func _create_condition_node(name: String) -> void:
	var node_data := BTNodeData.new()
	node_data.type = BTNodeType.NodeType.CONDITION
	node_data.name = name
	node_data.description = "条件节点"
	node_data.position = Vector2(400, 300) + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	_populate_default_condition_properties(node_data)
	_add_node_to_tree(node_data)

func _create_action_node(name: String) -> void:
	var node_data := BTNodeData.new()
	node_data.type = BTNodeType.NodeType.ACTION
	node_data.name = name
	node_data.description = "动作节点"
	node_data.position = Vector2(400, 300) + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	_populate_default_action_properties(node_data)
	_add_node_to_tree(node_data)

func _populate_default_condition_properties(node_data: BTNodeData) -> void:
	match node_data.name:
		"IsPlayerInSight":
			node_data.properties = {"vision_range": 15.0, "vision_angle": 90.0}
		"IsDistanceToPlayer":
			node_data.properties = {"min_distance": 0.0, "max_distance": 10.0, "return_if_no_player": false}
		"HasReachedTarget":
			node_data.properties = {"target_blackboard_key": "target_position", "tolerance": 0.5, "return_if_no_target": false}
		"IsLowHealth":
			node_data.properties = {"health_blackboard_key": "health", "threshold": 30.0, "return_if_no_health": false}
		"RandomChance":
			node_data.properties = {"chance": 0.5}

func _populate_default_action_properties(node_data: BTNodeData) -> void:
	var default_timeout: float = _get_default_timeout_for_action(node_data.name)
	match node_data.name:
		"MoveToPosition":
			node_data.properties = {"speed": 3.0, "tolerance": 0.3, "target_blackboard_key": "target_position", "stop_on_y": true, "use_flow_field": false, "flow_field_weight": 0.7, "timeout": default_timeout}
		"MoveToPlayer":
			node_data.properties = {"speed": 3.0, "tolerance": 0.3, "target_blackboard_key": "target_position", "use_flow_field": true, "flow_field_weight": 0.8, "timeout": default_timeout}
		"Patrol":
			node_data.properties = {"speed": 2.0, "patrol_radius": 5.0, "waypoint_count": 4, "wait_time": 2.0, "center_blackboard_key": "home_position", "use_flow_field": false, "timeout": default_timeout}
		"PlayAnimation":
			node_data.properties = {"animation_name": "idle", "wait_for_finish": false, "timeout": default_timeout}
		"Wait":
			node_data.properties = {"duration": 1.0, "timeout": default_timeout}
		"FleeFromPlayer":
			node_data.properties = {"speed": 4.0, "safe_distance": 15.0, "use_flow_field": true, "flee_search_distance": 8.0, "timeout": default_timeout}
		"LookAtPlayer":
			node_data.properties = {"lerp_speed": 5.0, "instant": false, "timeout": default_timeout}
		"Idle":
			node_data.properties = {"duration": -1.0, "timeout": default_timeout}
		"SetBlackboardValue":
			node_data.properties = {"key": "", "value_type": "string", "value": "", "timeout": default_timeout}
		_:
			node_data.properties = {"timeout": default_timeout}

func _get_default_timeout_for_action(action_name: String) -> float:
	match action_name:
		"MoveToPosition":
			return 10.0
		"MoveToPlayer":
			return 15.0
		"Patrol":
			return 0.0
		"PlayAnimation":
			return 5.0
		"Wait":
			return 0.0
		"FleeFromPlayer":
			return 0.0
		"LookAtPlayer":
			return 0.0
		"Idle":
			return 0.0
		"SetBlackboardValue":
			return 0.0
		_:
			return 0.0

func _add_node_to_tree(node_data: BTNodeData) -> void:
	if not tree_data:
		new_tree()
	if not tree_data.root:
		tree_data.root = node_data
	else:
		if selected_node_id != "":
			var parent: BTNodeData = tree_data.root.find_node_by_id(selected_node_id)
			if parent and parent.add_child(node_data):
				pass
			else:
				push_warning("不能添加子节点到此类型")
	_refresh_canvas()
	selected_node_id = node_data.id
	_refresh_property_editor()
	tree_modified.emit()

func _refresh_canvas() -> void:
	if not _node_layer:
		return
	for child in _node_layer.get_children():
		child.queue_free()
	if tree_data and tree_data.root:
		_render_node_recursive(tree_data.root, _node_layer)
	if _draw_layer:
		_draw_layer.queue_redraw()

func _render_node_recursive(node_data: BTNodeData, parent: Control) -> void:
	var node_gui := _create_node_gui(node_data)
	parent.add_child(node_gui)
	for child in node_data.children:
		_render_node_recursive(child, parent)

func _create_node_gui(node_data: BTNodeData) -> Control:
	var node_gui := Control.new()
	node_gui.position = node_data.position
	node_gui.custom_minimum_size = Vector2(160, 60)
	node_gui.name = "node_" + node_data.id
	node_gui.set_meta("node_id", node_data.id)
	node_gui.mouse_filter = Control.MOUSE_FILTER_PASS
	
	var bg := Panel.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var color := _get_node_color(node_data.type)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(color.r, color.g, color.b, 0.8)
	sb.border_color = color
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	if node_data.id == selected_node_id:
		sb.border_color = Color(1, 1, 0)
		sb.border_width_left = 3
		sb.border_width_right = 3
		sb.border_width_top = 3
		sb.border_width_bottom = 3
	bg.add_theme_stylebox_override("panel", sb)
	node_gui.add_child(bg)
	
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 0)
	node_gui.add_child(vbox)
	
	var type_label := Label.new()
	type_label.text = BTNodeType.to_string(node_data.type)
	type_label.add_theme_font_size_override("font_size", 9)
	type_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(type_label)
	
	var name_label := Label.new()
	name_label.text = node_data.name
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)
	
	var click_recv := Control.new()
	click_recv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_recv.mouse_filter = Control.MOUSE_FILTER_STOP
	click_recv.gui_input.connect(func(event): _on_node_gui_input(event, node_data, node_gui))
	node_gui.add_child(click_recv)
	
	var input_port := Control.new()
	input_port.position = Vector2(-6, 24)
	input_port.custom_minimum_size = Vector2(12, 12)
	input_port.mouse_filter = Control.MOUSE_FILTER_STOP
	var port_color := Color(0.5, 0.8, 1.0)
	var in_sb := StyleBoxFlat.new()
	in_sb.bg_color = port_color
	in_sb.corner_radius_top_left = 6
	in_sb.corner_radius_top_right = 6
	in_sb.corner_radius_bottom_left = 6
	in_sb.corner_radius_bottom_right = 6
	var in_panel := Panel.new()
	in_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	in_panel.add_theme_stylebox_override("panel", in_sb)
	input_port.add_child(in_panel)
	input_port.gui_input.connect(func(event): _on_port_input(event, node_data, true))
	node_gui.add_child(input_port)
	
	var output_port := Control.new()
	output_port.position = Vector2(154, 24)
	output_port.custom_minimum_size = Vector2(12, 12)
	output_port.mouse_filter = Control.MOUSE_FILTER_STOP
	var out_sb := StyleBoxFlat.new()
	out_sb.bg_color = Color(1.0, 0.6, 0.3)
	out_sb.corner_radius_top_left = 6
	out_sb.corner_radius_top_right = 6
	out_sb.corner_radius_bottom_left = 6
	out_sb.corner_radius_bottom_right = 6
	var out_panel := Panel.new()
	out_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	out_panel.add_theme_stylebox_override("panel", out_sb)
	output_port.add_child(out_panel)
	output_port.gui_input.connect(func(event): _on_port_input(event, node_data, false))
	node_gui.add_child(output_port)
	
	return node_gui

func _get_node_color(type: int) -> Color:
	match type:
		BTNodeType.NodeType.SEQUENCE:
			return Color(0.2, 0.6, 0.9)
		BTNodeType.NodeType.SELECTOR:
			return Color(0.9, 0.6, 0.2)
		BTNodeType.NodeType.CONDITION:
			return Color(0.9, 0.3, 0.3)
		BTNodeType.NodeType.ACTION:
			return Color(0.2, 0.8, 0.4)
		BTNodeType.NodeType.INVERTER:
			return Color(0.6, 0.4, 0.9)
		BTNodeType.NodeType.REPEATER:
			return Color(0.4, 0.7, 0.7)
		_:
			return Color(0.5, 0.5, 0.5)

func _on_node_gui_input(event: InputEvent, node_data: BTNodeData, node_gui: Control) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected_node_id = node_data.id
			_is_dragging_node = true
			_dragged_node_id = node_data.id
			_drag_start_mouse = event.position
			_drag_start_node_pos = node_data.position
			_refresh_canvas()
			_refresh_property_editor()
			node_selected.emit(node_data.id)
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging_node = false
	elif event is InputEventMouseMotion and _is_dragging_node and _dragged_node_id == node_data.id:
		node_data.position = _drag_start_node_pos + (event.position - _drag_start_mouse) / _zoom
		node_gui.position = node_data.position
		_draw_layer.queue_redraw()
		tree_modified.emit()

func _on_port_input(event: InputEvent, node_data: BTNodeData, is_input: bool) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not is_input:
				_is_connecting = true
				_connecting_from_id = node_data.id
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _is_connecting:
			if is_input and _connecting_from_id != "" and _connecting_from_id != node_data.id:
				_connect_nodes(_connecting_from_id, node_data.id)
			_is_connecting = false
			_connecting_from_id = ""
			_draw_layer.queue_redraw()
	elif event is InputEventMouseMotion and _is_connecting:
		_connecting_mouse = event.global_position - _canvas.global_position
		_draw_layer.queue_redraw()

func _connect_nodes(from_id: String, to_id: String) -> void:
	if not tree_data or not tree_data.root:
		return
	var from_node: BTNodeData = tree_data.root.find_node_by_id(from_id)
	var to_node: BTNodeData = tree_data.root.find_node_by_id(to_id)
	if not from_node or not to_node:
		return
	if _is_descendant(to_node, from_node):
		push_warning("不能创建循环连接")
		return
	tree_data.root.remove_child_by_id(to_id)
	if from_node.add_child(to_node):
		_refresh_canvas()
		tree_modified.emit()
	else:
		push_warning("此节点不能添加更多子节点")

func _is_descendant(ancestor: BTNodeData, node: BTNodeData) -> bool:
	if ancestor == node:
		return true
	for child in ancestor.children:
		if _is_descendant(child, node):
			return true
	return false

func _on_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected_node_id = ""
			_refresh_canvas()
			_refresh_property_editor()
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_is_connecting = false
			_connecting_from_id = ""
			_draw_layer.queue_redraw()
	elif event is InputEventMouseMotion and _is_connecting:
		_connecting_mouse = event.position
		_draw_layer.queue_redraw()

func _on_draw_layer_draw() -> void:
	if not tree_data or not tree_data.root:
		return
	_draw_connections_recursive(tree_data.root)
	if _is_connecting and _connecting_from_id != "":
		var from_pos := _get_node_port_position(_connecting_from_id, false)
		if from_pos:
			_draw_layer.draw_line(from_pos, _connecting_mouse, Color(1, 0.5, 0.2, 0.8), 2.0)

func _draw_connections_recursive(node_data: BTNodeData) -> void:
	var from_pos := _get_node_port_position(node_data.id, false)
	if not from_pos:
		return
	for child in node_data.children:
		var to_pos := _get_node_port_position(child.id, true)
		if to_pos:
			var mid_x: float = (from_pos.x + to_pos.x) * 0.5
			var p1: Vector2 = Vector2(mid_x, from_pos.y)
			var p2: Vector2 = Vector2(mid_x, to_pos.y)
			_draw_layer.draw_line(from_pos, p1, Color(0.6, 0.6, 0.7), 2.0)
			_draw_layer.draw_line(p1, p2, Color(0.6, 0.6, 0.7), 2.0)
			_draw_layer.draw_line(p2, to_pos, Color(0.6, 0.6, 0.7), 2.0)
		_draw_connections_recursive(child)

func _get_node_port_position(node_id: String, is_input: bool) -> Vector2:
	var node_gui: Control = _node_layer.get_node_or_null("node_" + node_id) as Control
	if not node_gui:
		return Vector2.ZERO
	if is_input:
		return node_gui.position + Vector2(0, 30)
	else:
		return node_gui.position + Vector2(160, 30)

func _refresh_property_editor() -> void:
	for child in _property_editor.get_children():
		child.queue_free()
	
	if not tree_data or selected_node_id == "":
		var hint := Label.new()
		hint.text = "选择一个节点以编辑属性"
		hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		_property_editor.add_child(hint)
		return
	
	var node_data: BTNodeData = tree_data.root.find_node_by_id(selected_node_id)
	if not node_data:
		return
	
	_add_prop_label("节点类型: " + BTNodeType.to_string(node_data.type))
	_add_prop_label("节点ID: " + node_data.id.substr(0, 20) + "...")
	_add_prop_spacer()
	
	_add_prop_label("显示名称")
	var name_edit := LineEdit.new()
	name_edit.text = node_data.name
	name_edit.text_changed.connect(func(t):
		node_data.name = t
		_refresh_canvas()
		tree_modified.emit()
	)
	_property_editor.add_child(name_edit)
	
	_add_prop_label("描述")
	var desc_edit := TextEdit.new()
	desc_edit.text = node_data.description
	desc_edit.custom_minimum_size = Vector2(0, 50)
	desc_edit.text_changed.connect(func():
		node_data.description = desc_edit.text
		tree_modified.emit()
	)
	_property_editor.add_child(desc_edit)
	
	if node_data.properties.size() > 0:
		_add_prop_spacer()
		_add_prop_label("参数属性")
		for key in node_data.properties.keys():
			_add_property_field(node_data, key)

func _add_prop_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	label.add_theme_font_size_override("font_size", 10)
	_property_editor.add_child(label)

func _add_prop_spacer() -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	_property_editor.add_child(spacer)

func _add_property_field(node_data: BTNodeData, key: String) -> void:
	var value: Variant = node_data.properties[key]
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	_property_editor.add_child(hbox)
	
	var key_label := Label.new()
	key_label.text = key
	key_label.custom_minimum_size = Vector2(90, 0)
	key_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	key_label.add_theme_font_size_override("font_size", 10)
	hbox.add_child(key_label)
	
	match typeof(value):
		TYPE_BOOL:
			var check := CheckBox.new()
			check.button_pressed = bool(value)
			check.toggled.connect(func(p):
				node_data.properties[key] = p
				tree_modified.emit()
			)
			hbox.add_child(check)
		TYPE_INT, TYPE_FLOAT:
			var spin := SpinBox.new()
			spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spin.min_value = -100000
			spin.max_value = 100000
			spin.step = 0.1 if typeof(value) == TYPE_FLOAT else 1.0
			spin.value = float(value)
			spin.value_changed.connect(func(v):
				if typeof(value) == TYPE_INT:
					node_data.properties[key] = int(v)
				else:
					node_data.properties[key] = v
				tree_modified.emit()
			)
			hbox.add_child(spin)
		_:
			var line_edit := LineEdit.new()
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line_edit.text = String(value)
			line_edit.text_changed.connect(func(t):
				if typeof(value) == TYPE_FLOAT:
					node_data.properties[key] = float(t)
				elif typeof(value) == TYPE_INT:
					node_data.properties[key] = int(t)
				else:
					node_data.properties[key] = t
				tree_modified.emit()
			)
			hbox.add_child(line_edit)
