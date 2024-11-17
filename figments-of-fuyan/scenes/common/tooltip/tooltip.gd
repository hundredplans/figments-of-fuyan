extends PanelContainer

@export var offset: Vector2 = Vector2(10, -40)
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
	elif is_instance_of(FofObject, MapEffectGD) and FofObject.info.id == 2: panel_color = "WhitePanelContainer"
	
	theme_type_variation = panel_color
		
func _process(_delta: float) -> void:
	global_position = get_viewport().get_mouse_position() + offset
	
