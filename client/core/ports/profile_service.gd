class_name ProfileService
extends RefCounted

var simulated: bool = false

func get_profile() -> ApiResponse:
	assert(false, "Implement get_profile")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)

func update_profile(patch: Dictionary) -> ApiResponse:
	assert(false, "Implement update_profile")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)
