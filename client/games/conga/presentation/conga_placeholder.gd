extends Screen

func _ready() -> void:
	custom_minimum_size = Vector2(360.0, 800.0)
	var title: Label = get_node_or_null("Center/Panel/Content/Title") as Label
	if title != null:
		title.text = "Conga is planned for Phase 2"
	var detail: Label = get_node_or_null("Center/Panel/Content/Detail") as Label
	if detail != null:
		detail.text = "No rules, bots, or multiplayer are implemented in this placeholder."
