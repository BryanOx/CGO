class_name AppCard
extends PanelContainer

var content: VBoxContainer = VBoxContainer.new()

func _init() -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	add_theme_stylebox_override(&"panel", ThemeFactory.panel_style(tokens, tokens.surface))
	content.add_theme_constant_override(&"separation", int(tokens.space_sm))
	add_child(content)
