extends SceneTree

# Headless parse sweep: run Godot's --check-only on every GDScript under res://.
# Run with: godot --headless --path client -s res://tools/check_parse.gd

const SKIPPED_DIRECTORIES: Array[String] = ["addons"]

var _failures: PackedStringArray = PackedStringArray()
var _checked_count: int = 0
var _executable: String = ""
var _project_path: String = ""

func _init() -> void:
	_executable = OS.get_executable_path()
	_project_path = ProjectSettings.globalize_path("res://").trim_suffix("/")
	_scan_directory("res://")
	if _failures.is_empty():
		print("Parse check: %d GDScript files checked, 0 failures." % _checked_count)
		quit(0)
		return
	printerr("Parse check: %d GDScript files checked, %d failures." % [_checked_count, _failures.size()])
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
		if script_path == "res://tools/check_parse.gd":
			continue
		_check_script(script_path)

func _check_script(script_path: String) -> void:
	_checked_count += 1
	var output: Array[String] = []
	var arguments: PackedStringArray = PackedStringArray()
	arguments.append("--headless")
	arguments.append("--path")
	arguments.append(_project_path)
	arguments.append("--check-only")
	arguments.append("--script")
	arguments.append(script_path)
	var exit_code: int = OS.execute(_executable, arguments, output, true)
	if exit_code != 0:
		var detail: String = " | ".join(output)
		_failures.append("%s (exit %d): %s" % [script_path, exit_code, detail])
