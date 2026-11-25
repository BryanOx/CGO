class_name ItemTile
extends Button

signal tile_pressed(item_id: String)

var _item_id: String = ""
var _title_label: Label = Label.new()
var _detail_label: Label = Label.new()

func _init() -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	custom_minimum_size = Vector2(0.0, tokens.touch_target_min)
	add_theme_stylebox_override(
		&"normal", ThemeFactory.button_style(tokens, tokens.surface, tokens.surface_alt)
	)
	add_theme_color_override(&"font_color", tokens.text)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override(&"separation", int(tokens.space_xs))
	_title_label.add_theme_font_size_override(&"font_size", int(tokens.font_body))
	_detail_label.add_theme_font_size_override(&"font_size", int(tokens.font_caption))
	_detail_label.add_theme_color_override(&"font_color", tokens.text_muted)
	column.add_child(_title_label)
	column.add_child(_detail_label)
	add_child(column)
	pressed.connect(_on_pressed)

func set_item(item: Dictionary) -> void:
	_item_id = String(item.get("id", ""))
	_title_label.text = String(item.get("name", item.get("display_name", "")))
	var price: Variant = item.get("price", null)
	_detail_label.text = "" if price == null else "Price: %d" % int(price)

func _on_pressed() -> void:
	tile_pressed.emit(_item_id)
