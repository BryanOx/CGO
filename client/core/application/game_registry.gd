class_name GameRegistry
extends RefCounted

var _definitions: Array[GameDefinition] = []
var _by_id: Dictionary = {}

func _init(definitions: Array[GameDefinition] = []) -> void:
	for definition: GameDefinition in definitions:
		register(definition)

func register(definition: GameDefinition) -> bool:
	if definition == null or definition.id == &"" or _by_id.has(definition.id):
		return false
	_definitions.append(definition)
	_by_id[definition.id] = definition
	return true

func get_by_id(id: StringName) -> GameDefinition:
	if not _by_id.has(id):
		return null
	return _by_id[id] as GameDefinition

func list_all() -> Array[GameDefinition]:
	return _definitions.duplicate()

func list_enabled() -> Array[GameDefinition]:
	var enabled_definitions: Array[GameDefinition] = []
	for definition: GameDefinition in _definitions:
		if definition.enabled:
			enabled_definitions.append(definition)
	return enabled_definitions
