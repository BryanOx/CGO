class_name AppContext
extends Node

var config: BackendConfig
var services: ServiceRegistry
var games: GameRegistry
var theme: Theme

func configure(
	p_config: BackendConfig,
	p_services: ServiceRegistry,
	p_games: GameRegistry,
	p_theme: Theme
) -> void:
	config = p_config
	services = p_services
	games = p_games
	theme = p_theme
