extends Control

signal mouse_in_ui
signal pressed

@onready var MainTexture: TextureRect = %MainTexture
@onready var MainPanel: PanelContainer = $MainPanel
@onready var ToolIconRect: Control = %ToolIconRect

@export var disable_tooltip: bool

var data: SavedData
var show_tool_icon: bool
func setInfo(_data: SavedData, _show_tool_icon: bool = false) -> void:
	show_tool_icon = _show_tool_icon
	setData(_data)

func setData(_data: SavedData) -> void:
	data = _data
	if data != null:
		var info: FofInfo = Helper.getFofInfoID(data.getInfoType(), data.id)
		MainTexture.texture = info.getIcon()
		MainPanel.theme_type_variation = Game.getRarityThemeVariation(info.rarity)
		
		if data is SavedDataCard:
			ToolIconRect.visible = data.tool_data != null
			if show_tool_icon and ToolIconRect.visible:
				ToolIconRect.texture = Helper.getFofInfoID(ToolInfo, data.tool_data.id).getIcon()
	else:
		ToolIconRect.visible = false
		MainTexture.texture = null
		MainPanel.theme_type_variation = ""
		
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(is_mouse_in_ui)
	
	if data == null or disable_tooltip: return
	Game.onMouseInUITooltip(is_mouse_in_ui, data, self, true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui:
		pressed.emit()
