extends FeatureScreen

const EQUIP_MESSAGE: String = "Equipping requires the Phase 4 backend. Inventory state was not changed."

var _host: VBoxContainer = null
var _modal: AppModal = null

func _ready() -> void:
	super._ready()
	var tokens: DesignTokens = DesignTokens.get_shared()
	var column: VBoxContainer = new_column()
	column.add_child(new_label("Inventory", tokens.font_display))
	_host = new_column()
	_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_host)
	add_nav(column)
	safe_area.add_child(column)
	_modal = add_modal()
	_load()

func _load() -> void:
	clear_children(_host)
	if context == null or context.services == null:
		add_empty(_host, "Inventory unavailable", "Services are not configured.", _load)
		return
	var response: ApiResponse = context.services.inventory.list_items()
	if not response.ok:
		add_empty(
			_host,
			"Inventory unavailable",
			"Could not load items: %s" % response.error_code,
			_load
		)
		return
	var items: Variant = response.data.get("items", [])
	if not (items is Array) or (items as Array).is_empty():
		add_empty(_host, "Nothing owned", "No inventory items are recorded.", _load)
		return
	for item: Dictionary in (items as Array):
		_host.add_child(_item_row(item))

func _item_row(item: Dictionary) -> PanelContainer:
	var tokens: DesignTokens = DesignTokens.get_shared()
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", ThemeFactory.panel_style(tokens, tokens.surface))
	var column: VBoxContainer = new_column(tokens.space_xs)
	var tile: ItemTile = ItemTile.new()
	tile.set_item(item)
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.tile_pressed.connect(_on_equip_pressed)
	column.add_child(tile)
	var state: String = "Equipped" if bool(item.get("equipped", false)) else "Owned, not equipped"
	column.add_child(new_label(state, tokens.font_caption, true))
	var equip: AppButton = new_button("Equip", &"secondary")
	equip.pressed.connect(_on_equip_pressed.bind(String(item.get("id", ""))))
	column.add_child(equip)
	panel.add_child(column)
	return panel

func _on_equip_pressed(_item_id: String) -> void:
	if _modal != null:
		_modal.show_modal("Equip unavailable", EQUIP_MESSAGE)
