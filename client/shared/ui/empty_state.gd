class_name EmptyState
extends Control

signal action_pressed

var _title_label: Label = Label.new()
var _detail_label: Label = Label.new()

func _init() -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override(&"separation", int(tokens.space_sm))
	_title_label.add_theme_font_size_override(&"font_size", int(tokens.font_title))
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.add_theme_font_size_override(&"font_size", int(tokens.font_body))
	_detail_label.add_theme_color_override(&"font_color", tokens.text_muted)
	_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var action: AppButton = AppButton.new()
	action.text = "Retry"
	action.pressed.connect(_on_action_pressed)
	column.add_child(_title_label)
	column.add_child(_detail_label)
	column.add_child(action)
	center.add_child(column)
	add_child(center)

func set_message(title: String, detail: String) -> void:
	_title_label.text = title
	_detail_label.text = detail

func _on_action_pressed() -> void:
	action_pressed.emit()
