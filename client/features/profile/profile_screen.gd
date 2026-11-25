extends FeatureScreen

func _ready() -> void:
	super._ready()
	var tokens: DesignTokens = DesignTokens.get_shared()
	var column: VBoxContainer = new_column()
	column.add_child(new_label("Profile", tokens.font_display))
	var response: ApiResponse = ApiResponse.new(false, {}, "NO_SERVICES", 0)
	if context != null and context.services != null:
		response = context.services.profile.get_profile()
	if not response.ok:
		column.add_child(new_label("Profile data is unavailable.", tokens.font_body, true))
	else:
		column.add_child(new_label(
			String(response.data.get("display_name", "Unknown player")),
			tokens.font_title
		))
		column.add_child(new_label("Level: %d" % int(response.data.get("level", 0)), tokens.font_body))
		column.add_child(new_label("Id: %s" % String(response.data.get("id", "")), tokens.font_caption, true))
	column.add_child(_navigation_button("Wallet", ScreenIds.WALLET))
	column.add_child(_navigation_button("Inventory", ScreenIds.INVENTORY))
	column.add_child(_navigation_button("Settings", ScreenIds.SETTINGS))
	add_nav(column)
	safe_area.add_child(column)

func _navigation_button(title: String, screen_id: StringName) -> AppButton:
	var button: AppButton = new_button(title)
	button.pressed.connect(_on_navigate.bind(screen_id))
	return button

func _on_navigate(screen_id: StringName) -> void:
	if router != null:
		router.navigate(screen_id)
