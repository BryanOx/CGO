extends FeatureScreen

var _game_id: StringName = &"conga"
var _host: VBoxContainer = null

func on_configured(payload: Dictionary) -> void:
	if payload.has("game_id"):
		_game_id = StringName(String(payload.get("game_id", "conga")))

func _ready() -> void:
	super._ready()
	var tokens: DesignTokens = DesignTokens.get_shared()
	var column: VBoxContainer = new_column()
	column.add_child(new_label("Leaderboard", tokens.font_display))
	column.add_child(new_label("Game: %s" % String(_game_id), tokens.font_caption, true))
	_host = new_column()
	_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_host)
	add_nav(column)
	safe_area.add_child(column)
	_load()

func _load() -> void:
	clear_children(_host)
	if context == null or context.services == null:
		add_empty(_host, "Leaderboard unavailable", "Services are not configured.", _load)
		return
	var response: ApiResponse = context.services.leaderboard.get_top(_game_id)
	if not response.ok:
		add_empty(
			_host,
			"Leaderboard unavailable",
			"Could not load ranks: %s" % response.error_code,
			_load
		)
		return
	var rows: Variant = response.data.get("rows", [])
	if not (rows is Array) or (rows as Array).is_empty():
		add_empty(_host, "No ranks yet", "No scores are recorded for this game.", _load)
		return
	for row: Dictionary in (rows as Array):
		_host.add_child(_row(row))

func _row(row: Dictionary) -> PanelContainer:
	var tokens: DesignTokens = DesignTokens.get_shared()
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", ThemeFactory.panel_style(tokens, tokens.surface))
	var line: HBoxContainer = new_row()
	var rank: Label = new_label("#%d" % int(row.get("rank", 0)), tokens.font_body)
	rank.custom_minimum_size = Vector2(tokens.touch_target_min, 0.0)
	var player: Label = new_label(String(row.get("player", "")), tokens.font_body)
	player.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var score: Label = new_label(str(int(row.get("score", 0))), tokens.font_body, true)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	line.add_child(rank)
	line.add_child(player)
	line.add_child(score)
	panel.add_child(line)
	return panel
