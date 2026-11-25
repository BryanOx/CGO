class_name LeaderboardService
extends RefCounted

var simulated: bool = false

func get_top(game_id: StringName) -> ApiResponse:
	assert(false, "Implement get_top")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)
