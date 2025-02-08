extends Control

signal mouse_in_ui

@onready var MainTexture: TextureRect = %MainTexture
@onready var MainPanel: PanelContainer = $MainPanel
@onready var ToolIconRect: Control = %ToolIconRect

var data: SavedData
func setInfo(_data: SavedData) -> void:
	data = _data
	var info: FofInfo = Helper.getFofInfoID(data.getInfoType(), data.id)
	MainTexture.texture = info.getIcon()
	MainPanel.theme_type_variation = Game.getRarityThemeVariation(info.rarity, data.ascended)
	
	if data is SavedDataCard: ToolIconRect.visible = data.tool_data != null
	
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(is_mouse_in_ui)
	
	Game.onMouseInUITooltip(is_mouse_in_ui, data, self, true)
