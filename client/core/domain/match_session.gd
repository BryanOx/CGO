class_name MatchSession
extends RefCounted

# Contract only. Game-specific rules and states belong in game modules.

signal snapshot_changed(snapshot: Dictionary)
signal action_rejected(code: String)
signal finished(result: Dictionary)

func submit_action(action: Dictionary) -> void:
	assert(false, "Implement submit_action")

func close() -> void:
	assert(false, "Implement close")
