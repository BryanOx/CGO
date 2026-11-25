class_name AppButton
extends Button

func _init() -> void:
	custom_minimum_size = Vector2(0.0, DesignTokens.get_shared().touch_target_min)
	set_variant(&"primary")

func set_variant(variant: StringName) -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	var fill: Color = tokens.primary
	var border: Color = tokens.primary
	var text_color: Color = tokens.on_primary
	match variant:
		&"secondary":
			fill = tokens.surface_alt
			border = tokens.text_muted
			text_color = tokens.text
		&"ghost":
			fill = Color.TRANSPARENT
			border = Color.TRANSPARENT
			text_color = tokens.primary
	add_theme_stylebox_override(&"normal", ThemeFactory.button_style(tokens, fill, border))
	add_theme_stylebox_override(
		&"hover", ThemeFactory.button_style(tokens, fill.lightened(0.08), border)
	)
	add_theme_stylebox_override(
		&"pressed", ThemeFactory.button_style(tokens, fill.darkened(0.08), border)
	)
	add_theme_stylebox_override(
		&"disabled", ThemeFactory.button_style(tokens, tokens.surface_alt, tokens.text_muted)
	)
	add_theme_color_override(&"font_color", text_color)
	add_theme_color_override(&"font_disabled_color", tokens.text_muted)
	add_theme_font_size_override(&"font_size", int(tokens.font_body))
