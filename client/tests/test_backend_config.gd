extends TestCase

# AC-3: the endpoint is configuration composition, not business logic.

func run() -> void:
	var config: BackendConfig = BackendConfig.new()
	config.base_url = "http://127.0.0.1:3000/"
	config.api_version = "v1"
	expect(
		config.endpoint("/auth/guest") == "http://127.0.0.1:3000/v1/auth/guest",
		"trailing slash on base_url should not duplicate a separator"
	)
	config.base_url = "http://127.0.0.1:3000"
	expect(
		config.endpoint("auth/guest") == "http://127.0.0.1:3000/v1/auth/guest",
		"path without leading slash should produce the same endpoint"
	)
	expect(config.api_version == "v1", "api version should remain unchanged")
	expect(config.is_development(), "default environment should be development")
	config.environment = &"production"
	expect(not config.is_development(), "production environment should not be development")

	config.base_url = "https://api.example.invalid"
	config.environment = &"development"
	expect(
		config.endpoint("/health") == "https://api.example.invalid/v1/health",
		"changing base_url should be the only edit needed to retarget the API"
	)
	expect(config.api_version == "v1", "retargeting base_url should not change the api version")
