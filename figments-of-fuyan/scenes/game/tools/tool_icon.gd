extends Control
signal pressed
signal mouse_in_ui
var is_mouse_in_ui: bool
var disabled: bool

const SPIN_SPEED: float = 10
@onready var ToolIcon: TextureRect = %ToolIcon

var Tool: ToolGD
var hoverable: bool
var ascended: bool

@export var disable_tooltip: bool

func setInfo(_Tool: ToolGD, _hoverable: bool = false) -> void:
	Tool = _Tool
	
	if Tool != null: Tool.clear.connect(queue_free)
	setInfoDirect(Tool.getIcon() if Tool != null else null, Tool.ascended if Tool != null else false, _hoverable)
	
func setInfoDirect(icon: Texture2D, _ascended: bool, _hoverable: bool = false) -> void:
	visible = icon != null
	ToolIcon.texture = icon
	hoverable = _hoverable
	onUpdateAscension(_ascended)

func onUpdateAscension(_ascended: bool) -> void:
	ascended = _ascended

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and !disabled:
		pressed.emit(Tool)

func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	
	if !disabled and hoverable:
		modulate = Color(1, 1, 1) if !state else Color(0.5, 0.5 , 0.5)
		
	if disable_tooltip: return
	Game.onMouseInUITooltip(state, Tool, self, true)
	
func setDisabled(state: bool) -> void:
	disabled = state
	modulate = Color(1, 1, 1) if !disabled else Color(0.2, 0.2, 0.2)
	onUpdateAscension(ascended)
