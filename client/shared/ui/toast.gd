class_name Toast
extends Control

var _panel: PanelContainer = PanelContainer.new()
var _label: Label = Label.new()
var _timer: Timer = Timer.new()

func _init() -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_bottom = -tokens.space_md
	_label.add_theme_font_size_override(&"font_size", int(tokens.font_body))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(_label)
	_timer.one_shot = true
	_timer.wait_time = tokens.toast_duration_seconds
	_timer.timeout.connect(_on_timeout)
	add_child(_panel)
	add_child(_timer)
	visible = false

func show_message(text: String, is_error: bool = false) -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	var fill: Color = tokens.success if not is_error else tokens.danger
	_panel.add_theme_stylebox_override(&"panel", ThemeFactory.panel_style(tokens, fill))
	var text_color: Color = tokens.on_primary if is_error else tokens.background
	_label.add_theme_color_override(&"font_color", text_color)
	_label.text = text
	visible = true
	if _timer.is_inside_tree():
		_timer.start()
	else:
		_timer.autostart = true

func _on_timeout() -> void:
	_timer.autostart = false
	visible = false
