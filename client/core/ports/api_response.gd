class_name ApiResponse
extends RefCounted

var ok: bool
var data: Dictionary
var error_code: String
var status_code: int

func _init(p_ok: bool, p_data: Dictionary = {}, p_error_code: String = "", p_status_code: int = 0) -> void:
	ok = p_ok
	data = p_data
	error_code = p_error_code
	status_code = p_status_code
