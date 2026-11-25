extends Node

const COSMETIC_DEFINITION_PATHS: Array[String] = [
	"res://assets/cosmetics/free/conga/decks/classic_red/manifest.tres",
]

@onready var app_context: AppContext = $AppContext
@onready var router: Router = $Router
@onready var screen_host: Node = $ScreenHost

func _ready() -> void:
	if router.screen_host == null:
		router.screen_host = screen_host
	var config: BackendConfig = _load_config()
	var services: ServiceRegistry = ServiceFactory.build(config)
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
	var theme: Theme = ThemeFactory.build(tokens)
	get_tree().root.theme = theme
	app_context.configure(config, services, games, theme)
	app_context.cosmetics = _build_cosmetic_catalog()
	var screen_map: Dictionary = {
		ScreenIds.SPLASH: "res://features/auth/splash_screen.tscn",
		ScreenIds.HOME: "res://features/home/home_screen.tscn",
		ScreenIds.CATALOG: "res://features/home/catalog_screen.tscn",
		ScreenIds.GAME_DETAIL: "res://features/home/game_detail_screen.tscn",
		ScreenIds.LEADERBOARD: "res://features/leaderboard/leaderboard_screen.tscn",
		ScreenIds.PROFILE: "res://features/profile/profile_screen.tscn",
		ScreenIds.WALLET: "res://features/wallet/wallet_screen.tscn",
		ScreenIds.SHOP: "res://features/shop/shop_screen.tscn",
		ScreenIds.INVENTORY: "res://features/inventory/inventory_screen.tscn",
		ScreenIds.SETTINGS: "res://features/settings/settings_screen.tscn",
	}
	router.configure(screen_map, app_context)
	router.replace(ScreenIds.SPLASH)

func _build_cosmetic_catalog() -> CosmeticCatalog:
	var definitions: Array[CosmeticDefinition] = []
	for path: String in COSMETIC_DEFINITION_PATHS:
		var definition: CosmeticDefinition = ResourceLoader.load(path) as CosmeticDefinition
		if definition != null:
			definitions.append(definition)
	return CosmeticCatalog.new(definitions)

func _load_config() -> BackendConfig:
	var config: BackendConfig = ResourceLoader.load("res://app/backend_config.tres") as BackendConfig
	if config == null:
		return BackendConfig.new()
	return config
