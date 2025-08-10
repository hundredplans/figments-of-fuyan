extends TbcUI

const SPIN_SPEED: float = 10
@onready var ToolIcon: TextureRect = %ToolIcon

var Tool: ToolGD

func setInfo(_Tool: ToolGD, _hoverable: bool = false) -> void:
	Tool = _Tool
	setInfoDirect(Tool.getIcon() if Tool != null else null, _hoverable)
	
func setTool(_Tool: ToolGD) -> void:
	Tool = _Tool
	setInfoDirect(Tool.getIcon() if Tool != null else null, hoverable)
	
func setInfoDirect(icon: Texture2D, _hoverable: bool = false) -> void:
	visible = icon != null
	ToolIcon.texture = icon
	hoverable = _hoverable
	
func setDisabled(state: bool) -> void:
	disabled = state
	onUpdateModulate()
	
func setDisableTooltip(_disable_tooltip: bool) -> void:
	disable_tooltip = _disable_tooltip
	
func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	super(_mouse_filter)
	mouse_filter = _mouse_filter

func setSizeScale(n: int) -> void:
	size *= n
	pivot_offset = (size / 2)
	
func setExpandMode(expand_mode: TextureRect.ExpandMode) -> void:
	ToolIcon.expand_mode = expand_mode

func getPriceLabelPosition() -> Vector2:
	return Vector2(-10, 43)
	
func getItem() -> FofGD: return Tool
