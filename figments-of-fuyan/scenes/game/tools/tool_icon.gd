extends Control
signal pressed
signal mouse_in_ui
var is_mouse_in_ui: bool
var disabled: bool

const SPIN_SPEED: float = 10
@onready var ToolIcon: TextureRect = %ToolIcon

var Tool: ToolGD
var hoverable: bool

@export var disable_tooltip: bool

func setInfo(_Tool: ToolGD, _hoverable: bool = false) -> void:
	Tool = _Tool
	setInfoDirect(Tool.getIcon() if Tool != null else null, _hoverable)
	
func setInfoDirect(icon: Texture2D, _hoverable: bool = false) -> void:
	visible = icon != null
	ToolIcon.texture = icon
	hoverable = _hoverable

func setHighlightOnHover(_hoverable: bool) -> void:
	hoverable = _hoverable
	onUpdateModulate()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and !disabled:
		pressed.emit(Tool)

func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	
	onUpdateModulate()
		
	if disable_tooltip: return
	Game.onMouseInUITooltip(state, Tool, self, true)
	
func setDisabled(state: bool) -> void:
	disabled = state
	onUpdateModulate()
	
func onUpdateModulate() -> void:
	modulate = Color(0.2, 0.2, 0.2) if disabled else\
		(Color(0.5, 0.5, 0.5) if is_mouse_in_ui and hoverable else Color.WHITE)
	
func setDisableTooltip(_disable_tooltip: bool) -> void:
	disable_tooltip = _disable_tooltip
	
func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	mouse_filter = _mouse_filter

func setSizeScale(n: int) -> void:
	size *= n
	pivot_offset = (size / 2)
	
func setExpandMode(expand_mode: TextureRect.ExpandMode) -> void:
	ToolIcon.expand_mode = expand_mode
