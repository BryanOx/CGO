class_name LocalSettingsService
extends SettingsService

const SETTINGS_PATH: String = "user://cgo_settings.cfg"
const SETTINGS_SECTION: StringName = &"cgo"
const DEFAULTS: Dictionary = {
	"audio_enabled": true,
	"language": "en",
	"reduced_motion": false,
}

func _init() -> void:
	simulated = false

func load_settings() -> Dictionary:
	var settings: Dictionary = DEFAULTS.duplicate(true)
	var file: ConfigFile = ConfigFile.new()
	if file.load(SETTINGS_PATH) != OK:
		return settings
	for key: String in file.get_section_keys(SETTINGS_SECTION):
		settings[key] = file.get_value(SETTINGS_SECTION, key)
	return settings

func save_settings(settings: Dictionary) -> bool:
	var file: ConfigFile = ConfigFile.new()
	for key: Variant in settings.keys():
		file.set_value(SETTINGS_SECTION, String(key), settings[key])
	return file.save(SETTINGS_PATH) == OK
