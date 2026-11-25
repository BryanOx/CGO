class_name ApiClient
extends RefCounted

var simulated: bool = false

func get_json(path: String, query: Dictionary = {}) -> ApiResponse:
	assert(false, "Implement get_json")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)

func post_json(path: String, payload: Dictionary, idempotency_key: String = "") -> ApiResponse:
	assert(false, "Implement post_json")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)

func delete_json(path: String) -> ApiResponse:
	assert(false, "Implement delete_json")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)
