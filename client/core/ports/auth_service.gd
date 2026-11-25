class_name AuthService
extends RefCounted

var simulated: bool = false

func start_guest_session() -> ApiResponse:
	assert(false, "Implement start_guest_session")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)

func current_user_id() -> String:
	assert(false, "Implement current_user_id")
	return ""
