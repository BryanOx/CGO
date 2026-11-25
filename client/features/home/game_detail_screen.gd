extends FeatureScreen

var _game_id: StringName = &""
var _host: VBoxContainer = null

func on_configured(payload: Dictionary) -> void:
	_game_id = StringName(String(payload.get("game_id", "")))

func _ready() -> void:
	super._ready()
	_host = new_column()
	safe_area.add_child(_host)
	_render()

func _render() -> void:
	clear_children(_host)
	if context == null or context.games == null:
		add_empty(_host, "Game unavailable", "The game registry is not configured.", _render)
		return
	var definition: GameDefinition = context.games.get_by_id(_game_id)
	if definition == null:
		add_empty(_host, "Game not found", "Unknown game id: %s" % String(_game_id), _render)
		return
	var tokens: DesignTokens = DesignTokens.get_shared()
	_host.add_child(new_label(definition.display_name, tokens.font_display))
	if not definition.description.is_empty():
		_host.add_child(new_label(definition.description, tokens.font_body))
	_add_local_preview(tokens)
	_host.add_child(new_label("Modes: %s" % _join(definition.modes), tokens.font_body))
	_host.add_child(new_label("Rules version: %s" % definition.rules_version, tokens.font_body, true))
	_host.add_child(new_label(
		"No playable rules are included in Phase 1. This screen is a navigation placeholder.",
		tokens.font_caption,
		true
	))
	var open_button: AppButton = new_button("Open")
	open_button.pressed.connect(_on_open_pressed.bind(definition))
	_host.add_child(open_button)

func _add_local_preview(tokens: DesignTokens) -> void:
	var cosmetic: CosmeticDefinition = _find_free_cosmetic()
	var texture: Texture2D = null
	if cosmetic != null and not cosmetic.preview.is_empty():
		texture = ResourceLoader.load(cosmetic.preview) as Texture2D
	if texture == null:
		_host.add_child(new_label("No local cosmetic preview available.", tokens.font_caption, true))
		return
	var preview: TextureRect = TextureRect.new()
	preview.texture = texture
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(96.0, 148.0)
	preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_host.add_child(preview)

func _find_free_cosmetic() -> CosmeticDefinition:
	if context == null or context.cosmetics == null:
		return null
	for definition: CosmeticDefinition in context.cosmetics.list_by_acquisition(CosmeticTiers.FREE):
		if not definition.enabled:
			continue
		for game_id: String in definition.compatible_game_ids:
			if StringName(game_id) == _game_id:
				return definition
	return null

func _join(values: PackedStringArray) -> String:
	if values.is_empty():
		return "none"
	return ", ".join(values)

func _on_open_pressed(definition: GameDefinition) -> void:
	if router != null:
		router.open_scene(definition.scene_path, {"game_id": String(definition.id)})
