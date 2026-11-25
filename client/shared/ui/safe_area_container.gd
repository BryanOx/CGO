class_name SafeAreaContainer
extends MarginContainer

func _ready() -> void:
	_apply_safe_area()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_safe_area()

func _apply_safe_area() -> void:
	var safe: Rect2 = DisplayServer.get_display_safe_area()
	var viewport: Vector2 = get_viewport_rect().size
	var left: float = maxf(0.0, safe.position.x)
	var top: float = maxf(0.0, safe.position.y)
	var right: float = maxf(0.0, viewport.x - safe.position.x - safe.size.x)
	var bottom: float = maxf(0.0, viewport.y - safe.position.y - safe.size.y)
	var max_horizontal: float = viewport.x * 0.5 if viewport.x > 0.0 else 0.0
	var max_vertical: float = viewport.y * 0.5 if viewport.y > 0.0 else 0.0
	add_theme_constant_override("margin_left", int(clampf(left, 0.0, max_horizontal)))
	add_theme_constant_override("margin_top", int(clampf(top, 0.0, max_vertical)))
	add_theme_constant_override("margin_right", int(clampf(right, 0.0, max_horizontal)))
	add_theme_constant_override("margin_bottom", int(clampf(bottom, 0.0, max_vertical)))
