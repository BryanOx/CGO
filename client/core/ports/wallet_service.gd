class_name WalletService
extends RefCounted

var simulated: bool = false

func get_balance() -> ApiResponse:
	assert(false, "Implement get_balance")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)
