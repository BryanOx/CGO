extends TestCase

# AC-7: tokens are centralized and responsive breakpoints are shared.

func run() -> void:
	var tokens: DesignTokens = DesignTokens.new()
	expect(tokens.touch_target_min == 48.0, "touch target minimum should be 48 dp")
	expect(tokens.design_width == 360.0, "design width should be 360")
	expect(tokens.design_height == 800.0, "design height should be 800")
	expect(tokens.space_md == 16.0, "medium spacing should be 16")
	expect(tokens.radius_sm == 8.0, "small radius should be 8")
	expect(tokens.font_body == 16.0, "body font size should be 16")
	expect(tokens.font_display == 28.0, "display font size should be 28")

	var theme: Theme = ThemeFactory.build(tokens)
	expect(theme != null, "ThemeFactory should produce a Theme")
	expect(theme.has_stylebox("normal", "Button"), "theme should define a Button style")
	expect(theme.has_stylebox("panel", "PanelContainer"), "theme should define a PanelContainer style")
	expect(theme.has_color("font_color", "Label"), "theme should define a Label color")
	expect(theme.has_font_size("font_size", "Label"), "theme should define a Label font size")

	expect(Responsive.columns_for(360.0) == 1, "360 width should use one column")
	expect(Responsive.columns_for(600.0) == 2, "600 width should use two columns")
	expect(Responsive.columns_for(900.0) == 3, "900 width should use three columns")
