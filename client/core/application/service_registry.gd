class_name ServiceRegistry
extends RefCounted

var auth: AuthService
var profile: ProfileService
var catalog: CatalogService
var wallet: WalletService
var inventory: InventoryService
var leaderboard: LeaderboardService
var settings: SettingsService
var api: ApiClient
var realtime: RealtimeClient

func _init(
	p_auth: AuthService,
	p_profile: ProfileService,
	p_catalog: CatalogService,
	p_wallet: WalletService,
	p_inventory: InventoryService,
	p_leaderboard: LeaderboardService,
	p_settings: SettingsService,
	p_api: ApiClient,
	p_realtime: RealtimeClient
) -> void:
	auth = p_auth
	profile = p_profile
	catalog = p_catalog
	wallet = p_wallet
	inventory = p_inventory
	leaderboard = p_leaderboard
	settings = p_settings
	api = p_api
	realtime = p_realtime
