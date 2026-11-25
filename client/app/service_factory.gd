class_name ServiceFactory
extends RefCounted

# Composition root for service adapters. No UI or game logic here.

static func build(config: BackendConfig) -> ServiceRegistry:
	if config != null and config.is_development():
		var services: ServiceRegistry = MockServices.build(config)
		services.settings = LocalSettingsService.new()
		return services
	return RemoteServices.build(config)
