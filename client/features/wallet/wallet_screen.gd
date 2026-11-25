extends FeatureScreen

func _ready() -> void:
	super._ready()
	var tokens: DesignTokens = DesignTokens.get_shared()
	var column: VBoxContainer = new_column()
	column.add_child(new_label("Wallet", tokens.font_display))
	var balance: int = 0
	var currency: String = "coins"
	var loaded: bool = false
	if context != null and context.services != null:
		var response: ApiResponse = context.services.wallet.get_balance()
		if response.ok:
			balance = int(response.data.get("balance", 0))
			currency = String(response.data.get("currency", "coins"))
			loaded = true
	var pill: CurrencyPill = CurrencyPill.new()
	pill.set_amount(balance)
	column.add_child(pill)
	column.add_child(new_label("Currency: %s" % currency, tokens.font_body))
	if not loaded:
		column.add_child(new_label("Balance data is unavailable.", tokens.font_body, true))
	column.add_child(new_label(
		"Balances are server-authoritative. This balance is simulated data in development; no balance controls are available.",
		tokens.font_caption,
		true
	))
	add_nav(column)
	safe_area.add_child(column)
