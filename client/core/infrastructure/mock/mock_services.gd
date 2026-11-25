class_name MockServices
extends RefCounted

# Deterministic development adapters. No rewards, rules, or economy mutation.

const GUEST_ID: String = "guest-dev-0001"
const PROFILE_NAME: String = "Development Guest"
const BALANCE: int = 200

static func build(_config: BackendConfig) -> ServiceRegistry:
	return ServiceRegistry.new(
		MockAuthService.new(),
		MockProfileService.new(),
		MockCatalogService.new(),
		MockWalletService.new(),
		MockInventoryService.new(),
		MockLeaderboardService.new(),
		MockSettingsService.new(),
		MockApiClient.new(),
		MockRealtimeClient.new()
	)

class MockApiClient extends ApiClient:
	func _init() -> void:
		simulated = true

	func get_json(path: String, _query: Dictionary = {}) -> ApiResponse:
		var payload: Dictionary = _payload_for(path)
		if payload.is_empty():
			return ApiResponse.new(false, {}, "NOT_FOUND", 404)
		return ApiResponse.new(true, payload, "", 200)

	func post_json(path: String, payload: Dictionary, _idempotency_key: String = "") -> ApiResponse:
		var response: Dictionary = _payload_for(path)
		response["received"] = payload.duplicate(true)
		return ApiResponse.new(true, response, "", 200)

	func delete_json(_path: String) -> ApiResponse:
		return ApiResponse.new(true, {}, "", 200)

	func _payload_for(path: String) -> Dictionary:
		match path:
			"/profile":
				return {
					"id": GUEST_ID,
					"display_name": PROFILE_NAME,
					"level": 1,
				}
			"/balance":
				return {"balance": BALANCE, "currency": "coins"}
			_:
				return {}

class MockAuthService extends AuthService:
	func _init() -> void:
		simulated = true

	func start_guest_session() -> ApiResponse:
		return ApiResponse.new(true, {"user_id": GUEST_ID}, "", 200)

	func current_user_id() -> String:
		return GUEST_ID

class MockProfileService extends ProfileService:
	func _init() -> void:
		simulated = true

	func get_profile() -> ApiResponse:
		return ApiResponse.new(
			true,
			{"id": GUEST_ID, "display_name": PROFILE_NAME, "level": 1},
			"",
			200
		)

	func update_profile(patch: Dictionary) -> ApiResponse:
		var profile: Dictionary = {"id": GUEST_ID, "display_name": PROFILE_NAME, "level": 1}
		for key: Variant in patch.keys():
			profile[String(key)] = patch[key]
		return ApiResponse.new(true, profile, "", 200)

class MockCatalogService extends CatalogService:
	func _init() -> void:
		simulated = true

	func list_shop_items(game_filter: String = "") -> ApiResponse:
		var items: Array[Dictionary] = [
			{"id": "item-001", "name": "Table theme", "price": 50, "game_id": "common"},
			{"id": "item-002", "name": "Avatar frame", "price": 80, "game_id": "common"},
			{"id": "item-003", "name": "Card back", "price": 120, "game_id": "conga"},
		]
		if game_filter.is_empty():
			return ApiResponse.new(true, {"items": items}, "", 200)
		var filtered: Array[Dictionary] = []
		for item: Dictionary in items:
			if String(item.get("game_id", "")) == game_filter:
				filtered.append(item)
		return ApiResponse.new(true, {"items": filtered}, "", 200)

class MockWalletService extends WalletService:
	func _init() -> void:
		simulated = true

	func get_balance() -> ApiResponse:
		return ApiResponse.new(true, {"balance": BALANCE, "currency": "coins"}, "", 200)

class MockInventoryService extends InventoryService:
	func _init() -> void:
		simulated = true

	func list_items() -> ApiResponse:
		var items: Array[Dictionary] = [
			{"id": "item-001", "name": "Table theme", "equipped": false},
			{"id": "item-002", "name": "Avatar frame", "equipped": true},
		]
		return ApiResponse.new(true, {"items": items}, "", 200)

	func equip(item_id: String, slot: StringName) -> ApiResponse:
		if item_id.is_empty() or slot == &"":
			return ApiResponse.new(false, {}, "INVALID_REQUEST", 400)
		return ApiResponse.new(
			true,
			{"item_id": item_id, "slot": String(slot), "equipped": true},
			"",
			200
		)

class MockLeaderboardService extends LeaderboardService:
	func _init() -> void:
		simulated = true

	func get_top(game_id: StringName) -> ApiResponse:
		var rows: Array[Dictionary] = [
			{"rank": 1, "player": "player-a", "score": 300},
			{"rank": 2, "player": "player-b", "score": 250},
			{"rank": 3, "player": "player-c", "score": 200},
		]
		return ApiResponse.new(
			true,
			{"game_id": String(game_id), "rows": rows},
			"",
			200
		)

class MockSettingsService extends SettingsService:
	func _init() -> void:
		simulated = true

	func load_settings() -> Dictionary:
		return {
			"audio_enabled": true,
			"language": "en",
			"reduced_motion": false,
		}

	func save_settings(_settings: Dictionary) -> bool:
		return true

class MockRealtimeClient extends RealtimeClient:
	func _init() -> void:
		simulated = true

	func connect_to(_match_id: String, _last_seq: int) -> void:
		connection_state_changed.emit(&"connected")

	func send_action(_action: Dictionary) -> void:
		pass

	func resume(_match_id: String, _last_seq: int) -> void:
		connection_state_changed.emit(&"resumed")

	func close() -> void:
		connection_state_changed.emit(&"closed")
