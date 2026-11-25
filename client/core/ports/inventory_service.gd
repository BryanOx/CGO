class_name InventoryService
extends RefCounted

var simulated: bool = false

func list_items() -> ApiResponse:
	assert(false, "Implement list_items")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)

func equip(item_id: String, slot: StringName) -> ApiResponse:
	assert(false, "Implement equip")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)
