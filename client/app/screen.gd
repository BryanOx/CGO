class_name Screen
extends Control

var router: Router
var context: AppContext

func configure(p_router: Router, p_context: AppContext, payload: Dictionary) -> void:
	router = p_router
	context = p_context
	on_configured(payload)

func on_configured(_payload: Dictionary) -> void:
	pass
