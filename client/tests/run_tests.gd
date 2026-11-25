extends SceneTree

# In-repo headless runner. No external framework.
# Run with: godot --headless --path client -s res://tests/run_tests.gd

const TEST_SCRIPTS: Array[String] = [
	"res://tests/test_game_registry.gd",
	"res://tests/test_backend_config.gd",
	"res://tests/test_service_factory.gd",
	"res://tests/test_mock_services.gd",
	"res://tests/test_design_system.gd",
	"res://tests/test_scenes.gd",
	"res://tests/test_cosmetic_catalog.gd",
	"res://tests/test_asset_licenses.gd",
]

func _initialize() -> void:
	var passed: int = 0
	var failed: int = 0
	for path: String in TEST_SCRIPTS:
		var name: String = path.get_file().get_basename()
		var script: GDScript = ResourceLoader.load(path) as GDScript
		if script == null:
			print("[FAIL] %s: cannot load test script" % name)
			failed += 1
			continue
		var case: TestCase = script.new() as TestCase
		if case == null:
			print("[FAIL] %s: script does not extend TestCase" % name)
			failed += 1
			continue
		case.run()
		if case.failures.is_empty():
			print("[PASS] %s" % name)
			passed += 1
		else:
			print("[FAIL] %s" % name)
			for failure: String in case.failures:
				print("  - %s" % failure)
			failed += 1
	print("Tests: %d passed, %d failed." % [passed, failed])
	quit(1 if failed > 0 else 0)
