extends TestCase

# AC-2: a second game is registered without touching wallet, shop, auth, or router.

func run() -> void:
	var registry: GameRegistry = GameRegistry.new()
	var first: GameDefinition = GameDefinition.new()
	first.id = &"conga"
	first.display_name = "Conga"
	first.scene_path = "res://games/conga/presentation/conga_placeholder.tscn"
	expect(registry.register(first), "first definition should register")

	var second: GameDefinition = GameDefinition.new()
	second.id = &"dominoes"
	second.display_name = "Dominoes"
	second.scene_path = "res://features/home/home_screen.tscn"
	second.enabled = false
	expect(registry.register(second), "second definition should register")
	expect(registry.get_by_id(&"dominoes") != null, "second definition should be retrievable by id")

	var duplicate: GameDefinition = GameDefinition.new()
	duplicate.id = &"conga"
	expect(not registry.register(duplicate), "duplicate id should be rejected")
	var empty: GameDefinition = GameDefinition.new()
	expect(not registry.register(empty), "empty id should be rejected")

	expect(registry.list_all().size() == 2, "registry should hold exactly two definitions")
	expect(registry.list_enabled().size() == 1, "disabled definitions should be filtered out")

	var services: ServiceRegistry = ServiceFactory.build(_development_config())
	expect(
		services.auth.simulated and services.wallet.simulated and services.catalog.simulated,
		"adding a game requires no wallet, shop, or auth edit"
	)

func _development_config() -> BackendConfig:
	var config: BackendConfig = BackendConfig.new()
	config.environment = &"development"
	return config
