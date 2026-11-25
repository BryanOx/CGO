extends TestCase

# AC-4, AC-5, AC-6: stable IDs, all three acquisition tiers, fallback
# resolution, resource values, and local previews in both screens.

const DEFINITION_PATH: String = "res://assets/cosmetics/free/conga/decks/classic_red/manifest.tres"
const PREVIEW_PATH: String = "res://assets/cards/conga/classic_red/cards/back.png"
const ATTRIBUTION_PATH: String = "res://assets/cards/conga/classic_red/attribution.txt"

class PreviewCatalogService extends CatalogService:
	func list_shop_items(_game_filter: String = "") -> ApiResponse:
		var items: Array[Dictionary] = [
			{"id": "conga_deck_classic_red", "name": "Card back", "price": 120, "game_id": "conga"}
		]
		return ApiResponse.new(true, {"items": items}, "", 200)

func run() -> void:
	_check_resource()
	_check_catalog()
	_check_scene_previews()

func _check_resource() -> void:
	var definition: CosmeticDefinition = ResourceLoader.load(DEFINITION_PATH) as CosmeticDefinition
	expect(definition != null, "manifest.tres should load as CosmeticDefinition")
	if definition == null:
		return
	expect(String(definition.item_id) == "conga_deck_classic_red", "stable item_id should match")
	expect(definition.category == "deck", "category should be deck")
	expect(definition.compatible_game_ids.size() == 1, "exactly one compatible game")
	expect(definition.compatible_game_ids[0] == "conga", "compatible game should be conga")
	expect(definition.slot == "deck", "slot should be deck")
	expect(definition.preview == PREVIEW_PATH, "preview should point to the local card back")
	expect(String(definition.asset_key) == "conga.cards.classic_red", "asset_key should match")
	expect(String(definition.fallback_key) == "conga.cards.default", "fallback_key should match")
	expect(String(definition.acquisition) == String(CosmeticTiers.FREE), "acquisition should be free")
	expect(String(definition.license_id) == "cc-by-sa-3.0", "license_id should match")
	expect(definition.attribution_ref == ATTRIBUTION_PATH, "attribution_ref should point to attribution.txt")
	expect(definition.enabled, "definition should be enabled")

func _check_catalog() -> void:
	var definition: CosmeticDefinition = ResourceLoader.load(DEFINITION_PATH) as CosmeticDefinition
	expect(definition != null, "catalog fixture definition should load")
	if definition == null:
		return
	var catalog: CosmeticCatalog = CosmeticCatalog.new([definition])
	var empty: CosmeticDefinition = CosmeticDefinition.new()
	expect(not catalog.register(empty), "empty item_id should be rejected")
	var duplicate: CosmeticDefinition = CosmeticDefinition.new()
	duplicate.item_id = definition.item_id
	expect(not catalog.register(duplicate), "duplicate item_id should be rejected")

	var paid: CosmeticDefinition = CosmeticDefinition.new()
	paid.item_id = &"paid_deck_test"
	paid.acquisition = CosmeticTiers.PAID
	var ad_reward: CosmeticDefinition = CosmeticDefinition.new()
	ad_reward.item_id = &"ad_reward_deck_test"
	ad_reward.acquisition = CosmeticTiers.AD_REWARD
	expect(catalog.register(paid), "paid tier definition should register")
	expect(catalog.register(ad_reward), "ad_reward tier definition should register")
	expect(catalog.list_by_acquisition(CosmeticTiers.FREE).size() == 1, "one free definition")
	expect(catalog.list_by_acquisition(CosmeticTiers.PAID).size() == 1, "one paid definition")
	expect(catalog.list_by_acquisition(CosmeticTiers.AD_REWARD).size() == 1, "one ad_reward definition")
	expect(catalog.get_by_item_id(&"missing") == null, "unknown item_id should return null")

	expect(
		catalog.resolve_asset(&"conga.cards.classic_red") == PREVIEW_PATH,
		"asset key should resolve to the local preview"
	)
	var fallback: CosmeticDefinition = CosmeticDefinition.new()
	fallback.item_id = &"conga.cards.default"
	fallback.asset_key = &"conga.cards.default"
	fallback.preview = "res://fallback_preview.png"
	var broken: CosmeticDefinition = CosmeticDefinition.new()
	broken.item_id = &"broken_preview_test"
	broken.asset_key = &"conga.cards.broken"
	broken.fallback_key = &"conga.cards.default"
	expect(catalog.register(fallback), "fallback definition should register")
	expect(catalog.register(broken), "definition with empty preview should register")
	expect(catalog.resolve_asset(&"conga.cards.broken") == fallback.preview, "missing preview should use fallback")
	expect(catalog.resolve_asset(&"conga.cards.unknown").is_empty(), "unknown asset key should resolve empty")

func _check_scene_previews() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		expect(false, "tests must run inside a SceneTree")
		return
	var config: BackendConfig = BackendConfig.new()
	config.environment = &"development"
	var services: ServiceRegistry = ServiceFactory.build(config)
	services.catalog = PreviewCatalogService.new()
	var games: GameRegistry = GameRegistry.new()
	var conga: GameDefinition = ResourceLoader.load(
		"res://games/conga/content/conga_definition.tres"
	) as GameDefinition
	if conga != null:
		games.register(conga)
	var tokens: DesignTokens = ResourceLoader.load(
		"res://shared/theme/design_tokens.tres"
	) as DesignTokens
	if tokens == null:
		tokens = DesignTokens.new()
	DesignTokens.set_shared(tokens)
	var definition: CosmeticDefinition = ResourceLoader.load(DEFINITION_PATH) as CosmeticDefinition
	var context: AppContext = AppContext.new()
	context.configure(config, services, games, ThemeFactory.build(tokens))
	context.cosmetics = CosmeticCatalog.new([definition])
	var router: Router = Router.new()

	var shop: Screen = _instantiate(
		"res://features/shop/shop_screen.tscn", router, context, {}, tree
	)
	expect(_count_previews(shop) == 1, "shop should show one textured cosmetic preview")
	_release(shop, tree)

	var detail: Screen = _instantiate(
		"res://features/home/game_detail_screen.tscn",
		router,
		context,
		{"game_id": "conga"},
		tree
	)
	expect(_count_previews(detail) == 1, "game detail should show one textured cosmetic preview")
	_release(detail, tree)
	context.free()
	router.free()

func _instantiate(
	path: String,
	router: Router,
	context: AppContext,
	payload: Dictionary,
	tree: SceneTree
) -> Screen:
	var packed: PackedScene = ResourceLoader.load(path, "PackedScene") as PackedScene
	if packed == null:
		expect(false, "cannot load %s" % path)
		return null
	var screen: Screen = packed.instantiate() as Screen
	if screen == null:
		expect(false, "%s is not a Screen" % path)
		return null
	screen.configure(router, context, payload)
	tree.root.add_child(screen)
	var feature: FeatureScreen = screen as FeatureScreen
	if feature != null and feature.safe_area == null:
		screen.call(&"_ready")
	return screen

func _release(screen: Screen, tree: SceneTree) -> void:
	if screen == null:
		return
	tree.root.remove_child(screen)
	screen.free()

func _count_previews(node: Node) -> int:
	if node == null:
		return 0
	var count: int = 0
	if node is TextureRect and (node as TextureRect).texture != null:
		count += 1
	for child: Node in node.get_children():
		count += _count_previews(child)
	return count
