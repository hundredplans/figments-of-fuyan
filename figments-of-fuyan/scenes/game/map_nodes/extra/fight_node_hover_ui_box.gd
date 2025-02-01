extends Control

@onready var UnitTexture: TextureRect = %UnitTexture
@onready var UnitPanel: PanelContainer = %UnitPanel
@onready var ToolIconRect: Control = %ToolIconRect

func setInfo(card_info: CardInfo, card_data: SavedDataCard, has_tool: bool) -> void:
	UnitTexture.texture = card_info.getArtMini()
	
	var theme_variation: String = "WhitePanelContainer"
	if card_data.ascended: theme_variation += "Ascended"
	UnitPanel.theme_type_variation = theme_variation
	ToolIconRect.visible = has_tool
	
