class_name BottomNav
extends MarginContainer

signal tab_selected(tab_id: StringName)

const TAB_IDS: Array[StringName] = [&"games", &"ranking", &"shop", &"profile"]
const TAB_TITLES: Array[String] = ["Games", "Ranking", "Shop", "Profile"]

var _buttons: Dictionary = {}
var _active_tab: StringName = &"games"

func _init() -> void:
	var tokens: DesignTokens = DesignTokens.get_shared()
	add_theme_constant_override(&"margin_top", int(tokens.space_sm))
	add_theme_constant_override(&"margin_bottom", int(tokens.space_sm))
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override(&"separation", int(tokens.space_sm))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	for index: int in range(TAB_IDS.size()):
		var tab_id: StringName = TAB_IDS[index]
		var button: AppButton = AppButton.new()
		button.text = TAB_TITLES[index]
		button.custom_minimum_size = Vector2(tokens.touch_target_min * 2.0, tokens.touch_target_min)
		button.pressed.connect(_on_tab_pressed.bind(tab_id))
		_buttons[tab_id] = button
		row.add_child(button)
	add_child(row)
	set_active(&"games")

func set_active(tab_id: StringName) -> void:
	_active_tab = tab_id
	for key: Variant in _buttons.keys():
		var button: AppButton = _buttons[key] as AppButton
		if button == null:
			continue
		var variant: StringName = &"primary" if key == tab_id else &"secondary"
		button.set_variant(variant)

func active_tab() -> StringName:
	return _active_tab

static func screen_for_tab(tab_id: StringName) -> StringName:
	match tab_id:
		&"games":
			return ScreenIds.CATALOG
		&"ranking":
			return ScreenIds.LEADERBOARD
		&"shop":
			return ScreenIds.SHOP
		&"profile":
			return ScreenIds.PROFILE
	return ScreenIds.HOME

func _on_tab_pressed(tab_id: StringName) -> void:
	set_active(tab_id)
	tab_selected.emit(tab_id)
