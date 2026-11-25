class_name FeatureScreen
extends Screen

# Screen owns configuration and navigation state but defines no _ready() hook.
# This presentation base supplies that hook so feature screens share root layout
# setup and can call super._ready() without editing the application contract.

var safe_area: SafeAreaContainer = null

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	safe_area = SafeAreaContainer.new()
	safe_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(safe_area)

func new_column(gap: float = -1.0) -> VBoxContainer:
	var tokens: DesignTokens = DesignTokens.get_shared()
	var column: VBoxContainer = VBoxContainer.new()
	var separation: float = tokens.space_md if gap < 0.0 else gap
	column.add_theme_constant_override(&"separation", int(separation))
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return column

func new_row(gap: float = -1.0) -> HBoxContainer:
	var tokens: DesignTokens = DesignTokens.get_shared()
	var row: HBoxContainer = HBoxContainer.new()
	var separation: float = tokens.space_sm if gap < 0.0 else gap
	row.add_theme_constant_override(&"separation", int(separation))
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return row

func new_label(text_value: String, font_size: float, muted: bool = false) -> Label:
	var tokens: DesignTokens = DesignTokens.get_shared()
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_size_override(&"font_size", int(font_size))
	label.add_theme_color_override(&"font_color", tokens.text_muted if muted else tokens.text)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func new_button(text_value: String, variant: StringName = &"primary") -> AppButton:
	var tokens: DesignTokens = DesignTokens.get_shared()
	var button: AppButton = AppButton.new()
	button.text = text_value
	button.set_variant(variant)
	button.custom_minimum_size = Vector2(tokens.touch_target_min, tokens.touch_target_min)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button

func add_nav(host: Node) -> BottomNav:
	var nav: BottomNav = BottomNav.new()
	nav.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.tab_selected.connect(_on_nav_tab_selected)
	host.add_child(nav)
	return nav

func add_modal() -> AppModal:
	var modal: AppModal = AppModal.new()
	add_child(modal)
	return modal

func clear_children(host: Node) -> void:
	for child: Node in host.get_children():
		host.remove_child(child)
		child.free()

func add_empty(host: Node, title: String, detail: String, retry: Callable = Callable()) -> EmptyState:
	var empty_state: EmptyState = EmptyState.new()
	empty_state.set_message(title, detail)
	empty_state.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if retry.is_valid():
		empty_state.action_pressed.connect(retry)
	host.add_child(empty_state)
	return empty_state

func _on_nav_tab_selected(tab_id: StringName) -> void:
	if router != null:
		router.navigate(BottomNav.screen_for_tab(tab_id))
