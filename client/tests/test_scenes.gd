extends TestCase

# AC-5: every main scene instantiates headless with a real configured context.

const SCREEN_PATHS: Array[String] = [
	"res://features/auth/splash_screen.tscn",
	"res://features/home/home_screen.tscn",
	"res://features/home/catalog_screen.tscn",
	"res://features/home/game_detail_screen.tscn",
	"res://features/leaderboard/leaderboard_screen.tscn",
	"res://features/profile/profile_screen.tscn",
	"res://features/wallet/wallet_screen.tscn",
	"res://features/shop/shop_screen.tscn",
	"res://features/inventory/inventory_screen.tscn",
	"res://features/settings/settings_screen.tscn",
	"res://games/conga/presentation/conga_placeholder.tscn",
]

func run() -> void:
	var config: BackendConfig = BackendConfig.new()
	config.environment = &"development"
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
	var context: AppContext = AppContext.new()
	context.configure(config, services, games, theme)
	var router: Router = Router.new()
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		expect(false, "tests must run inside a SceneTree")
		return
	for path: String in SCREEN_PATHS:
		_check_scene(path, router, context, tree.root)
	context.free()
	router.free()

func _check_scene(path: String, router: Router, context: AppContext, host: Node) -> void:
	var name: String = path.get_file().get_basename()
	var packed: PackedScene = ResourceLoader.load(path, "PackedScene") as PackedScene
	if packed == null:
		expect(false, "%s: cannot load PackedScene" % name)
		return
	var instance: Node = packed.instantiate()
	var screen: Screen = instance as Screen
	if screen == null:
		expect(false, "%s: instantiated node is not a Screen" % name)
		instance.free()
		return
	var payload: Dictionary = {}
	if name == "game_detail_screen":
		payload["game_id"] = "conga"
	screen.configure(router, context, payload)
	host.add_child(screen)
	var feature: FeatureScreen = screen as FeatureScreen
	if feature != null and feature.safe_area == null:
		screen.call(&"_ready")
	var controls: int = _count_controls(screen)
	expect(controls > 0, "%s: scene contains no Control nodes" % name)
	print("  scene: %s (%d controls)" % [name, controls])
	host.remove_child(screen)
	screen.free()

func _count_controls(node: Node) -> int:
	var count: int = 0
	if node is Control:
		count += 1
	for child: Node in node.get_children():
		count += _count_controls(child)
	return count
