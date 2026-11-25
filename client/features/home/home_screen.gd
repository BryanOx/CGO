extends FeatureScreen

var _content: VBoxContainer = null

func _ready() -> void:
	super._ready()
	_content = new_column()
	safe_area.add_child(_content)
	_render()

func _render() -> void:
	clear_children(_content)
	var tokens: DesignTokens = DesignTokens.get_shared()
	_content.add_child(new_label(_greeting(), tokens.font_display))
	_content.add_child(_balance_row())
	_content.add_child(new_label("Games", tokens.font_title))
	if context == null or context.games == null:
		add_empty(_content, "No games available", "The game registry is not configured.", _render)
		add_nav(_content)
		return
	var definitions: Array[GameDefinition] = context.games.list_enabled()
	if definitions.is_empty():
		add_empty(_content, "No games available", "No enabled game is registered.", _render)
	for definition: GameDefinition in definitions:
		_content.add_child(_game_card(definition))
	add_nav(_content)

func _greeting() -> String:
	if context == null or context.services == null:
		return "Welcome"
	var response: ApiResponse = context.services.profile.get_profile()
	if not response.ok:
		return "Welcome"
	return "Hello, %s" % String(response.data.get("display_name", "player"))

func _balance_row() -> HBoxContainer:
	var row: HBoxContainer = new_row()
	var pill: CurrencyPill = CurrencyPill.new()
	if context != null and context.services != null:
		var response: ApiResponse = context.services.wallet.get_balance()
		if response.ok:
			pill.set_amount(int(response.data.get("balance", 0)))
	row.add_child(pill)
	return row

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
