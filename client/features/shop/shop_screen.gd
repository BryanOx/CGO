extends FeatureScreen

const PURCHASE_MESSAGE: String = "Purchases require the Phase 4 backend. No wallet balance was changed."

var _items: Array[Dictionary] = []
var _filter: String = ""
var _filter_row: HBoxContainer = null
var _list_host: VBoxContainer = null
var _modal: AppModal = null

func _ready() -> void:
	super._ready()
	var tokens: DesignTokens = DesignTokens.get_shared()
	var column: VBoxContainer = new_column()
	column.add_child(new_label("Shop", tokens.font_display))
	_filter_row = new_row()
	column.add_child(_filter_row)
	_list_host = new_column()
	_list_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_list_host)
	add_nav(column)
	safe_area.add_child(column)
	_modal = add_modal()
	_load()

func _load() -> void:
	_items.clear()
	if context != null and context.services != null:
		var response: ApiResponse = context.services.catalog.list_shop_items()
		if response.ok:
			var items: Variant = response.data.get("items", [])
			if items is Array:
				for item: Dictionary in (items as Array):
					_items.append(item)
	_filter = ""
	_render_filters()
	_render_items()
	if _items.is_empty() and context != null and context.services != null:
		add_empty(_list_host, "Shop unavailable", "No items could be loaded.", _load)

func _render_filters() -> void:
	clear_children(_filter_row)
	var game_ids: Array[String] = []
	for item: Dictionary in _items:
		var game_id: String = String(item.get("game_id", ""))
		if not game_id.is_empty() and not game_ids.has(game_id):
			game_ids.append(game_id)
	_filter_row.add_child(_filter_button("All", ""))
	for game_id: String in game_ids:
		_filter_row.add_child(_filter_button(game_id, game_id))

func _filter_button(title: String, game_id: String) -> AppButton:
	var variant: StringName = &"primary" if game_id == _filter else &"secondary"
	var button: AppButton = new_button(title, variant)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_select_filter.bind(game_id))
	return button

func _select_filter(game_id: String) -> void:
	_filter = game_id
	_render_filters()
	_render_items()

func _render_items() -> void:
	clear_children(_list_host)
	var matched: int = 0
	for item: Dictionary in _items:
		if not _filter.is_empty() and String(item.get("game_id", "")) != _filter:
			continue
		matched += 1
		_list_host.add_child(_item_row(item))
	if matched == 0 and not _items.is_empty():
		add_empty(_list_host, "No items", "No items match this filter.", _render_items)

func _item_row(item: Dictionary) -> HBoxContainer:
	var row: HBoxContainer = new_row()
	# Price and availability still come from the service port; the local catalog
	# lookup below only resolves a visual preview for this stable item ID.
	var definition: CosmeticDefinition = null
	if context != null and context.cosmetics != null:
		definition = context.cosmetics.get_by_item_id(String(item.get("id", "")))
	var preview: TextureRect = _preview_for(definition)
	if preview != null:
		row.add_child(preview)
	var tile: ItemTile = ItemTile.new()
	tile.set_item(item)
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.tile_pressed.connect(_on_tile_pressed)
	row.add_child(tile)
	var buy: AppButton = new_button("Buy")
	buy.custom_minimum_size = Vector2(DesignTokens.get_shared().touch_target_min, DesignTokens.get_shared().touch_target_min)
	buy.pressed.connect(_on_buy_pressed)
	row.add_child(buy)
	return row

func _preview_for(definition: CosmeticDefinition) -> TextureRect:
	if definition == null or definition.preview.is_empty():
		return null
	var texture: Texture2D = ResourceLoader.load(definition.preview) as Texture2D
	if texture == null:
		return null
	var preview: TextureRect = TextureRect.new()
	preview.texture = texture
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(64.0, 99.0)
	preview.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return preview

func _show_purchase_notice() -> void:
	if _modal != null:
		_modal.show_modal("Purchase unavailable", PURCHASE_MESSAGE)

func _on_buy_pressed() -> void:
	_show_purchase_notice()

func _on_tile_pressed(_item_id: String) -> void:
	_show_purchase_notice()
