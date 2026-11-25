class_name CatalogService
extends RefCounted

var simulated: bool = false

func list_shop_items(game_filter: String = "") -> ApiResponse:
	assert(false, "Implement list_shop_items")
	return ApiResponse.new(false, {}, "NOT_IMPLEMENTED", 0)
