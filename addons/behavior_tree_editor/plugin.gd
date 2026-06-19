@tool
extends EditorPlugin

var _editor_panel: Control = null
var _bottom_panel_button: Button = null
var _editor_script: Script = null

func _enter_tree() -> void:
	_editor_script = preload("res://addons/behavior_tree_editor/bt_editor.gd")
	_editor_panel = _editor_script.new()
	_bottom_panel_button = add_control_to_bottom_panel(_editor_panel, "行为树编辑器")
	_bottom_panel_button.tooltip_text = "打开可视化行为树编辑器"

func _exit_tree() -> void:
	if _editor_panel:
		remove_control_from_bottom_panel(_editor_panel)
		_editor_panel.queue_free()
		_editor_panel = null
	_bottom_panel_button = null

func _has_main_screen() -> bool:
	return false

func _make_visible(visible: bool) -> void:
	if _editor_panel:
		_editor_panel.visible = visible
