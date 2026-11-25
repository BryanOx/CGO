extends TestCase

# Development mock shapes are observable without any economy mutation.

func run() -> void:
	var config: BackendConfig = BackendConfig.new()
	config.environment = &"development"
	var services: ServiceRegistry = ServiceFactory.build(config)

	var guest: ApiResponse = services.auth.start_guest_session()
	expect(guest.ok, "guest session response should be ok")
	expect(
		String(guest.data.get("user_id", "")) == MockServices.GUEST_ID,
		"guest session should return the deterministic guest id"
	)

	var balance: ApiResponse = services.wallet.get_balance()
	expect(balance.ok, "balance response should be ok")
	expect(
		int(balance.data.get("balance", -1)) == MockServices.BALANCE,
		"mock balance should be 200"
	)

	var shop: ApiResponse = services.catalog.list_shop_items()
	var shop_items: Variant = shop.data.get("items", [])
	expect(shop.ok and shop_items is Array, "shop response should carry an item array")
	expect((shop_items as Array).size() == 3, "shop should expose three items")

	var inventory: ApiResponse = services.inventory.list_items()
	var owned_items: Variant = inventory.data.get("items", [])
	expect(inventory.ok and owned_items is Array, "inventory response should carry an item array")
	expect((owned_items as Array).size() == 2, "inventory should expose two items")

	var leaderboard: ApiResponse = services.leaderboard.get_top(&"conga")
	var rows: Variant = leaderboard.data.get("rows", [])
	expect(leaderboard.ok and rows is Array, "leaderboard response should carry a row array")
	expect((rows as Array).size() == 3, "leaderboard should expose three rows")

	var mock_services: ServiceRegistry = MockServices.build(config)
	var defaults: Dictionary = mock_services.settings.load_settings()
	expect(bool(defaults.get("audio_enabled", false)), "audio should default to enabled")
	expect(String(defaults.get("language", "")) == "en", "language should default to en")
	expect(not bool(defaults.get("reduced_motion", true)), "reduced motion should default to off")
	expect(services.wallet.simulated, "mock balance is simulated data only")
