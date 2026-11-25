extends Node

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
	var theme: Theme = Theme.new()
	app_context.configure(config, services, games, theme)
	var screen_map: Dictionary = {
		ScreenIds.SPLASH: "res://games/conga/presentation/conga_placeholder.tscn"
	}
	router.configure(screen_map, app_context)
	router.replace(ScreenIds.SPLASH)

func _load_config() -> BackendConfig:
	var config: BackendConfig = ResourceLoader.load("res://app/backend_config.tres") as BackendConfig
	if config == null:
		return BackendConfig.new()
	return config
