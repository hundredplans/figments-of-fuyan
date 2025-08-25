extends TbcUI

const SPIN_SPEED: float = 10

@onready var NameLabel: Label = %NameLabel
@onready var TierLabel: Label = %TierLabel
@onready var RarityLabel: Label = %RarityLabel
@onready var ToolTxRect: TextureRect = %ToolTextureRect
var Tool: ToolGD

func setInfo(_Tool: ToolGD, _hoverable: bool = false, _autoscale: bool = false) -> void:
	Tool = _Tool
	if Tool != null:
		Tool.update_tier.connect(onUpdateTier)
	setInfoDirect(Tool.getIcon() if Tool != null else null, _hoverable, _autoscale)
	setMouseFilter(mouse_filter)
	onUpdateTier(Tool.getTier() if Tool != null else 0)
	
func onShowTierLabel(label_offset: int = 0) -> void:
	TierLabel.visible = Tool != null
	if Tool == null: return
	TierLabel.modulate = Game.getTierColor(Tool.getTier())
	TierLabel.text = "Tier " + Game.getTierString(Tool.getTier())
	TierLabel.label_settings = getToolBoonLabelSettings(label_offset)
	
func onShowNameLabel(label_offset: int = 0) -> void:
	TierLabel.visible = Tool != null
	if Tool == null: return
	NameLabel.modulate = Game.getRarityColor(Tool.getRarity())
	NameLabel.text = Tool.info.name
	NameLabel.label_settings = getToolBoonLabelSettings(label_offset)
	
func setTool(_Tool: ToolGD) -> void:
	Tool = _Tool
	setInfoDirect(Tool.getIcon() if Tool != null else null, hoverable)
	
func setInfoDirect(icon: Texture2D, _hoverable: bool = false, _autoscale: bool = false) -> void:
	visible = icon != null
	ToolTxRect.texture = icon
	hoverable = _hoverable
	autoscale = _autoscale
	
func setDisabled(state: bool) -> void:
	disabled = state
	onUpdateModulate()
	
func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	super(_mouse_filter)
	mouse_filter = _mouse_filter

func setSizeScale(n: int) -> void:
	var nsize: int = 40 * n
	custom_minimum_size = Vector2(nsize, nsize)
	ToolTxRect.custom_minimum_size = Vector2(nsize, nsize)
	size = Vector2(nsize, nsize)
	pivot_offset = (size / 2)
	
func setExpandMode(expand_mode: TextureRect.ExpandMode) -> void:
	ToolTxRect.expand_mode = expand_mode

func getPriceLabelPosition() -> Vector2:
	return Vector2(-10, 43)
	
func getItem() -> FofGD: return Tool

func onMouseInUI(state: bool) -> void:
	super(state)
	if !disable_tooltip:
		Game.onMouseInUITooltip(state, Tool, self, true)

func onUpdateTier(tier: int) -> void:
	if tier == 0: return
	#ToolTxRect.modulate = Game.getTierColor(tier)
