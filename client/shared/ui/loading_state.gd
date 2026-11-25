class_name LoadingState
extends Control

var _label: Label = Label.new()
var _progress: ProgressBar = ProgressBar.new()

func _init() -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override(&"separation", int(tokens.space_sm))
	_label.text = "Loading..."
	_label.add_theme_font_size_override(&"font_size", int(tokens.font_body))
	_label.add_theme_color_override(&"font_color", tokens.text_muted)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress.indeterminate = true
	_progress.custom_minimum_size = Vector2(0.0, tokens.space_md)
	column.add_child(_label)
	column.add_child(_progress)
	center.add_child(column)
	add_child(center)

func set_active(active: bool) -> void:
	visible = active
	_progress.indeterminate = true
