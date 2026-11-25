class_name DesignTokens
extends Resource

@export var background: Color = Color(0.06, 0.07, 0.10, 1.0)
@export var surface: Color = Color(0.11, 0.13, 0.18, 1.0)
@export var surface_alt: Color = Color(0.16, 0.19, 0.26, 1.0)
@export var primary: Color = Color(0.25, 0.55, 0.95, 1.0)
@export var on_primary: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var text: Color = Color(0.94, 0.95, 0.98, 1.0)
@export var text_muted: Color = Color(0.65, 0.68, 0.75, 1.0)
@export var danger: Color = Color(0.90, 0.28, 0.32, 1.0)
@export var success: Color = Color(0.20, 0.72, 0.45, 1.0)

@export var space_xs: float = 4.0
@export var space_sm: float = 8.0
@export var space_md: float = 16.0
@export var space_lg: float = 24.0
@export var radius_sm: float = 8.0
@export var radius_md: float = 12.0
@export var touch_target_min: float = 48.0
@export var font_caption: float = 12.0
@export var font_body: float = 16.0
@export var font_title: float = 20.0
@export var font_display: float = 28.0
@export var toast_duration_seconds: float = 3.0

@export var design_width: float = 360.0
@export var design_height: float = 800.0

static var _shared: DesignTokens = null

static func get_shared() -> DesignTokens:
	if _shared == null:
		var loaded: Resource = ResourceLoader.load("res://shared/theme/design_tokens.tres")
		if loaded is DesignTokens:
			_shared = loaded as DesignTokens
		else:
			_shared = DesignTokens.new()
	return _shared

static func set_shared(tokens: DesignTokens) -> void:
	if tokens != null:
		_shared = tokens
