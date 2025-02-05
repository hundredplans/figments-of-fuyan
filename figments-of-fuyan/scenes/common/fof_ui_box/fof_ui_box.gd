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
	
	var theme_variation: String
	match info.rarity:
		Game.Rarities.SCRAP, Game.Rarities.MINI: theme_variation = "GreyPanelContainer"
		Game.Rarities.NEUTRAL: theme_variation = "DarkBrownPanelContainer"
		Game.Rarities.COMMON: theme_variation = "BeigePanelContainer"
		Game.Rarities.RARE: theme_variation = "TealPanelContainer"
		Game.Rarities.EXALT: theme_variation = "YellowPanelContainer"
		Game.Rarities.MINIBOSS: theme_variation = "PurplePanelContainer"
		Game.Rarities.BOSS: theme_variation = "RedPanelContainer"
		Game.Rarities.CHAMPION: theme_variation = "BluePanelContainer"
		_: theme_variation = "WhitePanelContainer"
	
	if data.ascended: theme_variation += "Ascended"
	MainPanel.theme_type_variation = theme_variation
	
	if data is SavedDataCard: ToolIconRect.visible = data.tool_data != null
	
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(is_mouse_in_ui)
	
	Game.onMouseInUITooltip(is_mouse_in_ui, data, self, true)
