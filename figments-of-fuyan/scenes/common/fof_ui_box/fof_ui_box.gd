extends Control

signal mouse_in_ui
signal pressed

@onready var InsideRect: ColorRect = %InsideRect
@onready var MainTexture: TextureRect = %MainTexture
@onready var MainPanel: PanelContainer = $MainPanel
@onready var ToolIconRect: Control = %ToolIconRect

@export var disable_tooltip: bool
var flip_tooltip: bool

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
		setBorderColor(Game.getRarityColor(info.rarity))
		
		if data is SavedDataCard:
			var area_id: int = Game.getAreaIDFromCardID(data.id)
			InsideRect.color = Helper.getFofInfoID(AreaInfo, area_id).getAreaColor()
			setToolData(data.tool_data)
		else:
			InsideRect.color = Game.getArea().getAreaColor() 
	else:
		ToolIconRect.visible = false
		MainTexture.texture = null
		MainPanel.theme_type_variation = ""
		
func setBorderColor(color: Color) -> void:
	MainPanel.self_modulate = color
		
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(is_mouse_in_ui)
	
	if data == null or disable_tooltip: return
	Game.onMouseInUITooltip(is_mouse_in_ui, data, self, true, flip_tooltip)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui:
		pressed.emit()

func setBackgroundModulate(color: Color) -> void:
	MainPanel.self_modulate = color

func setSilhouette(icon: Texture2D, outside_color: Color) -> void:
	InsideRect.color = Color.BLACK
	MainTexture.texture = icon
	MainPanel.self_modulate = outside_color

func setFlipTooltip(_flip_tooltip: bool = false) -> void:
	flip_tooltip = _flip_tooltip

func setBorderMaterial(_material: Material) -> void:
	MainPanel.material = _material

func setToolData(data: SavedDataTool) -> void:
	ToolIconRect.visible = data != null
	if show_tool_icon and ToolIconRect.visible:
		ToolIconRect.texture = Helper.getFofInfoID(ToolInfo, data.id).getIcon()
		
