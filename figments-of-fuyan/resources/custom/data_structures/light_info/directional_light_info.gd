class_name DirectionalLightInfo
extends LightInfo

@export var rotation: Vector3

func setNode(light: Light3D) -> void:
	super(light)
	rotation = light.rotation

func onLoad(parent: Node3D) -> Light3D:
	var light := DirectionalLight3D.new()
	light.rotation = rotation
	light.light_color = color
	light.light_energy = energy
	parent.add_child(light)
	return light
