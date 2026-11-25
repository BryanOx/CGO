class_name CosmeticCatalog
extends RefCounted

# In-memory registry of cosmetic definitions. Stable IDs, tiers, and fallback
# keys are local metadata; no price, ownership, or reward decision is made here.

var _definitions: Array[CosmeticDefinition] = []
var _by_item_id: Dictionary = {}
var _by_asset_key: Dictionary = {}

func _init(definitions: Array[CosmeticDefinition] = []) -> void:
	for definition: CosmeticDefinition in definitions:
		register(definition)

func register(definition: CosmeticDefinition) -> bool:
	if definition == null or definition.item_id == &"" or _by_item_id.has(definition.item_id):
		return false
	_definitions.append(definition)
	_by_item_id[definition.item_id] = definition
	if definition.asset_key != &"":
		_by_asset_key[definition.asset_key] = definition
	return true

func get_by_item_id(item_id: StringName) -> CosmeticDefinition:
	if not _by_item_id.has(item_id):
		return null
	return _by_item_id[item_id] as CosmeticDefinition

func list_by_acquisition(tier: StringName) -> Array[CosmeticDefinition]:
	var matched: Array[CosmeticDefinition] = []
	for definition: CosmeticDefinition in _definitions:
		if definition.acquisition == tier:
			matched.append(definition)
	return matched

func resolve_asset(asset_key: StringName) -> String:
	var definition: CosmeticDefinition = _definition_for_asset_key(asset_key)
	if definition == null:
		return ""
	if not definition.preview.is_empty():
		return definition.preview
	if definition.fallback_key == &"":
		return ""
	var fallback: CosmeticDefinition = _definition_for_asset_key(definition.fallback_key)
	if fallback == null:
		fallback = get_by_item_id(definition.fallback_key)
	if fallback == null:
		return ""
	return fallback.preview

func _definition_for_asset_key(asset_key: StringName) -> CosmeticDefinition:
	if asset_key == &"" or not _by_asset_key.has(asset_key):
		return null
	return _by_asset_key[asset_key] as CosmeticDefinition
