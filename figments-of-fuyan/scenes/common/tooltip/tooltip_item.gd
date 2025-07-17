extends Control

@export var CardTooltipExtraPacked: PackedScene

@onready var NameLabel: Label = %NameLabel
@onready var TopIcon: TextureRect = %TopIcon
@onready var TextLabel: FancyTextLabel = %TextLabel
@onready var Topside: Control = %TopSide

func setInfo(info_or_fof: Variant, stop_mouse: bool = false) -> void:
	var info: FofInfo
	var ascended: bool = false
	var tier: int = 0
	if info_or_fof == null: queue_free(); return
	if is_instance_of(info_or_fof, InfoAscended):
		ascended = info_or_fof.ascended
		info = info_or_fof.info
		
	elif is_instance_of(info_or_fof, InfoWithTier):
		tier = info_or_fof.getTier()
		info = info_or_fof.info
		
	elif is_instance_of(info_or_fof, FofGD):
		if info_or_fof is BoonGD or info_or_fof is ToolGD or info_or_fof is CardGD:
			ascended = info_or_fof.getAscended()
		info = info_or_fof.info
		
	elif is_instance_of(info_or_fof, FofInfo):
		info = info_or_fof
		
	elif is_instance_of(info_or_fof, SavedData):
		if info_or_fof is SavedDataBoon or info_or_fof is SavedDataTool:
			ascended = info_or_fof.ascended
		elif info_or_fof is SavedDataCard:
			tier = info_or_fof.getTier()
		info = Helper.getFofInfoID(info_or_fof.getInfoType(), info_or_fof.id)
		info_or_fof = info
		
	NameLabel.text = info.name
	TopIcon.texture = info.getIcon()
	
	var description: String = info_or_fof.getDescription()
	TextLabel.setText(description)
	if info is CardInfo:
		var CardTooltipExtra: Control = CardTooltipExtraPacked.instantiate()
		Topside.add_child(CardTooltipExtra)
		CardTooltipExtra.setInfo(info, tier)
	
	var theme_variation: String
	if is_instance_of(info, ToolInfo) or is_instance_of(info, BoonInfo) or is_instance_of(info, CardInfo):
		theme_variation = Game.getRarityThemeVariation(info.rarity, ascended)
	else:
		theme_variation = "YellowPanelContainer"
	
	theme_type_variation = theme_variation
	mouse_filter = Control.MOUSE_FILTER_STOP if stop_mouse else Control.MOUSE_FILTER_IGNORE
	
func setInfoDirect(title: String, icon: Texture2D, text: String) -> void:
	NameLabel.text = title
	TopIcon.texture = icon
	TextLabel.setText(text)
	theme_type_variation = "BeigePanelContainer"

signal mouse_in_ui
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	
func getTextInfos() -> Array[InfoWithExtra]:
	return TextLabel.getInfos()
