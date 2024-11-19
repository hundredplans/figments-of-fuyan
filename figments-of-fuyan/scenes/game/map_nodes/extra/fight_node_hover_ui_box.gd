extends Control

@onready var UnitTexture: TextureRect = %UnitTexture
@onready var UnitPanel: PanelContainer = %UnitPanel
@onready var ToolIcon: Control = %ToolIcon

func setInfo(card_info: CardInfo, card_data: SavedDataCard, tool_info: ToolInfo, tool_data: SavedDataTool) -> void:
	UnitTexture.texture = ImageTexture.create_from_image(card_info.art_mini)
	
	if card_data.ascended:
		UnitPanel.theme_type_variation = "YellowPanelContainer"
	
	ToolIcon.setInfoDirect(
		ImageTexture.create_from_image(tool_info.icon) if tool_info != null else null,\
		tool_data.ascended if tool_data != null else false)
	
