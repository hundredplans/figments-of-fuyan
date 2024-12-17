extends Control

@export var CardTooltipExtraPacked: PackedScene

@onready var NameLabel: Label = %NameLabel
@onready var TopIcon: TextureRect = %TopIcon
@onready var TextLabel: FancyTextLabel = %TextLabel
@onready var Topside: Control = %TopSide

func setInfo(info_or_fof: Variant, stop_mouse: bool = false) -> void:
	var info: FofInfo
	var ascended: bool = false
	if is_instance_of(info_or_fof, InfoAscended):
		ascended = info_or_fof.ascended
		info = info_or_fof.info
	
	if is_instance_of(info_or_fof, FofGD):
		NameLabel.text = info_or_fof.info.name
		TopIcon.texture = info_or_fof.getIcon()
		info = info_or_fof.info
		
	elif is_instance_of(info_or_fof, FofInfo):
		var is_card: bool = is_instance_of(info_or_fof, CardInfo)
		NameLabel.text = info_or_fof.name
		TopIcon.texture = info_or_fof.art_mini if is_card else info_or_fof.icon
		info = info_or_fof
	
	TextLabel.setText(info_or_fof.getDescription(ascended) if info in [CardInfo, BoonInfo, ToolInfo] else info_or_fof.getDescription())
	if info is CardInfo:
		var CardTooltipExtra: Control = CardTooltipExtraPacked.instantiate()
		Topside.add_child(CardTooltipExtra)
		CardTooltipExtra.setInfo(info, ascended)
	
	var panel_color: String
	if is_instance_of(info, TraitInfo): panel_color = "YellowPanelContainer"
	elif is_instance_of(info, StatusEffectInfo): panel_color = "RedPanelContainer"
	elif is_instance_of(info, ToolInfo): panel_color = "BluePanelContainer"
	elif is_instance_of(info, FieldEffectInfo): panel_color = "WhitePanelContainer"
	elif is_instance_of(info, BoonInfo): panel_color = "PurplePanelContainer"
	elif is_instance_of(info, MapEffectInfo) and info.id == 2: panel_color = "WhitePanelContainer"
	
	theme_type_variation = panel_color
	mouse_filter = Control.MOUSE_FILTER_STOP if stop_mouse else Control.MOUSE_FILTER_IGNORE
	
func setInfoDirect(title: String, icon: Texture2D, text: String) -> void:
	NameLabel.text = title
	TopIcon.texture = icon
	TextLabel.setText(text)
	theme_type_variation = "BeigePanelContainer"

signal mouse_in_ui
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	
func getTextInfos() -> Array[InfoAscended]:
	return TextLabel.getInfos()
