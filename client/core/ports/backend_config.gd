class_name BackendConfig
extends Resource

@export var environment: StringName = &"development"
@export var base_url: String = "http://127.0.0.1:3000"
@export var api_version: String = "v1"
@export var request_timeout_seconds: float = 10.0

func endpoint(path: String) -> String:
	var segments: PackedStringArray = PackedStringArray()
	var clean_base: String = base_url.trim_suffix("/")
	var clean_version: String = api_version.trim_suffix("/").trim_prefix("/")
	var clean_path: String = path.trim_prefix("/")
	if not clean_base.is_empty():
		segments.append(clean_base)
	if not clean_version.is_empty():
		segments.append(clean_version)
	if not clean_path.is_empty():
		segments.append(clean_path)
	return "/".join(segments)

func is_development() -> bool:
	return environment == &"development"
