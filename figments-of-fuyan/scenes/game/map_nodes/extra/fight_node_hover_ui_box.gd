extends Control

@onready var UnitTexture: TextureRect = %UnitTexture
@onready var UnitPanel: PanelContainer = %UnitPanel
@onready var ToolIconRect: Control = %ToolIconRect

func setInfo(card_info: CardInfo, card_data: SavedDataCard, has_tool: bool) -> void:
	UnitTexture.texture = card_info.getArtMini()
	
	if card_data.ascended:
		UnitPanel.theme_type_variation = "YellowPanelContainer"
	
	ToolIconRect.visible = has_tool
	
