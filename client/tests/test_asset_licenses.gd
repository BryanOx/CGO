extends TestCase

# AC-1, AC-2, AC-3: licensed card assets are complete and unlicensed audio is absent.

const MANIFEST_PATH: String = "res://assets/cards/conga/classic_red/manifest.json"
const CARDS_PATH: String = "res://assets/cards/conga/classic_red/cards"
const ATTRIBUTION_MD_PATH: String = "res://assets/cards/conga/classic_red/ATTRIBUTION.md"
const ATTRIBUTION_TXT_PATH: String = "res://assets/cards/conga/classic_red/attribution.txt"
const ATTRIBUTION_PATHS: Array[String] = [ATTRIBUTION_MD_PATH, ATTRIBUTION_TXT_PATH]
const DEFINITION_PATH: String = "res://assets/cosmetics/free/conga/decks/classic_red/manifest.tres"
const AUDIO_EXTENSIONS: Array[String] = [
	"ogg", "oga", "mp3", "wav", "m4a", "flac", "aac", "opus", "wma", "aiff", "mid", "midi"
]
const LICENSED_AUDIO_PATHS: Array[String] = [
	"res://assets/common/audio/effects",
	"res://assets/common/audio/music",
]

func run() -> void:
	_check_attribution()
	var files: Dictionary = _manifest_files()
	_check_manifest(files)
	_check_audio_gate()
	_check_stable_ids(files)

func _check_attribution() -> void:
	for path: String in ATTRIBUTION_PATHS:
		expect(FileAccess.file_exists(path), "%s should exist" % path)
		if not FileAccess.file_exists(path):
			continue
		var text: String = FileAccess.get_file_as_string(path)
		expect(text.contains("CC BY-SA 3.0"), "%s should name CC BY-SA 3.0" % path)
		expect(text.contains("Basquetteur"), "%s should credit Basquetteur" % path)
		expect(text.contains("gjenkins20"), "%s should credit gjenkins20" % path)

func _manifest_files() -> Dictionary:
	if not FileAccess.file_exists(MANIFEST_PATH):
		expect(false, "manifest.json should exist")
		return {}
	var text: String = FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		expect(false, "manifest.json should parse as an object")
		return {}
	var files: Variant = (parsed as Dictionary).get("files", null)
	if not (files is Dictionary):
		expect(false, "manifest should contain a files object")
		return {}
	return files as Dictionary

func _check_manifest(files: Dictionary) -> void:
	expect(files.size() == 50, "manifest should reference exactly 50 card PNGs")
	var missing: Array[String] = []
	for key: Variant in files.keys():
		var file_name: String = String(key)
		if not FileAccess.file_exists(CARDS_PATH.path_join(file_name)):
			missing.append(file_name)
	expect(missing.is_empty(), "all manifest PNGs should exist: %s" % ", ".join(missing))

func _check_audio_gate() -> void:
	var paths: Array[String] = []
	_collect_files("res://assets", paths)
	var audio: Array[String] = []
	for path: String in paths:
		var licensed: bool = false
		for licensed_path: String in LICENSED_AUDIO_PATHS:
			if path.begins_with(licensed_path + "/"):
				licensed = true
		if licensed:
			continue
		var extension: String = path.get_extension().to_lower()
		if AUDIO_EXTENSIONS.has(extension):
			audio.append(path)
	expect(audio.is_empty(), "unlicensed audio should not exist under client/assets: %s" % ", ".join(audio))

func _collect_files(path: String, result: Array[String]) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null:
		expect(false, "cannot open %s" % path)
		return
	for file_name: String in directory.get_files():
		result.append(path.path_join(file_name))
	for folder_name: String in directory.get_directories():
		_collect_files(path.path_join(folder_name), result)

func _check_stable_ids(files: Dictionary) -> void:
	var definition: CosmeticDefinition = ResourceLoader.load(DEFINITION_PATH) as CosmeticDefinition
	expect(definition != null, "definition resource should load")
	if definition == null:
		return
	var item_ids: Array[StringName] = [definition.item_id, &"paid_test", &"ad_reward_test"]
	var paths: Array[String] = []
	_collect_files("res://assets", paths)
	for path: String in paths:
		var file_name: String = path.get_file()
		for item_id: StringName in item_ids:
			var identifier: String = String(item_id)
			expect(identifier != file_name, "item_id %s should not equal a filename" % identifier)
			expect(identifier != file_name.get_basename(), "item_id %s should not equal a file stem" % identifier)
	expect(not files.has(String(definition.item_id)), "item_id should not be a manifest filename")
