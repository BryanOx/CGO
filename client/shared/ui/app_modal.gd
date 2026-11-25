class_name AppModal
extends Control

signal confirmed
signal cancelled

var _title_label: Label = Label.new()
var _message_label: Label = Label.new()

func _init() -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = tokens.background
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", ThemeFactory.panel_style(tokens, tokens.surface))
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override(&"separation", int(tokens.space_md))
	_title_label.add_theme_font_size_override(&"font_size", int(tokens.font_title))
	_message_label.add_theme_font_size_override(&"font_size", int(tokens.font_body))
	_message_label.add_theme_color_override(&"font_color", tokens.text_muted)
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var confirm: AppButton = AppButton.new()
	confirm.text = "Confirm"
	confirm.pressed.connect(_on_confirmed)
	var cancel: AppButton = AppButton.new()
	cancel.set_variant(&"secondary")
	cancel.text = "Cancel"
	cancel.pressed.connect(_on_cancelled)
	column.add_child(_title_label)
	column.add_child(_message_label)
	column.add_child(confirm)
	column.add_child(cancel)
	panel.add_child(column)
	center.add_child(panel)
	add_child(overlay)
	add_child(center)
	visible = false

func show_modal(title: String, message: String) -> void:
	_title_label.text = title
	_message_label.text = message
	visible = true

func hide_modal() -> void:
	visible = false

func _on_confirmed() -> void:
	confirmed.emit()
	hide_modal()

func _on_cancelled() -> void:
	cancelled.emit()
	hide_modal()
