extends FeatureScreen

const LANGUAGE_CODES: Array[String] = ["en", "es", "pt"]
const LANGUAGE_LABELS: Array[String] = ["English", "Spanish", "Portuguese"]

var _settings: Dictionary = {}
var _audio: CheckButton = null
var _motion: CheckButton = null
var _haptics: CheckButton = null
var _language: OptionButton = null

func _ready() -> void:
	super._ready()
	var tokens: DesignTokens = DesignTokens.get_shared()
	var column: VBoxContainer = new_column()
	column.add_child(new_label("Settings", tokens.font_display))
	_audio = _toggle("Audio", tokens)
	_motion = _toggle("Reduced motion", tokens)
	_haptics = _toggle("Haptics", tokens)
	column.add_child(_labeled_toggle("Audio", _audio, tokens))
	column.add_child(_labeled_toggle("Reduced motion", _motion, tokens))
	column.add_child(_labeled_toggle("Haptics", _haptics, tokens))
	_language = OptionButton.new()
	_language.custom_minimum_size = Vector2(0.0, tokens.touch_target_min)
	_language.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_language.add_theme_color_override(&"font_color", tokens.text)
	_language.add_theme_font_size_override(&"font_size", int(tokens.font_body))
	for index: int in range(LANGUAGE_CODES.size()):
		_language.add_item(LANGUAGE_LABELS[index], index)
	column.add_child(_labeled_control("Language", _language, tokens))
	if context != null and context.services != null:
		_settings = context.services.settings.load_settings()
	_audio.set_pressed_no_signal(bool(_settings.get("audio_enabled", true)))
	_motion.set_pressed_no_signal(bool(_settings.get("reduced_motion", false)))
	_haptics.set_pressed_no_signal(bool(_settings.get("haptics_enabled", true)))
	var code_index: int = LANGUAGE_CODES.find(String(_settings.get("language", "en")))
	_language.select(code_index if code_index >= 0 else 0)
	_audio.toggled.connect(_on_bool_toggled.bind(&"audio_enabled"))
	_motion.toggled.connect(_on_bool_toggled.bind(&"reduced_motion"))
	_haptics.toggled.connect(_on_bool_toggled.bind(&"haptics_enabled"))
	_language.item_selected.connect(_on_language_selected)
	add_nav(column)
	safe_area.add_child(column)

func _toggle(_title: String, tokens: DesignTokens) -> CheckButton:
	var toggle: CheckButton = CheckButton.new()
	toggle.custom_minimum_size = Vector2(0.0, tokens.touch_target_min)
	toggle.add_theme_color_override(&"font_color", tokens.text)
	toggle.add_theme_font_size_override(&"font_size", int(tokens.font_body))
	return toggle

func _labeled_toggle(title: String, toggle: CheckButton, tokens: DesignTokens) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", ThemeFactory.panel_style(tokens, tokens.surface))
	var row: HBoxContainer = new_row()
	var label: Label = new_label(title, tokens.font_body)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	row.add_child(toggle)
	panel.add_child(row)
	return panel

func _labeled_control(title: String, control: Control, tokens: DesignTokens) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", ThemeFactory.panel_style(tokens, tokens.surface))
	var column: VBoxContainer = new_column(tokens.space_xs)
	column.add_child(new_label(title, tokens.font_caption, true))
	column.add_child(control)
	panel.add_child(column)
	return panel

func _save() -> void:
	if context != null and context.services != null:
		context.services.settings.save_settings(_settings)

func _on_bool_toggled(pressed: bool, key: StringName) -> void:
	_settings[String(key)] = pressed
	_save()

func _on_language_selected(index: int) -> void:
	if index < 0 or index >= LANGUAGE_CODES.size():
		return
	_settings["language"] = LANGUAGE_CODES[index]
	_save()
