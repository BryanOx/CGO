class_name ThemeFactory
extends RefCounted

static func build(tokens: DesignTokens) -> Theme:
	var source: DesignTokens = tokens if tokens != null else DesignTokens.get_shared()
	var theme: Theme = Theme.new()
	theme.set_stylebox("normal", "Button", button_style(source, source.primary, source.primary))
	theme.set_stylebox(
		"hover", "Button", button_style(source, source.primary.lightened(0.08), source.primary)
	)
	theme.set_stylebox(
		"pressed", "Button", button_style(source, source.primary.darkened(0.08), source.primary)
	)
	theme.set_stylebox(
		"disabled", "Button", button_style(source, source.surface_alt, source.text_muted)
	)
	theme.set_color("font_color", "Button", source.on_primary)
	theme.set_color("font_disabled_color", "Button", source.text_muted)
	theme.set_font_size("font_size", "Button", int(source.font_body))
	theme.set_stylebox("panel", "PanelContainer", panel_style(source, source.surface))
	theme.set_stylebox("panel", "Panel", panel_style(source, source.surface))
	theme.set_color("font_color", "Label", source.text)
	theme.set_font_size("font_size", "Label", int(source.font_body))
	theme.set_color("font_color", "LineEdit", source.text)
	theme.set_font_size("font_size", "LineEdit", int(source.font_body))
	theme.set_constant("separation", "HSeparator", int(source.space_md))
	theme.set_constant("separation", "VSeparator", int(source.space_md))
	return theme

static func button_style(tokens: DesignTokens, fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(int(tokens.radius_sm))
	style.set_content_margin_all(int(tokens.space_sm))
	return style

static func panel_style(tokens: DesignTokens, fill: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.set_corner_radius_all(int(tokens.radius_md))
	style.set_content_margin_all(int(tokens.space_md))
	return style
