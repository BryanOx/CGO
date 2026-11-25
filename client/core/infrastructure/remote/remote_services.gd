class_name RemoteServices
extends RefCounted

static func build(config: BackendConfig) -> ServiceRegistry:
	var api: RemoteApiClient = RemoteApiClient.new(config)
	return ServiceRegistry.new(
		RemoteAuthService.new(api),
		RemoteProfileService.new(api),
		RemoteCatalogService.new(api),
		RemoteWalletService.new(api),
		RemoteInventoryService.new(api),
		RemoteLeaderboardService.new(api),
		LocalSettingsService.new(),
		api,
		RemoteRealtimeClient.new()
	)

class RemoteAuthService extends AuthService:
	var _api: ApiClient

	func _init(p_api: ApiClient) -> void:
		_api = p_api
		simulated = false

	func start_guest_session() -> ApiResponse:
		return _api.post_json("/auth/guest", {})

	func current_user_id() -> String:
		assert(false, "Implement current_user_id in the Phase 3 auth adapter")
		return ""

class RemoteProfileService extends ProfileService:
	var _api: ApiClient

	func _init(p_api: ApiClient) -> void:
		_api = p_api
		simulated = false

	func get_profile() -> ApiResponse:
		return _api.get_json("/profile")

	func update_profile(patch: Dictionary) -> ApiResponse:
		return _api.post_json("/profile", patch)

class RemoteCatalogService extends CatalogService:
	var _api: ApiClient

	func _init(p_api: ApiClient) -> void:
		_api = p_api
		simulated = false

	func list_shop_items(game_filter: String = "") -> ApiResponse:
		if game_filter.is_empty():
			return _api.get_json("/catalog/items")
		return _api.get_json("/catalog/items", {"game_id": game_filter})

class RemoteWalletService extends WalletService:
	var _api: ApiClient

	func _init(p_api: ApiClient) -> void:
		_api = p_api
		simulated = false

	func get_balance() -> ApiResponse:
		return _api.get_json("/wallet/balance")

class RemoteInventoryService extends InventoryService:
	var _api: ApiClient

	func _init(p_api: ApiClient) -> void:
		_api = p_api
		simulated = false

	func list_items() -> ApiResponse:
		return _api.get_json("/inventory/items")

	func equip(item_id: String, slot: StringName) -> ApiResponse:
		return _api.post_json("/inventory/equip", {
			"item_id": item_id,
			"slot": String(slot),
		}, "")

class RemoteLeaderboardService extends LeaderboardService:
	var _api: ApiClient

	func _init(p_api: ApiClient) -> void:
		_api = p_api
		simulated = false

	func get_top(game_id: StringName) -> ApiResponse:
		return _api.get_json("/leaderboard/top", {"game_id": String(game_id)})

class RemoteRealtimeClient extends RealtimeClient:
	func _init() -> void:
		simulated = false

	# Match transport is Phase 3 work; this adapter stays fail-explicit.
	func connect_to(_match_id: String, _last_seq: int) -> void:
		assert(false, "Implement connect_to in the Phase 3 WebSocket adapter")

	func send_action(_action: Dictionary) -> void:
		assert(false, "Implement send_action in the Phase 3 WebSocket adapter")

	func resume(_match_id: String, _last_seq: int) -> void:
		assert(false, "Implement resume in the Phase 3 WebSocket adapter")

	func close() -> void:
		assert(false, "Implement close in the Phase 3 WebSocket adapter")
