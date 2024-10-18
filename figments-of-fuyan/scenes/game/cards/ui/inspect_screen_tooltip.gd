extends PanelContainer

@export_group("Top Icon")
@export var tool_icon: Texture2D
@export var ability_icon: Texture2D
@export var ultimate_icon: Texture2D
@export var trait_icon: Texture2D
@export var trinket_icon: Texture2D
@export_group("")

@onready var NameLabel: Label = %NameLabel
@onready var TopIcon: TextureRect = %TopIcon
@onready var TextLabel: FancyTextLabel = %TextLabel

func setInfo(FofObject: FofGD) -> void:
	NameLabel.text = FofObject.info.name
	TopIcon.texture = FofObject.getIcon()
	TextLabel.setText(FofObject.getDescription())
	
	var panel_color: String
	
	if is_instance_of(FofObject, TraitGD): panel_color = "BluePanelContainer"
	elif is_instance_of(FofObject, StatusEffectGD): panel_color = "WhitePanelContainer"
	
	theme_type_variation = panel_color
		
	
