extends Control

@export var CardTooltipExtraPacked: PackedScene

@onready var RarityLabel: Label = %RarityLabel
@onready var TierLabel: Label = %TierLabel
@onready var InnerPanelContainer: PanelContainer = %InnerPanelContainer
@onready var NameLabel: Label = %NameLabel
@onready var TopIcon: TextureRect = %TopIcon
@onready var TextLabel: FancyTextLabel = %TextLabel
@onready var Topside: Control = %TopSide

func setInfo(info_or_fof: Variant, stop_mouse: bool = false) -> void:
	var info: FofInfo
	var tier: int = 1
	
	var description: String
	if info_or_fof == null: queue_free(); return
	if is_instance_of(info_or_fof, InfoWithTier):
		tier = info_or_fof.getTier()
		info = info_or_fof.info
		description = info_or_fof.getDescription(true)
		
	elif is_instance_of(info_or_fof, FofGD):
		if info_or_fof is BoonGD or info_or_fof is ToolGD or info_or_fof is CardGD:
			tier = info_or_fof.getTier()
		info = info_or_fof.info
		description = info_or_fof.getDescription()
		
	elif is_instance_of(info_or_fof, FofInfo):
		info = info_or_fof
		if info is CardInfo or info is ToolInfo or info is BoonInfo: description = info.getDescription(tier, true)
		else: description = info.getDescription()
		
	elif is_instance_of(info_or_fof, SavedData):
		tier = info_or_fof.getTier()
		info = Helper.getFofInfoID(info_or_fof.getInfoType(), info_or_fof.id)
		info_or_fof = info
		
		if info is CardInfo or info is ToolInfo or info is BoonInfo: description = info.getDescription(tier, true)
		else: description = info.getDescription()
	
	TopIcon.texture = info.getIcon()
	
	if info is CardInfo:
		var CardTooltipExtra: Control = CardTooltipExtraPacked.instantiate()
		Topside.add_child(CardTooltipExtra)
		CardTooltipExtra.setInfo(info, tier)
	
	if info is BoonInfo or info is ToolInfo or info is CardInfo:
		RarityLabel.text = Game.getRarityString(info.rarity)
		RarityLabel.modulate = Game.getRarityColor(info.rarity)
		
		TierLabel.text = "Tier  " + Game.getTierString(tier)
		TierLabel.modulate = Game.getTierColor(tier)
		
		NameLabel.text = info.name
		NameLabel.modulate = Game.getRarityColor(info.rarity)
	else:
		NameLabel.text = "%s" % info.name
		theme_type_variation = "YellowPanelContainer"
		InnerPanelContainer.visible = false
	
	mouse_filter = Control.MOUSE_FILTER_STOP if stop_mouse else Control.MOUSE_FILTER_IGNORE
	TextLabel.setText(description)
	
func setInfoDirect(title: String, icon: Texture2D, text: String) -> void:
	NameLabel.text = title
	TopIcon.texture = icon
	TextLabel.setText(text)
	theme_type_variation = "BeigePanelContainer"

signal mouse_in_ui
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	
func getTextInfos() -> Array[InfoWithTier]:
	return TextLabel.getInfos()
