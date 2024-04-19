extends CSGSphere3D
@export var color: Color

func _ready():
	material.albedo_color = color
