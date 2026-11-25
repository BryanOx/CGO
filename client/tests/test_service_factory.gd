extends TestCase

# AC-4: composition selects mocks only in development.

func run() -> void:
	var development: BackendConfig = BackendConfig.new()
	development.environment = &"development"
	var dev_services: ServiceRegistry = ServiceFactory.build(development)
	expect(dev_services.auth.simulated, "development auth should be simulated")
	expect(dev_services.profile.simulated, "development profile should be simulated")
	expect(dev_services.catalog.simulated, "development catalog should be simulated")
	expect(dev_services.wallet.simulated, "development wallet should be simulated")
	expect(dev_services.inventory.simulated, "development inventory should be simulated")
	expect(dev_services.leaderboard.simulated, "development leaderboard should be simulated")
	expect(dev_services.api.simulated, "development api should be simulated")
	expect(dev_services.realtime.simulated, "development realtime should be simulated")
	expect(dev_services.settings is LocalSettingsService, "development settings should be local")
	expect(not dev_services.settings.simulated, "local settings persistence is real, not a mock")
	var mock_services: ServiceRegistry = MockServices.build(development)
	expect(mock_services.settings.simulated, "mock settings adapter should be simulated")

	var production: BackendConfig = BackendConfig.new()
	production.environment = &"production"
	var prod_services: ServiceRegistry = ServiceFactory.build(production)
	expect(not prod_services.auth.simulated, "production auth must not be simulated")
	expect(not prod_services.profile.simulated, "production profile must not be simulated")
	expect(not prod_services.catalog.simulated, "production catalog must not be simulated")
	expect(not prod_services.wallet.simulated, "production wallet must not be simulated")
	expect(not prod_services.inventory.simulated, "production inventory must not be simulated")
	expect(not prod_services.leaderboard.simulated, "production leaderboard must not be simulated")
	expect(not prod_services.settings.simulated, "production settings must not be simulated")
	expect(not prod_services.api.simulated, "production api must not be simulated")
	expect(not prod_services.realtime.simulated, "production realtime must not be simulated")
	expect(prod_services.api is RemoteApiClient, "production api should be the remote adapter")
