class_name GameDefinition
extends Resource

@export var id: StringName
@export var display_name: String
@export var description: String = ""
@export var scene_path: String = ""
@export var rules_version: String = "0"
@export var modes: PackedStringArray = PackedStringArray()
@export var capabilities: PackedStringArray = PackedStringArray()
@export var enabled: bool = true
@export var accent_color: Color = Color.WHITE
