extends TestCase

# AC-3, AC-8: all 17 licensed audio files are complete and no audio is present
# outside the two licensed folders. SHA-256 and byte-size checks are delegated
# to client/tools/verify_audio_assets.py; this suite stays offline and typed.

const ASSETS_PATH: String = "res://assets"
const EFFECTS_PATH: String = "res://assets/common/audio/effects"
const MUSIC_PATH: String = "res://assets/common/audio/music"
const LICENSE_PATH: String = "res://assets/common/audio/effects/LICENSE.txt"
const EFFECTS_ATTRIBUTION_PATH: String = "res://assets/common/audio/effects/ATTRIBUTION.md"
const MUSIC_ATTRIBUTION_PATH: String = "res://assets/common/audio/music/ATTRIBUTION.md"
const AUDIO_EXTENSIONS: Array[String] = ["ogg", "mp3", "wav"]
const GROUPS: Array[Dictionary] = [
	{"path": EFFECTS_PATH, "count": 13, "extension": "ogg"},
	{"path": MUSIC_PATH, "count": 4, "extension": "mp3"},
]

func run() -> void:
	var total: int = _check_manifests()
	expect(total == 17, "manifests should reference exactly 17 audio files")
	_check_license()
	_check_attributions()
	_check_audio_gate()

func _manifest_files(directory: String) -> Dictionary:
	var manifest_path: String = directory.path_join("manifest.json")
	if not FileAccess.file_exists(manifest_path):
		expect(false, "%s should exist" % manifest_path)
		return {}
	var text: String = FileAccess.get_file_as_string(manifest_path)
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		expect(false, "%s should parse as an object" % manifest_path)
		return {}
	var files: Variant = (parsed as Dictionary).get("files", null)
	if not (files is Dictionary):
		expect(false, "%s should contain a files object" % manifest_path)
		return {}
	return files as Dictionary

func _check_manifests() -> int:
	var total: int = 0
	for group: Dictionary in GROUPS:
		var directory: String = String(group["path"])
		var expected_count: int = int(group["count"])
		var extension: String = String(group["extension"])
		var files: Dictionary = _manifest_files(directory)
		expect(files.size() == expected_count, "%s manifest should reference %d files" % [directory, expected_count])
		total += files.size()
		for key: Variant in files.keys():
			var file_name: String = String(key)
			expect(file_name == file_name.get_file(), "manifest key should be a filename: %s" % file_name)
			expect(file_name.get_extension().to_lower() == extension, "unexpected manifest extension: %s" % file_name)
			expect(FileAccess.file_exists(directory.path_join(file_name)), "manifest audio file should exist: %s" % file_name)
		var on_disk: Array[String] = _audio_files(directory, extension)
		expect(on_disk.size() == expected_count, "%s should hold exactly %d audio files" % [directory, expected_count])
		for file_name: String in on_disk:
			expect(files.has(file_name), "audio file should be listed in the manifest: %s" % file_name)
	return total

func _audio_files(directory: String, extension: String) -> Array[String]:
	var result: Array[String] = []
	var folder: DirAccess = DirAccess.open(directory)
	if folder == null:
		expect(false, "cannot open %s" % directory)
		return result
	for file_name: String in folder.get_files():
		if file_name.get_extension().to_lower() == extension:
			result.append(file_name)
	return result

func _check_license() -> void:
	expect(FileAccess.file_exists(LICENSE_PATH), "LICENSE.txt should exist")
	if not FileAccess.file_exists(LICENSE_PATH):
		return
	var text: String = FileAccess.get_file_as_string(LICENSE_PATH)
	expect(text.contains("CC0"), "LICENSE.txt should name CC0")
	expect(text.contains("Kenney"), "LICENSE.txt should credit Kenney")

func _check_attributions() -> void:
	var paths: Array[String] = [EFFECTS_ATTRIBUTION_PATH, MUSIC_ATTRIBUTION_PATH]
	for path: String in paths:
		expect(FileAccess.file_exists(path), "%s should exist" % path)
		if not FileAccess.file_exists(path):
			continue
		var text: String = FileAccess.get_file_as_string(path)
		expect(text.contains("CC0"), "%s should name CC0" % path)
	if FileAccess.file_exists(EFFECTS_ATTRIBUTION_PATH):
		var effects_text: String = FileAccess.get_file_as_string(EFFECTS_ATTRIBUTION_PATH)
		expect(effects_text.contains("Kenney"), "effects attribution should credit Kenney")
	if FileAccess.file_exists(MUSIC_ATTRIBUTION_PATH):
		var music_text: String = FileAccess.get_file_as_string(MUSIC_ATTRIBUTION_PATH)
		expect(music_text.contains("HoliznaCC0"), "music attribution should credit HoliznaCC0")

func _check_audio_gate() -> void:
	var paths: Array[String] = []
	_collect_files(ASSETS_PATH, paths)
	var outside: Array[String] = []
	for path: String in paths:
		if path.begins_with(EFFECTS_PATH + "/") or path.begins_with(MUSIC_PATH + "/"):
			continue
		if AUDIO_EXTENSIONS.has(path.get_extension().to_lower()):
			outside.append(path)
	expect(outside.is_empty(), "audio outside licensed folders: %s" % ", ".join(outside))

func _collect_files(path: String, result: Array[String]) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null:
		expect(false, "cannot open %s" % path)
		return
	for file_name: String in directory.get_files():
		result.append(path.path_join(file_name))
	for folder_name: String in directory.get_directories():
		_collect_files(path.path_join(folder_name), result)
