class_name RealtimeClient
extends RefCounted

signal snapshot_received(snapshot: Dictionary)
signal connection_state_changed(state: StringName)

var simulated: bool = false

func connect_to(match_id: String, last_seq: int) -> void:
	assert(false, "Implement connect_to")

func send_action(action: Dictionary) -> void:
	assert(false, "Implement send_action")

func resume(match_id: String, last_seq: int) -> void:
	assert(false, "Implement resume")

func close() -> void:
	assert(false, "Implement close")
