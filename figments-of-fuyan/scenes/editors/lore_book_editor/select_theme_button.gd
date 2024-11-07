extends OptionButton

@export var panel: PanelContainer

func _ready() -> void:
	print(panel.theme)
	for variation in panel.theme.get_type_variation_list("PanelContainer"):
		add_item(variation)

func _on_item_selected(index: int) -> void:
	panel.theme_type_variation = get_item_text(index)
