extends FeatureScreen

# Guest session only: this screen never grants currency or inventory.

var _status_host: VBoxContainer = null
var _session_timer: Timer = Timer.new()

func _ready() -> void:
	super._ready()
	_session_timer.one_shot = true
	_session_timer.wait_time = 0.4
	_session_timer.timeout.connect(_on_session_timeout)
	add_child(_session_timer)
	var tokens: DesignTokens = DesignTokens.get_shared()
	var column: VBoxContainer = new_column()
	column.add_child(new_label("Classic Games Online", tokens.font_display))
	_status_host = new_column()
	_status_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_status_host)
	safe_area.add_child(column)
	_start_session()

func _start_session() -> void:
	clear_children(_status_host)
	var loading: LoadingState = LoadingState.new()
	_status_host.add_child(loading)
	if context == null or context.services == null:
		_show_failure("Services are unavailable. Try again.")
		return
	var response: ApiResponse = context.services.auth.start_guest_session()
	if not response.ok:
		_show_failure("Guest session failed: %s" % response.error_code)
		return
	loading.set_active(true)
	if _session_timer.is_inside_tree():
		_session_timer.start()
	else:
		_session_timer.autostart = true

func _show_failure(detail: String) -> void:
	clear_children(_status_host)
	add_empty(_status_host, "Session unavailable", detail, _retry_session)

func _retry_session() -> void:
	_start_session()

func _on_session_timeout() -> void:
	if router != null:
		router.replace(ScreenIds.HOME)
