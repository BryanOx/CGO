extends FeatureScreen

var _filter: String = ""
var _filter_row: HBoxContainer = null
var _list_host: VBoxContainer = null

func _ready() -> void:
	super._ready()
	var tokens: DesignTokens = DesignTokens.get_shared()
	var column: VBoxContainer = new_column()
	column.add_child(new_label("Game catalog", tokens.font_display))
	_filter_row = new_row()
	column.add_child(_filter_row)
	_list_host = new_column()
	_list_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_list_host)
	add_nav(column)
	safe_area.add_child(column)
	_render_filters()
	_render_list()

func _render_filters() -> void:
	clear_children(_filter_row)
	var capabilities: Array[String] = []
	if context != null and context.games != null:
		for definition: GameDefinition in context.games.list_all():
			for capability: String in definition.capabilities:
				if not capabilities.has(capability):
					capabilities.append(capability)
	_filter_row.add_child(_filter_button("All", ""))
	for capability: String in capabilities:
		_filter_row.add_child(_filter_button(capability, capability))

func _filter_button(title: String, capability: String) -> AppButton:
	var variant: StringName = &"primary" if capability == _filter else &"secondary"
	var button: AppButton = new_button(title, variant)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_select_filter.bind(capability))
	return button

func _select_filter(capability: String) -> void:
	_filter = capability
	_render_filters()
	_render_list()

func _render_list() -> void:
	clear_children(_list_host)
	if context == null or context.games == null:
		add_empty(_list_host, "No games available", "The game registry is not configured.", _render_list)
		return
	var matched: int = 0
	for definition: GameDefinition in context.games.list_enabled():
		if not _matches_filter(definition):
			continue
		matched += 1
		_list_host.add_child(_game_card(definition))
	if matched == 0:
		add_empty(_list_host, "No games match", "Choose another capability filter.", _render_list)

func _matches_filter(definition: GameDefinition) -> bool:
	if _filter.is_empty():
		return true
	for capability: String in definition.capabilities:
		if capability == _filter:
			return true
	return false

func _game_card(definition: GameDefinition) -> AppCard:
	var tokens: DesignTokens = DesignTokens.get_shared()
	var card: AppCard = AppCard.new()
	card.content.add_child(new_label(definition.display_name, tokens.font_title))
	if not definition.description.is_empty():
		card.content.add_child(new_label(definition.description, tokens.font_caption, true))
	var open_button: AppButton = new_button("View game")
	open_button.pressed.connect(_on_game_pressed.bind(definition.id))
	card.content.add_child(open_button)
	return card

func _on_game_pressed(game_id: StringName) -> void:
	if router != null:
		router.navigate(ScreenIds.GAME_DETAIL, {"game_id": String(game_id)})
