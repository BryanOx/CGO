class_name CurrencyPill
extends PanelContainer

var _amount_label: Label = Label.new()

func _init() -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	add_theme_stylebox_override(&"panel", ThemeFactory.panel_style(tokens, tokens.surface_alt))
	custom_minimum_size = Vector2(0.0, tokens.touch_target_min)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override(&"separation", int(tokens.space_xs))
	var icon: Label = Label.new()
	icon.text = "◈"
	icon.add_theme_color_override(&"font_color", tokens.primary)
	_amount_label.add_theme_color_override(&"font_color", tokens.text)
	_amount_label.text = "0"
	row.add_child(icon)
	row.add_child(_amount_label)
	add_child(row)

func set_amount(amount: int) -> void:
	_amount_label.text = str(amount)
