class_name LightInfo
extends Resource

@export var color: Color
@export var energy: float

func setNode(light: Light3D) -> void:
	color = light.light_color
	energy = light.light_energy

static func onConvertNode(light: Light3D) -> LightInfo:
	var light_info: LightInfo
	if light is DirectionalLight3D: light_info = DirectionalLightInfo.new()
	else: light_info = LightInfo.new()
	
	light_info.setNode(light)
	return light_info
