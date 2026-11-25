class_name ServiceFactory
extends RefCounted

# Interim composition: fail-explicit ports until P1-3 supplies adapters.

static func build(_config: BackendConfig) -> ServiceRegistry:
	return ServiceRegistry.new(
		AuthService.new(),
		ProfileService.new(),
		CatalogService.new(),
		WalletService.new(),
		InventoryService.new(),
		LeaderboardService.new(),
		SettingsService.new(),
		ApiClient.new(),
		RealtimeClient.new()
	)
