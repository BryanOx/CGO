class_name CosmeticDefinition
extends Resource

# A definition resolves local visuals only. Price, availability, ownership,
# and rewards remain server authority.

@export var item_id: StringName = &""
@export var category: String = ""
@export var compatible_game_ids: PackedStringArray = PackedStringArray()
@export var slot: String = ""
@export var preview: String = ""
@export var asset_key: StringName = &""
@export var fallback_key: StringName = &""
@export var acquisition: StringName = &""
@export var license_id: StringName = &""
@export var attribution_ref: String = ""
@export var enabled: bool = true
