extends SceneTree

# Headless parse sweep: load every GDScript under res:// and fail on parse errors.
# Run with: godot --headless --path client -s res://tools/check_parse.gd

const SKIPPED_DIRECTORIES: Array[String] = [".godot", "addons"]

var _failures: PackedStringArray = PackedStringArray()
var _checked_count: int = 0

func _init() -> void:
	_scan_directory("res://")
	if _failures.is_empty():
		print("Parse check: %d GDScript files loaded, 0 failures." % _checked_count)
		quit(0)
		return
	printerr("Parse check: %d GDScript files loaded, %d failures." % [_checked_count, _failures.size()])
	for failure: String in _failures:
		printerr("FAIL: %s" % failure)
	quit(1)

func _scan_directory(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null:
		printerr("Cannot open directory: %s" % path)
		_failures.append(path)
		return
	for folder: String in DirAccess.get_directories_at(path):
		if folder.begins_with(".") or folder in SKIPPED_DIRECTORIES:
			continue
		_scan_directory(path.path_join(folder) + "/")
	for file_name: String in DirAccess.get_files_at(path):
		if not file_name.ends_with(".gd"):
			continue
		var script_path: String = path.path_join(file_name)
		_checked_count += 1
		var loaded: Resource = ResourceLoader.load(script_path)
		if loaded == null:
			_failures.append(script_path)
