class_name Router
extends Node

signal screen_changed(screen_id: StringName)

@export var screen_host: Node

var _screen_map: Dictionary = {}
var _context: AppContext = null
var _current_screen: Screen = null
var _current_id: StringName = &""
var _current_payload: Dictionary = {}
var _back_stack: Array[StringName] = []
var _back_payloads: Array[Dictionary] = []

func configure(screen_map: Dictionary, p_context: AppContext) -> void:
	_screen_map = screen_map.duplicate()
	_context = p_context

func navigate(screen_id: StringName, payload: Dictionary = {}) -> void:
	_push_current()
	_show_mapped_screen(screen_id, payload)

func replace(screen_id: StringName, payload: Dictionary = {}) -> void:
	_back_stack.clear()
	_back_payloads.clear()
	_show_mapped_screen(screen_id, payload)

func open_scene(scene_path: String, payload: Dictionary = {}) -> void:
	var packed: PackedScene = ResourceLoader.load(scene_path, "PackedScene") as PackedScene
	if packed == null:
		push_error("Router cannot load scene: %s" % scene_path)
		return
	_push_current()
	_show_packed_scene(packed, StringName(scene_path), payload)

func back() -> void:
	if _back_stack.is_empty():
		return
	var previous_id: StringName = _back_stack.pop_back()
	var previous_payload: Dictionary = _back_payloads.pop_back()
	_show_mapped_screen(previous_id, previous_payload)

func _push_current() -> void:
	if _current_id == &"":
		return
	_back_stack.append(_current_id)
	_back_payloads.append(_current_payload.duplicate())

func _show_mapped_screen(screen_id: StringName, payload: Dictionary) -> void:
	if not _screen_map.has(screen_id):
		push_error("Router has no screen registered for: %s" % screen_id)
		return
	var mapping: Variant = _screen_map[screen_id]
	var packed: PackedScene = null
	if mapping is PackedScene:
		packed = mapping as PackedScene
	elif mapping is String:
		packed = ResourceLoader.load(mapping as String, "PackedScene") as PackedScene
	if packed == null:
		push_error("Router cannot load screen: %s" % screen_id)
		return
	_show_packed_scene(packed, screen_id, payload)

func _show_packed_scene(packed: PackedScene, screen_id: StringName, payload: Dictionary) -> void:
	if screen_host == null:
		push_error("Router has no screen_host assigned")
		return
	var instance: Node = packed.instantiate()
	if instance.has_method(&"configure"):
		instance.call(&"configure", self, _context, payload)
	if _current_screen != null and is_instance_valid(_current_screen):
		screen_host.remove_child(_current_screen)
		_current_screen.free()
	screen_host.add_child(instance)
	_current_screen = instance as Screen
	_current_id = screen_id
	_current_payload = payload.duplicate()
	screen_changed.emit(screen_id)
