extends PanelContainer

@onready var NameLabel: Label = %NameLabel
@onready var TopIcon: TextureRect = %TopIcon
@onready var TextLabel: FancyTextLabel = %TextLabel

func setInfo(FofObject: FofGD) -> void:
	NameLabel.text = FofObject.info.name
	TopIcon.texture = FofObject.getIcon()
	TextLabel.setText(FofObject.getDescription())
	
	var panel_color: String
	
	if is_instance_of(FofObject, TraitGD): panel_color = "YellowPanelContainer"
	elif is_instance_of(FofObject, StatusEffectGD): panel_color = "RedPanelContainer"
	elif is_instance_of(FofObject, ToolGD): panel_color = "BluePanelContainer"
	elif is_instance_of(FofObject, FieldEffectGD): panel_color = "WhitePanelContainer"
	elif is_instance_of(FofObject, BoonGD): panel_color = "PurplePanelContainer"
	
	theme_type_variation = panel_color
		
	
